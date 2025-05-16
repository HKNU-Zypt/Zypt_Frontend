import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:path_provider/path_provider.dart';
import '../services/focus_analyzer.dart';

class FocusTimeScreen extends StatefulWidget {
  const FocusTimeScreen({super.key});

  @override
  State<FocusTimeScreen> createState() => _FocusTimeScreenState();
}

class _FocusTimeScreenState extends State<FocusTimeScreen> {
  late FocusAnalyzer _focusAnalyzer;
  late CameraController _controller;
  bool _isCameraInitialized = false;
  Timer? _timer;
  bool _isInitialized = false;
  String tempFilePath = "";
  String _currentLabel = "";

  @override
  void initState() {
    super.initState();
    _initializeFocusAnalyzer();
    _initializeCamera();
  }

  int _photoCount = 0;

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller.initialize();
      setState(() {
        _isCameraInitialized = true;
      });

      // Start taking photos every 10 seconds
      _startPhotoTimer();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _initializeFocusAnalyzer() async {
    try {
      _focusAnalyzer = FocusAnalyzer();
      await _focusAnalyzer.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing focus analyzer: $e');
      _isInitialized = false;
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile photo = await _controller.takePicture();

      // Convert XFile to byte data
      final bytes = await photo.readAsBytes();

      // Convert image to tensor
      final Uint8List imageBytes = bytes.buffer.asUint8List();

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp.jpg';

      try {
        // Delete existing file if it exists
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }

        // Write new file
        await file.writeAsBytes(imageBytes);

        // Store file path for cleanup
        tempFilePath = path;

        // Process with FocusAnalyzer
        if (_isInitialized) {
          try {
            final prediction = await _focusAnalyzer.analyzeFocus(imageBytes);

            setState(() {
              _currentLabel = prediction;
            });
          } catch (e) {
            print('Error during inference: $e');
          }
        }

        setState(() {
          _photoCount++;
        });
      } catch (e) {
        return;
      } finally {
        try {
          await File(tempFilePath).delete();
        } catch (e) {
          return;
        }
      }
    } catch (e) {
      return;
    }
  }

  void _startPhotoTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _takePhoto();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultLayout(
      child: Column(
        children: [
          Expanded(child: CameraPreview(_controller)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '사진 수: $_photoCount',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  '현재 상태: $_currentLabel',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('집중 종료', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
