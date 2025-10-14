import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/services/focus_time_service.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:focused_study_time_tracker/services/focus_analyzer_service.dart';
import 'package:focused_study_time_tracker/utils/image_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class FocusTimeScreenV2 extends StatefulWidget {
  const FocusTimeScreenV2({super.key});

  @override
  _FocusTimeScreenV2State createState() => _FocusTimeScreenV2State();
}

class _FocusTimeScreenV2State extends State<FocusTimeScreenV2> {
  CameraController? _cameraController;
  Timer? _frameTimer;
  bool _isCameraInitialized = false;
  NativeDeviceOrientation? _orientation;
  List<CameraDescription> cameras = [];
  StreamSubscription<NativeDeviceOrientation>? _orientationSubscription;

  String _focusStatus = '대기 중';
  final FocusAnalyzerService _analyzer = FocusAnalyzerService();

  // 실시간 녹화 시간 표시용
  Duration _elapsed = Duration.zero;
  Timer? _elapsedTimer;

  bool _isLocked = false;
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
    // 실시간 경과 시간 타이머 시작
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!mounted || _sessionStartAt == null) return;
      setState(() {
        _elapsed = DateTime.now().difference(_sessionStartAt!);
      });
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();

    // 화면 종료 시에는 상태 변경 없이 자원만 정리
    _finalizeAndPost();
    _stopCamera(updateState: false);
    _orientationSubscription?.cancel();
    _analyzer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
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
  FocusTimeInsertDto? _finalizeAndPost() {
    try {
      if (_sessionStartAt == null) return null;
      final DateTime endAt = DateTime.now();

      // 진행 중인 비집중 구간 마감
      if (_currentUnfocusedStart != null && _currentUnfocusedType != null) {
        _pushFragment(_currentUnfocusedStart!, endAt, _currentUnfocusedType!);
        _currentUnfocusedStart = null;
        _currentUnfocusedType = null;
      }

      //비 집중구간이 n초 이하이면 삭제
      _unfocusedFragments.removeWhere((fragment) {
        final start = DateTime.parse('$fragment.startAt');
        final end = DateTime.parse('$fragment.endAt');
        return end.difference(start).inSeconds <= 3;
      });

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
      return dto;
    } catch (e) {
      debugPrint('세션 마감 중 오류: $e');
      return null;
    }
  }

  Color _getFocusStatusColor(String status) {
    switch (status) {
      case '졸음':
        return Colors.orange;
      case '집중 안함':
        return const Color.fromARGB(255, 61, 110, 92);
      case '얼굴 미감지':
        return Colors.blue;
      case '집중':
        return Colors.white;
      default:
        return const Color.fromARGB(255, 93, 135, 191);
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final cameraPreview =
        _isCameraInitialized && _cameraController != null
            ? FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: CameraPreview(_cameraController!),
              ),
            )
            : Center(child: Text('전면 카메라 화면'));

    return DefaultLayout(
      child: Stack(
        children: [
          Container(color: Colors.black),
          // 카메라 전체 화면
          // 그냥 child로만 사용
          cameraPreview,
          // 상단 시간 표시
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF6BAB93),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  _formatDuration(_elapsed),
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '상태: $_focusStatus',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'SoyoMaple',
                  color: _getFocusStatusColor(_focusStatus),
                ),
              ),
            ),
          ),
          // 하단 버튼들
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                      backgroundColor: Color(0xFFF95C3B),
                    ),
                    onPressed:
                        _isLocked
                            ? null
                            : () {
                              if (_elapsed.inSeconds < 60) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('최소한 1분 이상 진행해주세요.'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.black.withOpacity(
                                      0.7,
                                    ), // 투명도 70%
                                    behavior:
                                        SnackBarBehavior
                                            .floating, // (선택) 위로 띄우기
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                          0.4,
                                    ),
                                    padding: EdgeInsets.fromLTRB(80, 0, 0, 0),
                                  ),
                                );
                                return;
                              }
                              // 1. _finalizeAndPost 함수를 호출하여 dto 데이터를 받습니다.
                              final sessionData = _finalizeAndPost();

                              // 2. 데이터가 null이 아닌지 확인합니다. (안전장치)
                              if (sessionData != null) {
                                // 3. 결과 화면으로 데이터를 전달하며 이동합니다.
                                context.go('/result', extra: sessionData);
                              }
                            },
                    child: Icon(Icons.pause, color: Colors.black),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(16),
                        backgroundColor: Colors.black87,
                      ),
                      onPressed:
                          _isLocked
                              ? null
                              : () {
                                setState(() {
                                  _isLocked = true;
                                });
                              },
                      child: Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 잠금 오버레이
          if (_isLocked)
            Positioned.fill(
              child: Stack(
                children: [
                  AbsorbPointer(
                    absorbing: true,
                    child: Container(color: Colors.black),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF6BAB93),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          _formatDuration(_elapsed),
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 32,
                        right: 8,
                      ), // 기존 잠금 버튼 위치와 동일
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isLocked = false;
                          });
                        },
                        child: Icon(
                          Icons.lock_open,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
