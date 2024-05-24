import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

import '../widgets/AfterDetection.dart';
List<CameraDescription> cameras = [];
class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  State<QrScan> createState() => _QrScanState();

}

class _QrScanState extends State<QrScan> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (capture){
              final List<Barcode> barcodes = capture.barcodes;
              final Uint8List? image = capture.image;
              for(final barcode in barcodes){
                print('Barcode found! ${barcode.rawValue}');
              }
              if( image != null){
                showDialog(context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          barcodes.first.rawValue ?? "",
                        ),
                        content: Image(
                          image: MemoryImage(image),
                        ),
                      );
                    }
                );
              }
            },
          ),
          QRScannerOverlay(
            overlayColor: Colors.black.withOpacity(0.5),


          ),
        ],
      ),

    );
  }
}
