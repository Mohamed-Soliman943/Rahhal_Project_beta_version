import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rahal/widgets/AfterDetection.dart';
import 'package:tflite_v2/tflite_v2.dart';

import '../classes/card_class.dart';

class CameraAiDetectionScreen extends StatefulWidget {
  const CameraAiDetectionScreen({Key? key});

  @override
  _CameraAiDetectionScreenState createState() => _CameraAiDetectionScreenState();
}

class _CameraAiDetectionScreenState extends State<CameraAiDetectionScreen> {
  List<Widget> _stackChildren = [];
  CameraController? _controller; // Changed to nullable
  XFile? _savedImage;
  bool _isProcessing = false;
  String? _result;
  cardClass? cardData;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    loadModel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false, // Ensure audio is disabled if not needed

      );
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off); // Explicitly disable flash
      setState(() {}); // Update the state to reflect the initialized camera
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/tflite/rahhal_model.tflite',
        labels: 'assets/tflite/labels.txt',
      );
      print('====================================Model loaded successfully');
    } catch (e) {
      print('=========================================Error loading model: $e');
    }
  }

  Future<void> _captureAndProcessImage() async {
    setState(() {
      _isProcessing = true;
    });
    final XFile imageFile = await _controller!.takePicture();
    setState(() {
      _savedImage = imageFile;
    });

    if (_savedImage != null) {
      final result = await _runInference(_savedImage!.path);
      setState(() {
        _result = result;
        _isProcessing = false;
        print('==============================RESULT================================== : '+result);
      });

      if (_result != null) {
        await fetchAndSaveDocumentData(_result!);
        setState(() {
          if (cardData != null) {
            _stackChildren.add(
              // Text(_result!),
              AfterDetection(
                onClose: _handleAfterDetectionClose,
                element: cardData!,
              ),
            );
          }
        });
      }
    }
  }

  Future<String> _runInference(String imagePath) async {
    final List<dynamic>? output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1, // Specify the number of results you want to retrieve
    );

    final String result = output != null ? output[0]['label'] : 'No result';

    return result;
  }

  void _handleAfterDetectionClose() {
    setState(() {
      if (_stackChildren.isNotEmpty) {
        _stackChildren.removeLast();
      }
    });
  }

  Future<cardClass?> getDocumentData(String documentId) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection("all_monuments").doc(documentId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      return cardClass(
        name: data['Name'],
        coordinates: data['Loc_st'],
        image: data['Image'],
        discrebtion: data['Details'],
        videoURL: data['Vid_link'],
        modelURL: data['3D_link'], coordinate: data['Loc_geo'],
      );
    } else {
      return null; // Document does not exist
    }
  }

  Future<void> fetchAndSaveDocumentData(String documentId) async {
    cardData = await getDocumentData(documentId);

    if (cardData != null) {
      // Use cardData here
      print("Name: ${cardData!.name}");
      print("Coordinates: ${cardData!.coordinates}");
      print("Image: ${cardData!.image}");
      print("Discrebtion: ${cardData!.discrebtion}");
      print("Video URL: ${cardData!.videoURL}");
      print("Model URL: ${cardData!.modelURL}");
    } else {
      print("Document does not exist.");
    }
    setState(() {}); // Update the state with new card data
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: _cameraPreviewWidget()),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black.withOpacity(0.5), // Dark background
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 40,
                  onPressed: _isProcessing ? null : _captureAndProcessImage,
                  icon: _isProcessing
                      ? Icon(Icons.camera_alt_outlined)
                      : Icon(Icons.camera_alt),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        ..._stackChildren,
      ],
    );
  }

  Widget _cameraPreviewWidget() {
    return CameraPreview(_controller!); // Accessing with '!' because it's checked for null before
  }
}
