import 'package:flutter/material.dart';

class ProfileScreenTextField extends StatelessWidget{
  final controller;
  final String hintText;
  final bool obscureText;

  const ProfileScreenTextField ({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          // border: OutlineInputBorder(
          //  borderRadius: BorderRadius.circular(6.0),
          //
          //   borderSide: BorderSide(color: Colors.yellow),
          // ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(255, 170, 4, 10) ),
            borderRadius: BorderRadius.circular(10),
          ),




          fillColor :Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey ),
        ),
      ),
    );
  }

}

