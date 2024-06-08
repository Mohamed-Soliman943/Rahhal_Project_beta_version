import 'package:flutter/material.dart';
import 'package:rahal/screens/qrScan.dart';


import 'cameraDetection.dart';
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {

    return CameraDetection();

  }
}
