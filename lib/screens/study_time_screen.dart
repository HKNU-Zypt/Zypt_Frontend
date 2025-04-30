import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class StudyTimeScreen extends StatefulWidget {
  const StudyTimeScreen({super.key});

  @override
  State<StudyTimeScreen> createState() => _StudyTimeScreenState();
}

class _StudyTimeScreenState extends State<StudyTimeScreen> {
  late ClassificationModel classificationModel;
  late CameraController _controller;
  bool _isCameraInitialized = false;
  Timer? _timer;
  bool _isModelLoaded = false;
  String tempFilePath = "";

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  int _photoCount = 0;

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(frontCamera, ResolutionPreset.medium);

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

  Future<void> _loadModel() async {
    try {
      // Load PyTorch model
      final modelPath = 'assets/model.pt';

      // Load model
      classificationModel = await PytorchLite.loadClassificationModel(
        modelPath,
        224,
        224,
        5, // class 수
        labelPath: "assets/labels/label_classification_imageNet.txt",
      );

      print('Model loaded successfully');
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print('Error loading model: $e');
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

        // Process with PyTorch Lite
        if (_isModelLoaded) {
          try {
            // Run inference with .jpg file
            final prediction = await classificationModel.getImagePrediction(
              await File(tempFilePath).readAsBytes(),
            );

            print('Model prediction: $prediction');
            // TODO: Process the prediction here
          } catch (e) {
            print('Error during inference: $e');
          }
        }

        setState(() {
          _photoCount++;
        });
        print('Photo processed: $_photoCount');
      } catch (e) {
        print('Error saving temporary file: $e');
        return;
      } finally {
        try {
          await File(tempFilePath).delete();
        } catch (e) {
          print('Error deleting temporary file: $e');
        }
      }
    } catch (e) {
      print('Error taking photo: $e');
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

    return Scaffold(
      body: Column(
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
