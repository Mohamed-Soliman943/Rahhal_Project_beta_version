import 'package:flutter/material.dart';
import 'package:rahal/widgets/cameraAiDetection.dart';
import 'package:rahal/widgets/AfterDetection.dart';


class CameraDetection extends StatefulWidget {
  const CameraDetection({super.key});
  @override
  State<CameraDetection> createState() => _CameraDetectionState();
}

class _CameraDetectionState extends State<CameraDetection> {
  late String result;
  List<Widget> _stackChildren = [
    CameraAiDetectionScreen(),
  ];
  void _handleAfterDetectionClose() {
    Navigator.pop(context); // Pop the AfterDetection widget from the stack
  }

  void _pushWidget() {
    if (result != '') { // Check if result is not empty
      setState(() {
        // _stackChildren.add(
        //   AfterDetection(onClose: () {
        //     _popWidget();
        //   }, ),
        // );
      });
    }
  }

  void _popWidget() {
    setState(() {
      if (_stackChildren.isNotEmpty) {
        _stackChildren.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: _stackChildren,

      ),
    );
  }
}

class AfterDetection {
}
