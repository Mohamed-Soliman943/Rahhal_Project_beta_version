import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget{
  final String imagePath;
  final String text;
  const SquareTile({
    super.key,
    required this.imagePath, required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white38,
      ),
      child: Row(
        children: [
          Image.asset(imagePath,
            height:44 ,
          ),
          Text('Google'),
        ],
      ),
    );
  }
}