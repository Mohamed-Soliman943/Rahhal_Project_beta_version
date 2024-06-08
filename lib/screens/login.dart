import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rahal/screens/signup.dart';
import '../component/my_button.dart';
import '../component/my_textfield.dart';
import '../component/square_tile.dart';


class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late String _verify;
  bool _isObscure = true; // Track password visibility state
  String? _errorMessage; // Track error message
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkVerification();
  }

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
  void togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

      void logUserIn() async {
    if (_formKey.currentState!.validate() ) {
      setState(() {
        _errorMessage = null; // Clear previous error message
      });

      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if(_verify == 'no'){
          Navigator.of(context).pushReplacementNamed('/navScreen');
        }else{
          if(credential.user!.emailVerified){
            Navigator.of(context).pushReplacementNamed('/navScreen');
          }else{
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Information'),
                  content: Text('Check your email and verify your acount'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _errorMessage = 'No user found for that email.';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'Wrong password provided for that user.';
          } else {
            _errorMessage = 'The username or password is incorrect';
          }
        });
      }
    }
  }

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

  // Future signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       print("Google sign-in was canceled.");
  //       return null ;
  //     }
  //
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     // return await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  //     Navigator.of(context).pushNamedAndRemoveUntil('/navScreen', (route) => false);
  //   } catch (e) {
  //     print("=========================================================Error signing in with Google: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(40, 40, 40, 100),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Image.asset('assets/images/logo2.png'),
                ),
                // Email textfield
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
                const SizedBox(height: 10),
                // Password textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: _isObscure,
                    decoration: _inputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: togglePasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Forget password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pushNamed('/forgetPassword');
                        },
                        child: Text(
                          'Forget password?',
                          style: TextStyle(color: Color.fromRGBO(255, 170, 4, 10)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Login button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyButton(
                    text: 'Sign in',
                    onTap: logUserIn,
                  ),
                ),
                const SizedBox(height: 5),
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 5),
                // Or login with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.3,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or Log in with',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.3,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 10),
                // // Google sign in button
                // SingleChildScrollView(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       GestureDetector(
                //         onTap: () async{
                //           signInWithGoogle();                        //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                //         //   if (googleUser == null) {
                //         //     print("Google sign-in was canceled.");
                //         //     return null ;
                //         //   }
                //         //
                //         //   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
                //         //   final credential = GoogleAuthProvider.credential(
                //         //     accessToken: googleAuth.accessToken,
                //         //     idToken: googleAuth.idToken,
                //         //   );
                //         //   UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                //         //
                //         //   print(userCredential.user?.email);
                //         //   print(userCredential.user?.uid);
                //         //   print(userCredential.user?.emailVerified);
                //         //   print(userCredential.user?.photoURL);
                //         //   print(userCredential.user?.phoneNumber);
                //         //
                //         //
                //         //
                //         //   Navigator.of(context).pushNamedAndRemoveUntil('/navScreen', (route) => false);
                //         },
                //         child: Container(
                //           // width: double.infinity,
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(10.0),
                //             border: Border.all(color: Colors.black),
                //           ),
                //           height: 50,
                //           child: Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Image.network(
                //                   'https://p7.hiclipart.com/preview/543/934/536/google-logo-g-suite-google-thumbnail.jpg', height: 25, width: 25,),
                //                 SizedBox(width: 5.0,),
                //                 Text(
                //                   'Google',
                //                   style: TextStyle(
                //                     fontSize: 15,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       SizedBox(width: 3.0,),
                //       GestureDetector(
                //         onTap: () {},
                //         child: Container(
                //           // width: double.infinity,
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(10.0),
                //             border: Border.all(color: Colors.black),
                //           ),
                //           height: 50,
                //           child: Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Image.asset(
                //                   'assets/images/facebook.png', height: 30, width: 30,),
                //                 SizedBox(width: 5.0,),
                //                 Text(
                //                   'Facebook',
                //                   style: TextStyle(
                //                     fontSize: 15,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       SizedBox(width: 3.0,),
                //       GestureDetector(
                //         onTap: () {},
                //         child: Container(
                //           // width: double.infinity,
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(10.0),
                //             border: Border.all(color: Colors.black),
                //           ),
                //           height: 50,
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Padding(
                //                   padding: const EdgeInsets.only(bottom: 3.0),
                //                   child: Image.network(
                //                     'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/814px-Apple_logo_black.svg.png', height: 30, width: 30,),
                //                 ),
                //                 SizedBox(width: 3.0,),
                //                 Text(
                //                   'Apple',
                //                   style: TextStyle(
                //                     fontSize: 15,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 10),
                // Don't have an account sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don’t have an account ? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/signUp');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 170, 4, 10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
