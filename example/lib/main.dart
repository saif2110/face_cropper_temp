import 'dart:developer';
import 'dart:io';

import 'package:face_cropper/face_cropper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Cropper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Face cropper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _imagePath;
  String? _croppedImagePath;
  bool isLoading = false;
  FaceCropper faceCropper = FaceCropper();

  void _pickImage() async {
    try {
      final pickedImagePath =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImagePath != null) {
        setState(() {
          _imagePath = pickedImagePath.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "No Image selected",
            style: TextStyle(color: Colors.white),
          ),
        ));
      }
    } catch (error, stackTrace) {
      log(error.toString());
      log(stackTrace.toString());
    }
  }

  void _clearAll() {
    setState(() {
      _imagePath = null;
      _croppedImagePath = null;
    });
  }

  void _cropFace() async {
    setState(() {
      isLoading = true;
    });
    if (_imagePath == null || _imagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Error occured while detecting face",
          style: TextStyle(color: Colors.white),
        ),
      ));
      setState(() {
        isLoading = false;
      });
      return;
    }
    final croppedImage = await faceCropper.detectFacesAndCrop(_imagePath!);
    if (croppedImage != null) {
      setState(() {
        _croppedImagePath = croppedImage;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              isLoading
                  ? const SizedBox(
                      height: 400,
                      width: 400,
                      child: Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_imagePath != null) {
                                return;
                              }
                              _pickImage();
                            },
                            borderRadius: BorderRadius.circular(10),
                            splashColor: Colors.blue,
                            child: Container(
                              height: 400,
                              width: 400,
                              decoration: BoxDecoration(
                                  color: _imagePath != null
                                      ? Colors.transparent
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10)),
                              child: _imagePath == null
                                  ? const Icon(Icons.upload)
                                  : Image.file(
                                      File.fromUri(
                                        Uri.parse(_imagePath!),
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                        if (_croppedImagePath != null)
                          const SizedBox(
                            width: 10,
                          ),
                        if (_croppedImagePath != null)
                          Expanded(
                            child: Container(
                              height: 400,
                              width: 400,
                              decoration: BoxDecoration(
                                  color: _imagePath != null
                                      ? Colors.transparent
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10)),
                              child: _imagePath == null
                                  ? const Icon(Icons.upload)
                                  : Image.file(
                                      File.fromUri(
                                        Uri.parse(_croppedImagePath!),
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                      ],
                    ),
              const SizedBox(
                height: 30,
              ),
              if (_imagePath != null) ...[
                if (_croppedImagePath == null)
                  ElevatedButton(
                    onPressed: _cropFace,
                    child: const Text('Face Crop'),
                  ),
                ElevatedButton(
                  onPressed: _clearAll,
                  child: const Text('Clear'),
                ),
              ],
              if (_imagePath == null)
                Text(
                  'Pick Image',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
            ],
          ),
        ),
      ),
    );
  }
}
