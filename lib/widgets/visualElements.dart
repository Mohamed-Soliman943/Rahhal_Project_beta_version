
import 'package:flutter/material.dart';
import 'package:rahal/widgets/presenter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisualElements extends StatefulWidget {
  final VoidCallback onClose;
  final String modelURL;
  final String videoURL;
  const VisualElements({Key? key, required this.onClose, required this.modelURL, required this.videoURL}) ;

  @override
  _VisualElementsState createState() => _VisualElementsState();
}

class _VisualElementsState extends State<VisualElements> {
  CrossFadeState crossFadeState = CrossFadeState.showFirst;
  late WebView _webView;

  @override
  void initState() {
    super.initState();
    _webView = WebView(
      initialUrl: widget.modelURL,
      javascriptMode: JavascriptMode.unrestricted,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Presenter(videoURL: widget.videoURL,),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.all(20.0),
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
                child: ClipRRect(

                  borderRadius: BorderRadius.circular(25),
                  child: Visibility(
                    visible: crossFadeState == CrossFadeState.showSecond,
                    child: _webView,
                  ),
                ),
              ),
            ),
            crossFadeState: crossFadeState,
            duration: Duration(milliseconds: 500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    crossFadeState = CrossFadeState.showFirst;
                  });
                },
                child: Icon(
                  Icons.person,
                  size: 45,
                  color: Colors.white,
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(CircleBorder()),
                  padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromRGBO(100, 100, 100, 80)),
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (states) {
                      if (states.contains(MaterialState.pressed))
                        return Color.fromRGBO(255, 170, 4, 10);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  widget.onClose();
                },
                child: Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.white,
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(CircleBorder()),
                  padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromRGBO(100, 100, 100, 80)),
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (states) {
                      if (states.contains(MaterialState.pressed))
                        return Color.fromRGBO(255, 170, 4, 10);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    crossFadeState = CrossFadeState.showSecond;
                  });
                },
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.white,
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(CircleBorder()),
                  padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromRGBO(100, 100, 100, 80)),
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (states) {
                      if (states.contains(MaterialState.pressed))
                        return Color.fromRGBO(255, 170, 4, 10);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
