import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../classes/card_class.dart';
import '../widgets/AfterDetection.dart';
import '../widgets/visualElements.dart';
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.element});
  final cardClass element;


  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List<Widget> _stackChildren = [];

  @override
  void initState() {
    super.initState();
    _stackChildren = [
      CustomScrollView(

        slivers: [

          // DetailsAppDar(
          //     link:element.image),
          SliverAppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark
            ),
            expandedHeight: 300,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            pinned: true,
            collapsedHeight: 100,
            flexibleSpace: ClipRRect(
              borderRadius: BorderRadius.circular(32.0),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: 340,
                    width: double.infinity,
                    decoration:  BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                widget.element.image),
                            fit: BoxFit.cover)),
                  ),
                  Positioned(
                    right: 20,
                    top: 50,
                    child:GestureDetector(
                      onTap: _pushWidget,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 170, 4, 1),
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        width: 125,
                        height: 40,
                        child: const Text('Use Rahhal',
                          style: TextStyle(
                            fontSize: 20,
                          ),),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // bottom: PreferredSize(
            //   preferredSize: const Size.fromHeight(0.0),
            //   child: Container(
            //   ),
            // ),


          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                top: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: AlignmentDirectional.center,
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color.fromRGBO(68, 68, 68, 70),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Text('Distance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                Text('__''km',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          alignment: AlignmentDirectional.center,
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color.fromRGBO(68, 68, 68, 70),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Text('Temp',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                Text('__C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          alignment: AlignmentDirectional.center,
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color.fromRGBO(68, 68, 68, 70),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Text('Rate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                Text('__',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    widget.element.name,
                    style: TextStyle(
                      fontSize: 35,
                      color: Color.fromRGBO(255, 170, 4, 10),
                    ),
                  ),
                  const Text('Description',
                    style:TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),),
                  Text(widget.element.discrebtion,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),

                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void _pushWidget() {
    setState(() {
      print('============================----------------------===================================gooooot link');
      print(widget.element.modelURL);
      _stackChildren.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 85.0),
          child: VisualElements(onClose: _popWidget, modelURL:widget.element.modelURL, videoURL: widget.element.videoURL,),
        ),
      );
    });
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
      backgroundColor: const Color.fromRGBO(40, 40, 40, 100),
      body: Stack(
        children: _stackChildren,
      ),
    );
  }
}
