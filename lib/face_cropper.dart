library face_cropper;

import 'dart:async';
import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:logger/logger.dart';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class FaceCropper {
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: true,
    ),
  );

  Future<String?> detectFacesAndCrop(String imagePath) async {
    try {
      final imageName = imagePath.split('/').last.split('?').first;
      final directoryPath = await getApplicationCacheDirectory();
      final newImagePath =
          '${directoryPath.path}/${DateTime.now().toString()}_$imageName';

      final inputImage =
          InputImage.fromFile(File.fromUri(Uri.parse(imagePath)));

      final fileLength =
          File(inputImage.filePath ?? '').readAsBytesSync().lengthInBytes;

      if (fileLength == 0) {
        Logger().e('FaceCropper: Invalid file');
        return null;
      }

      List<Face> faces = await faceDetector.processImage(inputImage);

      List<Map<String, int>> faceMaps = [];

      if (faces.isEmpty) {
        Logger().e('FaceCropper: No faces detected in the image');
        return imagePath;
      }

      for (Face face in faces) {
        int x = face.boundingBox.left.toInt();
        int y = face.boundingBox.top.toInt();
        int w = face.boundingBox.width.toInt();
        int h = face.boundingBox.height.toInt();
        Map<String, int> thisMap = {'x': x, 'y': y, 'w': w, 'h': h};
        faceMaps.add(thisMap);
      }

      // create an img.Image from your original image file for processing
      final originalImage =
          img.decodeImage(await File(imagePath).readAsBytes());

      img.Image? faceCrop;

      // now crop out only the detected face boundry, below will crop out the first face from the list
      if (originalImage != null) {
        final imageWidth = originalImage.width;
        final xPadding = (imageWidth - (faceMaps[0]['w'] ?? 0)) ~/ 6;
        final yPadding = (imageWidth - (faceMaps[0]['h'] ?? 0)) ~/ 6;

        final isWidthSmaller = (faceMaps[0]['w'] ?? 0) + (xPadding * 2) <
            (faceMaps[0]['h'] ?? 0) + (yPadding * 2);
        faceCrop = img.copyCrop(
          originalImage,
          x: (faceMaps[0]['x'] ?? 0) - xPadding,
          y: (faceMaps[0]['y'] ?? 0) - yPadding,
          width: isWidthSmaller
              ? (faceMaps[0]['w'] ?? 0) + (xPadding * 2)
              : (faceMaps[0]['h'] ?? 0) + (yPadding * 2),
          height: isWidthSmaller
              ? (faceMaps[0]['w'] ?? 0) + (xPadding * 2)
              : (faceMaps[0]['h'] ?? 0) + (yPadding * 2),
        );
      }

      final isEncoded = await img.encodeImageFile(newImagePath, faceCrop!);

      if (isEncoded) {
        return newImagePath;
      }
      Logger().e('FaceCropper: Error while encoding cropped image');
      return null;
    } catch (e, stackTrace) {
      Logger().e(e);
      Logger().e(stackTrace);
      return null;
    }
  }
}
