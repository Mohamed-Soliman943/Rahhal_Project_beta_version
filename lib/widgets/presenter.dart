import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class Presenter extends StatefulWidget {
  const Presenter({Key? key,}) ;
  // final String selector;
  @override
  State<Presenter> createState() => _PresenterState();
}

class _PresenterState extends State<Presenter> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isVideoInitialized = false;
  bool hasError = false;
  bool timeoutOccurred = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.asset('assets/videos/info.mp4');
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 9 / 16,
      zoomAndPan: true,
      allowFullScreen: false,

    );

    videoPlayerController.initialize().then((_) {
      setState(() {
        isVideoInitialized = true;
      });
    });

    videoPlayerController.addListener(() {
      if (videoPlayerController.value.hasError) {
        setState(() {
          hasError = true;
        });
      }
    });

    // Set up a timeout mechanism
    Future.delayed(Duration(seconds: 5), () {
      if (!isVideoInitialized) {
        setState(() {
          timeoutOccurred = true;
        });
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isVideoInitialized && !timeoutOccurred) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (timeoutOccurred || hasError) {
      return Center(
        child: Container(
          width: double.infinity,
          height: 80,
          color: Colors.red,
          child: Center(
            child: Text(
              timeoutOccurred ? 'Loading took too long!' : 'Error loading Rahhal!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Center(
          // widthFactor: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color.fromRGBO(100, 100, 100, 80),
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: 3.0,
                      blurRadius: 7.0,
                      color: Color.fromRGBO(60, 60, 60, 80),
                    ),
                  ],
                ),
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Chewie(
                    controller: chewieController,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
