
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rahal/screens/nav_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rahal/screens/signup.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'onBoarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  bool showHome = false;
  late String _verify;
  Future<void> checkVerification() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection(
        'virtual tour guide').doc('rahhal info').get();
    if (doc.exists) {
      String verify = doc['verify'];
      setState(() {
        _verify = verify;
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkVerification();
    checkOnboardingStatus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 3),(){
      Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: _verify =='no'?showHome
                ?(
                (FirebaseAuth.instance.currentUser !=null && FirebaseAuth.instance.currentUser!.emailVerified)
                    ? NavigationScreen()
                    : LoginPage())
                : OnBoardingScreen()
                :showHome
                ?(
                (FirebaseAuth.instance.currentUser !=null )
                    ? NavigationScreen()
                    : LoginPage())
                : OnBoardingScreen(),

            // SignUpPage(),

            // NavigationScreen(),
          // PageTransition(
          //     child:NavigationScreen() ,
          //     type: PageTransitionType.rightToLeft)
      ));
    });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    super.dispose();
  }
  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showHome = prefs.getBool('showHome') ?? false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color.fromRGBO(40, 40, 40, 100),
        body: Center(
          child: RiveAnimation.asset('assets/animations/rahhal.riv',
          ),


        ),
    );
  }
}
