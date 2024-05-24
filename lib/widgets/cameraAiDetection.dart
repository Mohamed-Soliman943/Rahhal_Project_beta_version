import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:rahal/widgets/AfterDetection.dart';
import 'package:tflite_v2/tflite_v2.dart';

class CameraAiDetectionScreen extends StatefulWidget {
  const CameraAiDetectionScreen({Key? key});

  @override
  _CameraAiDetectionScreenState createState() => _CameraAiDetectionScreenState();
}

class _CameraAiDetectionScreenState extends State<CameraAiDetectionScreen> {
  CameraController? _controller; // Changed to nullable
  XFile? _savedImage;
  bool _isProcessing = false;
  String _result = '';

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
        ResolutionPreset.medium,
      );
      await _controller!.initialize();
      setState(() {}); // Update the state to reflect the initialized camera
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/tflite/rahhal_model7.tflite',
        labels: 'assets/tflite/labels.txt',
      );
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
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
      });
    }
  }

  Future<String> _runInference(String imagePath) async {
    // Load the image from disk
    final File imageFile = File(imagePath);

    // Convert the image to a format compatible with the model
    // You may need to resize, normalize, or preprocess the image here

    // Perform inference using TensorFlow Lite model
    final List<dynamic>? output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1, // Specify the number of results you want to retrieve
    );

    // Extract the result from the output
    final String result = output != null ? output[0]['label'] : 'No result';

    return result;
  }

  void _handleAfterDetectionClose() {
    // Navigator.pop(context); // Pop the AfterDetection widget from the stack
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      // Camera is not initialized yet, show a loading indicator
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
                      ? CircularProgressIndicator()
                      : Icon(Icons.camera_alt),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Text(
            _result,
            style: TextStyle(color: Colors.white),
          ),
        ),
        AfterDetection(onClose: () {
          _handleAfterDetectionClose();
        }),
      ],
    );
  }

  Widget _cameraPreviewWidget() {
    return CameraPreview(_controller!); // Accessing with '!' because it's checked for null before
  }
}
