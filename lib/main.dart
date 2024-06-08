import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rahal/firebase_options.dart';
import 'package:rahal/screens/forgetPassword.dart';
import 'package:rahal/screens/login.dart';
import 'package:rahal/screens/nav_screen.dart';
import 'package:rahal/screens/signup.dart';
import 'package:rahal/screens/splashScreen.dart';
import 'package:rahal/screens/profile_screen.dart';
import 'package:rahal/screens/verification.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('==================================================User is currently signed out!');
      } else {
        print('=======================================================User is signed in!');
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // fontFamily:'raleway',
      ),

      title: 'Rahhal',
      debugShowCheckedModeBanner: false,
      home:
      const SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/navScreen': (context) => NavigationScreen(),
        '/settings':(context) => ProfileScreen(),
        // '/verification':(context) => VerificationPage(),
        '/forgetPassword':(context) => ForgetPassword(),

      },
    );
  }
}
