import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

import 'face_painter.dart';

class FacePage extends StatefulWidget {
  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;

  _getImageAndDetectFaces() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      isLoading = true;
    });
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
        _loadImage(imageFile);
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
          (value) => setState(() {
        _image = value;
        isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (_imageFile == null)
          ? Center(child: Text('Aucune image sélectionné'))
          : Center(
        child: FittedBox(
          child: SizedBox(
            width: _image.width.toDouble(),
            height: _image.height.toDouble(),
            child: CustomPaint(
              painter: FacePainter(_image, _faces),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Sélect. Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}