import 'dart:io';

import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FocusAnalyzerService {
  FaceMeshDetector? _faceMeshDetector;
  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _isRunning = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _faceMeshDetector = FaceMeshDetector(
      option: FaceMeshDetectorOptions.faceMesh,
    );
    _interpreter = await Interpreter.fromAsset(
      'assets/models/landmark_model.tflite',
    );
    _isInitialized = true;
  }

  Future<String> analyze(
    File imageFile, {
    required double previewWidth,
    required double previewHeight,
  }) async {
    if (!_isInitialized || _faceMeshDetector == null || _interpreter == null) {
      throw StateError('FocusAnalyzerService is not initialized');
    }
    if (_isRunning) {
      // 이전 추론이 아직 끝나지 않았으면 스킵
      return '분석 중';
    }
    _isRunning = true;
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceMeshDetector!.processImage(inputImage);
      if (faces.isEmpty) {
        return '얼굴 미감지';
      }

      final coords = faces.first.points.map((p) => [p.x, p.y]).toList();
      final normalized = _normalizeCoords(coords, previewWidth, previewHeight);

      // 전치 (468, 2) -> (2, 468)
      final transposed = List.generate(2, (_) => List.filled(468, 0.0));
      for (int i = 0; i < 468; i++) {
        transposed[0][i] = normalized[i][0];
        transposed[1][i] = normalized[i][1];
      }

      final input = [transposed]; // [1, 2, 468]
      final output = List.generate(1, (_) => List.filled(3, 0.0)); // [1,3]

      _interpreter!.run(input, output);

      final List<String> labels = ['집중', '집중안함', '졸음'];
      int maxIdx = 0;
      double maxVal = output[0][0];
      for (int i = 1; i < output[0].length; i++) {
        if (output[0][i] > maxVal) {
          maxVal = output[0][i];
          maxIdx = i;
        }
      }
      return labels[maxIdx];
    } finally {
      _isRunning = false;
    }
  }

  Future<void> dispose() async {
    await _faceMeshDetector?.close();
    _faceMeshDetector = null;
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }

  List<List<double>> _normalizeCoords(
    List<List<double>> coords,
    double width,
    double height,
  ) {
    return coords.map((p) => [p[0] / width, p[1] / height]).toList();
  }
}
