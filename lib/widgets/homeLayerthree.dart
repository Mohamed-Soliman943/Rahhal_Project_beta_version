import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rahal/widgets/presenter.dart';

class HomeLayerThree extends StatefulWidget {
  final VoidCallback onClose;

  const HomeLayerThree({Key? key, required this.onClose}) : super(key: key);

  @override
  State<HomeLayerThree> createState() => _HomeLayerThreeState();
}

class _HomeLayerThreeState extends State<HomeLayerThree> {
  String videoURL = '';
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchVideoURL();
  }

  Future<void> fetchVideoURL() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("virtual tour guide")
          .doc("rahhal info")
          .get();

      if (docSnapshot.exists) {
        setState(() {
          videoURL = docSnapshot.get('videoURL');
          isLoading = false;
          hasError = false;
          print('========================video==================: $videoURL');
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        print("===============Document does not exist.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("==========================================Error fetching video URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.black,
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (hasError)
              Center(child: Text('Error loading video. Please try again later.'))
            else
              Expanded(child: Presenter(videoURL: videoURL)),
            GestureDetector(
              onTap: widget.onClose, // Call the onClose callback function
              child: Container(
                alignment: AlignmentDirectional.center,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(100, 100, 100, 100),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                width: 150,
                height: 40,
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
