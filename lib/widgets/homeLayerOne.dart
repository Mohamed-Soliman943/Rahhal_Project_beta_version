import 'package:flutter/material.dart';
import 'CardList.dart';

class HomeLayerOne extends StatelessWidget {
  final String searchQuery;

  HomeLayerOne({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'Explore Rahhal',
            style: TextStyle(
              color: Color.fromRGBO(255, 170, 4, 10),
              fontSize: 30,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'Suggestions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
        CardList(searchQuery: searchQuery),
      ],
    );
  }
}
