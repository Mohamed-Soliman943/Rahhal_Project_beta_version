import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Set black color as the background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Check your Mail",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "We’ve sent a 6-digit confirmation code to yasminamaged@gmail.com. Make sure you enter the correct code.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Positioned(
            left: 69,
            top: 268,
            child: Image.asset(
              'assets/images/pana.png',
              width: 207.83,
              height: 179.14,
            ),
          ),
        ],
      ),
    );
  }
}