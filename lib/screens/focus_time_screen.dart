import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:focused_study_time_tracker/services/focus_analyzer_service.dart';
import 'package:focused_study_time_tracker/utils/image_utils.dart';

class FocusTimeScreen extends StatefulWidget {
  const FocusTimeScreen({super.key});

  @override
  _FocusTimeScreenState createState() => _FocusTimeScreenState();
}

class _FocusTimeScreenState extends State<FocusTimeScreen> {
  CameraController? _cameraController;
  Timer? _frameTimer;
  bool _isCameraInitialized = false;
  NativeDeviceOrientation? _orientation;
  List<CameraDescription> cameras = [];
  StreamSubscription<NativeDeviceOrientation>? _orientationSubscription;

  String _focusStatus = '대기 중';
  final FocusAnalyzerService _analyzer = FocusAnalyzerService();

  @override
  void initState() {
    super.initState();
    _startListeningOrientation();
    _initializeCamera();
    _analyzer.initialize();
  }

  @override
  void dispose() {
    // 화면 종료 시에는 상태 변경 없이 자원만 정리
    _stopCamera(updateState: false);
    _orientationSubscription?.cancel();
    _analyzer.dispose();
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
  // 이미지 회전은 유틸로 이동

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

      // 1초마다 사진 찍고 분석
      _frameTimer = Timer.periodic(
        const Duration(seconds: 1),
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

    if (updateState && mounted) {
      setState(() {
        _isCameraInitialized = false;
        _focusStatus = '카메라 종료';
      });
    }
  }

  // 이미지를 인식하고 예측을 담당하는 함수.
  Future<void> _analyzeImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // 디바이스 방향 정보가 없으면 분석 불가
      if (_orientation == null) return;

      final XFile picture = await _cameraController!.takePicture();
      final File rotatedFile = await ImageUtils.rotateImageFile(
        File(picture.path),
        _orientation!,
      );
      final previewSize = _cameraController!.value.previewSize;
      if (previewSize == null) return;

      final result = await _analyzer.analyze(
        rotatedFile,
        previewWidth: previewSize.width,
        previewHeight: previewSize.height,
      );

      if (!mounted) return;
      setState(() {
        _focusStatus = result;
      });
    } catch (e) {
      debugPrint("⚠️ 분석 중 오류 발생: $e");
      if (!mounted) return;
      setState(() {
        _focusStatus = '분석 오류';
      });
    }
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
    return DefaultLayout(
      appBar: AppBar(title: const Text('FaceMesh 집중도 예측')),
      child: Column(
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
