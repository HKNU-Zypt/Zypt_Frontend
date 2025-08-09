import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/services/focus_time_service.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:focused_study_time_tracker/services/focus_analyzer_service.dart';
import 'package:focused_study_time_tracker/utils/image_utils.dart';
import 'package:intl/intl.dart';

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

  // 세션 및 비집중 구간 추적
  DateTime? _sessionStartAt;
  final List<FragmentedUnFocusedTimeInsertDto> _unfocusedFragments = [];
  DateTime? _currentUnfocusedStart;
  UnFocusedType? _currentUnfocusedType;

  @override
  void initState() {
    super.initState();
    _startListeningOrientation();
    _sessionStartAt = DateTime.now();
    _initializeCamera();
    _analyzer.initialize();
  }

  @override
  void dispose() {
    // 화면 종료 시에는 상태 변경 없이 자원만 정리
    _finalizeAndPost();
    _stopCamera(updateState: false);
    _orientationSubscription?.cancel();
    _analyzer.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (!mounted) return;
    await _startCamera();
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

  // 세션을 마감하고 서버로 전송
  void _finalizeAndPost() {
    try {
      if (_sessionStartAt == null) return;
      final DateTime endAt = DateTime.now();

      // 진행 중인 비집중 구간 마감
      if (_currentUnfocusedStart != null && _currentUnfocusedType != null) {
        _pushFragment(_currentUnfocusedStart!, endAt, _currentUnfocusedType!);
        _currentUnfocusedStart = null;
        _currentUnfocusedType = null;
      }

      final dto = FocusTimeInsertDto(
        startAt: _formatTime(_sessionStartAt!),
        endAt: _formatTime(endAt),
        createDate: _formatDate(_sessionStartAt!),
        fragmentedUnFocusedTimeInsertDtos: List.from(_unfocusedFragments),
      );

      debugPrint(
        '[FocusTimeScreen] finalize dto fragments: '
        '${dto.fragmentedUnFocusedTimeInsertDtos.length}',
      );
      for (final f in dto.fragmentedUnFocusedTimeInsertDtos) {
        debugPrint('[FocusTimeScreen]  - ${f.type} ${f.startAt} ~ ${f.endAt}');
      }
      // dispose 중 비동기 전송
      unawaited(
        FocusTimeService()
            .createFocusTime(dto)
            .then((msg) {
              debugPrint('FocusTime POST 성공: $msg');
            })
            .catchError((e) {
              debugPrint('FocusTime POST 실패: $e');
            }),
      );
    } catch (e) {
      debugPrint('세션 마감 중 오류: $e');
    }
  }

  String _formatTime(DateTime dt) => DateFormat('HH:mm:ss').format(dt);
  String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  void _handleAnalysisResult(String label) {
    // 집중: null, 졸음: SLEEP, 그 외(집중안함/얼굴 미감지/분석 오류 등): DISTRACTED
    if (label == '분석 중') return;

    UnFocusedType? newType;
    if (label == '집중') {
      newType = null;
    } else if (label == '졸음') {
      newType = UnFocusedType.SLEEP;
    } else {
      newType = UnFocusedType.DISTRACTED;
    }

    _updateUnfocusedState(newType);
  }

  void _updateUnfocusedState(UnFocusedType? newType) {
    final DateTime now = DateTime.now();

    // 집중 상태로 복귀 → 진행 중이던 비집중 구간 종료
    if (newType == null) {
      if (_currentUnfocusedStart != null && _currentUnfocusedType != null) {
        _pushFragment(_currentUnfocusedStart!, now, _currentUnfocusedType!);
        _currentUnfocusedStart = null;
        _currentUnfocusedType = null;
      }
      return;
    }

    // 비집중 시작
    if (_currentUnfocusedStart == null) {
      _currentUnfocusedStart = now;
      _currentUnfocusedType = newType;
      return;
    }

    // 타입 변경 시 구간 분할
    if (_currentUnfocusedType != newType) {
      _pushFragment(_currentUnfocusedStart!, now, _currentUnfocusedType!);
      _currentUnfocusedStart = now;
      _currentUnfocusedType = newType;
    }
  }

  void _pushFragment(DateTime start, DateTime end, UnFocusedType type) {
    if (_sessionStartAt == null) return;
    final bool startInRange =
        start.isAfter(_sessionStartAt!) ||
        start.isAtSameMomentAs(_sessionStartAt!);
    if (!startInRange) return;

    _unfocusedFragments.add(
      FragmentedUnFocusedTimeInsertDto(
        startAt: _formatTime(start),
        endAt: _formatTime(end),
        type: type,
      ),
    );
    debugPrint(
      '[FocusTimeScreen] pushFragment: $type '
      '${_formatTime(start)} ~ ${_formatTime(end)} '
      '(total=${_unfocusedFragments.length})',
    );
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
      _handleAnalysisResult(result);
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
