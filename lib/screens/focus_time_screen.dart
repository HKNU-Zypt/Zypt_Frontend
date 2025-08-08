import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class FocusTimeScreen extends StatefulWidget {
  const FocusTimeScreen({super.key});

  @override
  _FocusTimeScreenState createState() => _FocusTimeScreenState();
}

class _FocusTimeScreenState extends State<FocusTimeScreen> {
  CameraController? _cameraController;
  FaceMeshDetector? _faceMeshDetector;
  Interpreter? _interpreter;
  Timer? _frameTimer;
  bool _isCameraInitialized = false;
  NativeDeviceOrientation? _orientation;
  List<CameraDescription> cameras = [];
  StreamSubscription<NativeDeviceOrientation>? _orientationSubscription;

  String _focusStatus = '대기 중';

  @override
  void initState() {
    super.initState();
    _startListeningOrientation();
    _initializeCamera();
  }

  @override
  void dispose() {
    // 화면 종료 시에는 상태 변경 없이 자원만 정리
    _stopCamera(updateState: false);
    _orientationSubscription?.cancel();
    _faceMeshDetector?.close();
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
  }

  // 회전 방향을 감지하는 함수.
  void _startListeningOrientation() {
    _orientationSubscription = NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen((orientation) {
          if (!mounted) return;
          setState(() {
            _orientation = orientation;
          });
        });
  }

  // 이미지와 화면 각도를 같이 받아 화면 각도에 따라 이미지를 회전시키기 위한 함수.
  Future<File> rotateImageFile(
    File file,
    NativeDeviceOrientation orientation,
  ) async {
    // 파일을 바이트로 읽기
    final bytes = await file.readAsBytes();

    // image 패키지로 디코딩
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('이미지 디코딩 실패');

    // 회전 각도 설정 (필요시 상황에 맞게 조정)
    int rotationDegree = 0;
    switch (orientation) {
      case NativeDeviceOrientation.portraitUp:
        rotationDegree = 0;
        break;
      case NativeDeviceOrientation.landscapeLeft:
        rotationDegree = 90;
        break;
      case NativeDeviceOrientation.portraitDown:
        rotationDegree = 180;
        break;
      case NativeDeviceOrientation.landscapeRight:
        rotationDegree = 270;
        break;
      default:
        rotationDegree = 0;
    }

    // 이미지 회전 (시계 방향)
    if (rotationDegree != 0) {
      image = img.copyRotate(image, angle: rotationDegree);
    }

    // 임시 디렉토리에 저장
    final tempDir = await getTemporaryDirectory();
    final rotatedFile = File('${tempDir.path}/rotated_image.jpg');

    await rotatedFile.writeAsBytes(img.encodeJpg(image));
    return rotatedFile;
  }

  // 카메라 켰을 때
  Future<void> _startCamera() async {
    if (_cameraController != null) return;

    try {
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => throw Exception('Front camera not found'),
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      // 얼굴인식을 위한 faceMesh 초기화
      _faceMeshDetector = FaceMeshDetector(
        option: FaceMeshDetectorOptions.faceMesh,
      );

      // 모델을 사용하기 위해 모델 초기화
      _interpreter = await Interpreter.fromAsset(
        'assets/models/landmark_model.tflite',
      );

      // 2초마다 사진 찍고 분석
      _frameTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _analyzeImage(),
      );

      setState(() {
        _isCameraInitialized = true;
        _focusStatus = '카메라 준비 완료';
      });
    } catch (e) {
      setState(() {
        _focusStatus = '카메라 초기화 실패: $e';
      });
    }
  }

  // 카메라 껐을 때
  void _stopCamera({bool updateState = true}) {
    _frameTimer?.cancel();
    _frameTimer = null;

    _cameraController?.dispose();
    _cameraController = null;

    _faceMeshDetector?.close();
    _faceMeshDetector = null;

    _interpreter?.close();
    _interpreter = null;

    if (updateState && mounted) {
      setState(() {
        _isCameraInitialized = false;
        _focusStatus = '카메라 종료';
      });
    }
  }

  // 이미지를 인식하고 예측을 담당하는 함수.
  Future<void> _analyzeImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _faceMeshDetector == null ||
        _interpreter == null) {
      return;
    }

    try {
      // 디바이스 방향 정보가 없으면 분석 불가
      if (_orientation == null) return;

      final XFile picture = await _cameraController!.takePicture();
      final File rotatedFile = await rotateImageFile(
        File(picture.path),
        _orientation!,
      );

      final inputImage = InputImage.fromFilePath(rotatedFile.path);
      final faces = await _faceMeshDetector!.processImage(inputImage);
      if (faces.isEmpty) {
        if (!mounted) return;
        setState(() {
          _focusStatus = '얼굴 미감지';
        });
        return;
      }

      final previewSize = _cameraController!.value.previewSize;
      if (previewSize == null) return;

      final coords = faces.first.points.map((p) => [p.x, p.y]).toList();

      final normalizedCoords = normalizeCoords(
        coords,
        previewSize.width,
        previewSize.height,
      );

      // 1) 전치 (468, 2) -> (2, 468)
      final transposed = List.generate(2, (_) => List.filled(468, 0.0));
      for (int i = 0; i < 468; i++) {
        transposed[0][i] = normalizedCoords[i][0];
        transposed[1][i] = normalizedCoords[i][1];
      }

      // 2) (1, 2, 468) 입력 생성
      final input = [transposed];

      // 출력 버퍼 [1, 3]
      final output = List.generate(1, (_) => List.filled(3, 0.0));

      _interpreter!.run(input, output);

      final maxIndex = output[0].indexWhere(
        (val) => val == output[0].reduce((a, b) => a > b ? a : b),
      );

      final labels = ['집중', '집중안함', '졸음'];

      if (!mounted) return;
      setState(() {
        _focusStatus = labels[maxIndex];
      });
    } catch (e) {
      debugPrint("⚠️ 분석 중 오류 발생: $e");
      if (!mounted) return;
      setState(() {
        _focusStatus = '분석 오류';
      });
    }
  }

  // 좌표를 정규화하기 위한 함수.
  List<List<double>> normalizeCoords(
    List<List<double>> coords,
    double width,
    double height,
  ) {
    return coords
        .map((point) => [point[0] / width, point[1] / height])
        .toList();
  }

  // 카메라를 키고 끄기 위한 버튼에 적용되는 함수.
  void _toggleCamera() {
    if (_isCameraInitialized) {
      _stopCamera();
    } else {
      _startCamera();
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FaceMesh 집중도 예측')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child:
                  _isCameraInitialized && _cameraController != null
                      ? CameraPreview(_cameraController!)
                      : const Text('카메라가 꺼져있습니다'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('상태: $_focusStatus', style: const TextStyle(fontSize: 20)),
                Text(
                  '디바이스 방향: ${_orientation.toString().split('.').last}',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _toggleCamera,
              child: Text(_isCameraInitialized ? '카메라 끄기' : '카메라 켜기'),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
