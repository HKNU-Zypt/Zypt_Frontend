import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<File> rotateImageFile(
    File file,
    NativeDeviceOrientation orientation,
  ) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('이미지 디코딩 실패');

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

    if (rotationDegree != 0) {
      image = img.copyRotate(image, angle: rotationDegree);
    }

    final tempDir = await getTemporaryDirectory();
    final rotatedFile = File('${tempDir.path}/rotated_image.jpg');
    await rotatedFile.writeAsBytes(img.encodeJpg(image));
    return rotatedFile;
  }
}
