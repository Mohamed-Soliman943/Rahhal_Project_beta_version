import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

import '../classes/card_class.dart';
import '../widgets/AfterDetection.dart';

List<CameraDescription> cameras = [];

class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  State<QrScan> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  String? _barcode;
  List<Widget> _stackChildren = [];
  cardClass? cardData;
  late MobileScannerController _mobileScannerController;

  @override
  void initState() {
    super.initState();
    _mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _mobileScannerController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          MobileScanner(
            controller: _mobileScannerController,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              final Uint8List? image = capture.image;

              for (final barcode in barcodes) {
                print('Barcode found! ${barcode.rawValue}');
                if (barcode.rawValue != null) {
                  setState(() {
                    _barcode = barcode.rawValue;
                  });

                  await fetchAndSaveDocumentData(_barcode!);
                  if (cardData != null) {
                    setState(() {
                      _stackChildren.add(
                        AfterDetection(
                          onClose: _handleAfterDetectionClose,
                          element: cardData!,
                        ),
                      );
                    });
                  }
                }
              }

              if (image != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        barcodes.first.rawValue ?? "",
                      ),
                      content: Image(
                        image: MemoryImage(image),
                      ),
                    );
                  },
                );
              }
            },
          ),
          QRScannerOverlay(
            overlayColor: Colors.black.withOpacity(0.5),
          ),
          ..._stackChildren,
        ],
      ),
    );
  }

  void _handleAfterDetectionClose() {
    setState(() {
      if (_stackChildren.isNotEmpty) {
        _stackChildren.removeLast();
      }
    });
  }
}
