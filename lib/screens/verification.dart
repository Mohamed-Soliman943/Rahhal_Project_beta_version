import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import '../component/my_button.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(40, 40, 40, 100),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Check your Mail', style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            )),
            Text(
              'We have sent you a verification email. Make sure to verify your email then login.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Center(child: Image.asset('assets/images/panal.png')),
            SizedBox(height: 30),
            MyButton(
              onTap: () {

                Navigator.of(context).pushReplacementNamed('/login');
              },
              text: 'Sign in',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No email sent? ',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.currentUser!.sendEmailVerification();
                    },
                    child: Text('Resend email',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 170, 4, 10),
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
