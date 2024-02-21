
# Face Cropper

A flutter package that detects face in an image and gives cropped image of face.

## Preview

https://github.com/sagarRawatUK/face_cropper/assets/60035156/baef2481-831f-4f40-b930-056483dd6307

## Installation

First, add face_cropper as a dependency in your pubspec.yaml file.

```dart
face_cropper: ^<latest-version>
```

## iOS

• Minimum iOS Deployment Target: 13.0

Add a row to the ios/Runner/Info.plist:

• Add ```Privacy - Photo Library Usage Description``` and a usage description.

• If editing Info.plist as text, add:

```dart
<key>NSPhotoLibraryUsageDescription</key>
<string>your usage description here</string>
```

## Android

• Change the minimum Android sdk version to 21 (or higher) in your ```android/app/build.gradle``` file.

```dart
minSdkVersion 21
```

## Usage

• Add the import of the dependency

```dart
import 'package:face_cropper/face_cropper.dart';
```

• Create an instance of the ```FaceCropper``` class

```dart
FaceCropper faceCropper = FaceCropper();
```

• Use the async ```detectFacesAndCrop``` method to get a cropped image path

```dart
await faceCropper.detectFacesAndCrop(<path_to_image>);
```

• It returns a path of the cropped image

## Contributions

Contributions of any kind are more than welcome! Feel free to fork and improve face_cropper in any way you want, make a pull request, or open an issue.

## Support the Library

You can support the library by liking it on pub, staring in on Github and reporting any bugs you encounter
