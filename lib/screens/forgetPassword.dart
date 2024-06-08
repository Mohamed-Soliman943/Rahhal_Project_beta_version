import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/my_button.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    InputDecoration _inputDecoration(String hintText) {
      return InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    Future<void> _showDialog(BuildContext context, String title, String content) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button to dismiss
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(content),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orangeAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Color.fromRGBO(40, 40, 40, 100),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100,),
            Text(
              'Reset your Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(255, 170, 4, 10),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Image.asset('assets/images/panal.png'),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextFormField(
                controller: emailController,
                decoration: _inputDecoration('Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MyButton(
                text: 'Reset Password',
                onTap: () async {
                  final email = emailController.text;
                  if (email.isEmpty) {
                    await _showDialog(
                        context, 'Error', 'Please enter your email');
                    return;
                  }
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    await _showDialog(
                        context, 'Success', 'Password reset email sent');
                  } on FirebaseAuthException catch (e) {
                    await _showDialog(
                        context, 'Error', e.message ?? 'An error occurred');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
