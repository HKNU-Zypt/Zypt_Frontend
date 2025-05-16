import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FocusAnalyzer {
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isInitialized = false;

  static const int numLandmarks = 478;
  static const int maxWidth = 640;

  Future<void> initialize() async {
    try {
      // Load model
      final modelPath = 'assets/concentration_model.tflite';

      // Initialize interpreter
      _interpreter = await Interpreter.fromAsset(modelPath);

      // Load labels
      _labels = ["focused", "unfocused", "drowsy"];

      _isInitialized = true;
    } catch (e) {
      print('Error initializing focus analyzer: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<String> analyzeFocus(Uint8List imageBytes) async {
    if (!_isInitialized) {
      throw Exception('Focus analyzer is not initialized');
    }

    try {
      // 1. EXIF 회전 수정
      final correctedImage = await _correctImageOrientation(imageBytes);

      // 2. 이미지 리사이징
      final resizedImage = _resizeImage(correctedImage);

      // 3. 얼굴 랜드마크 추출
      final landmarks = await _extractLandmarks(resizedImage);

      // 4. 전처리
      final preprocessedLandmarks = _preprocessLandmarks(landmarks);

      // 5. 모델에 입력
      final prediction = _runModel(preprocessedLandmarks);

      return prediction;
    } catch (e) {
      print('Error analyzing focus: $e');
      rethrow;
    }
  }

  Future<img.Image> _correctImageOrientation(Uint8List imageBytes) async {
    final tempDir = Directory.systemTemp;
    final tempFile = await File('${tempDir.path}/temp_image.jpg').create();
    await tempFile.writeAsBytes(imageBytes);

    final correctedFile = await FlutterExifRotation.rotateImage(
      path: tempFile.path,
    );
    final correctedBytes = await correctedFile.readAsBytes();

    final image = img.decodeImage(correctedBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    return image;
  }

  img.Image _resizeImage(img.Image image) {
    final width = min(image.width, maxWidth);
    final height = (image.height * (width / image.width)).round();
    return img.copyResize(image, width: width, height: height);
  }

  // RGBA8888 → BGRA8888 변환 함수
  Uint8List _rgbaToBgra(Uint8List rgbaBytes) {
    final bgra = Uint8List(rgbaBytes.length);
    for (int i = 0; i < rgbaBytes.length; i += 4) {
      bgra[i] = rgbaBytes[i + 2];     // B
      bgra[i + 1] = rgbaBytes[i + 1]; // G
      bgra[i + 2] = rgbaBytes[i];     // R
      bgra[i + 3] = rgbaBytes[i + 3]; // A
    }
    return bgra;
  }

  Future<Float32List> _extractLandmarks(img.Image image) async {
    // Use RGBA8888 raw bytes (default from getBytes)
    final rgbaBytes = image.getBytes();
    final bgraBytes = _rgbaToBgra(rgbaBytes);

    // Create input image for face mesh detection
    final inputImage = InputImage.fromBytes(
      bytes: bgraBytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.width * 4, // 4 bytes per pixel (BGRA8888)
      ),
    );

    final faceMeshDetector = FaceMeshDetector(
      option: FaceMeshDetectorOptions.faceMesh,
    );

    final List<FaceMesh> faceMeshes = await faceMeshDetector.processImage(
      inputImage,
    );
    if (faceMeshes.isEmpty) {
      throw Exception('No face detected');
    }

    final faceMesh = faceMeshes.first;
    final landmarks = Float32List(numLandmarks * 2);

    // Process all 478 landmarks
    for (var i = 0; i < numLandmarks; i++) {
      final point = faceMesh.points[i];
      final x = point.x.toDouble();
      final y = point.y.toDouble();
      landmarks[i * 2] = x;
      landmarks[i * 2 + 1] = y;
    }

    return landmarks;
  }

  Float32List _preprocessLandmarks(Float32List landmarks) {
    final xs = [for (var i = 0; i < numLandmarks; i++) landmarks[i * 2]];
    final ys = [for (var i = 0; i < numLandmarks; i++) landmarks[i * 2 + 1]];
    final meanX = xs.reduce((a, b) => a + b) / numLandmarks;
    final meanY = ys.reduce((a, b) => a + b) / numLandmarks;
    for (var i = 0; i < numLandmarks; i++) {
      landmarks[i * 2] -= meanX;
      landmarks[i * 2 + 1] -= meanY;
    }
    return landmarks;
  }

  String _runModel(Float32List input) {
    final output = Float32List(_labels.length);
    _interpreter.run(input, output);
    int maxIndex = 0;
    double maxValue = output[0];
    for (int i = 1; i < output.length; i++) {
      if (output[i] > maxValue) {
        maxValue = output[i];
        maxIndex = i;
      }
    }
    return _labels[maxIndex];
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
    }
  }
}
