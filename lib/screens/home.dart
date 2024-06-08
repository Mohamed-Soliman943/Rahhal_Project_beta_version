import 'package:flutter/material.dart';
import '../widgets/homeLayerOne.dart';
import '../widgets/homeLayerthree.dart';

class HomeScreen extends StatefulWidget {
  final String searchQuery;

  const HomeScreen({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> _stackChildren = [];

  @override
  void initState() {
    super.initState();
    _stackChildren = [
      HomeLayerOne(
        searchQuery: widget.searchQuery,
      ),
    ];
  }

  void _pushWidget() {
    setState(() {
      _stackChildren.add(
        HomeLayerThree(onClose: _popWidget),
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
    // Update HomeLayerOne when searchQuery changes
    if (_stackChildren.isNotEmpty && _stackChildren[0] is HomeLayerOne) {
      _stackChildren[0] = HomeLayerOne(
        searchQuery: widget.searchQuery,
      );
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(40, 40, 40, 100),
      body: Stack(
        children: _stackChildren,
      ),
      floatingActionButton: _stackChildren.length < 2
          ? SizedBox(
        width: 130,
        height: 130,
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: _pushWidget,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: Image.asset(('assets/images/RahhalChar.png'))),
        ),
      )
          : Container(),
    );
  }
}
