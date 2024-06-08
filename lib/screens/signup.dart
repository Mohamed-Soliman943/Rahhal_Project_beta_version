import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rahal/screens/verification.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../component/my_button.dart';
import '../component/my_textfield.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // final firstnameController = TextEditingController();
  // final lastnameController = TextEditingController();
  final phoneController = TextEditingController();
  // final dobController = TextEditingController();
  final countryCodeController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  File? _image;

  // list of country codes with flags
  final List<Map<String, String>> _countryCodes = [
    {'code': '+20', 'name': 'Egypt', 'flag': 'https://www.countryflags.com/wp-content/uploads/egypt-flag-png-large.png'},
    {'code': '+966', 'name': 'KSA', 'flag': 'https://www.countryflags.com/wp-content/uploads/saudi-arabia-flag-png-large.png'},
    {'code': '+1', 'name': 'USA', 'flag': 'https://www.countryflags.com/wp-content/uploads/united-states-of-america-flag-png-large.png'},
    {'code': '+971', 'name': 'UAE', 'flag': 'https://www.countryflags.com/wp-content/uploads/united-arab-emirates-flag-png-large.png'},
    {'code': '+86', 'name': 'China', 'flag': 'https://www.countryflags.com/wp-content/uploads/china-flag-png-large.png'},
    {'code': '+33', 'name': 'France', 'flag': 'https://www.countryflags.com/wp-content/uploads/france-flag-png-large.png'},
    {'code': '+44', 'name': 'England', 'flag': 'https://www.countryflags.com/wp-content/uploads/united-kingdom-flag-png-large.png'},
    {'code': '+34', 'name': 'Spain', 'flag': 'https://www.countryflags.com/wp-content/uploads/spain-flag-png-large.png'},
    {'code': '+45', 'name': 'Denmark', 'flag': 'https://www.countryflags.com/wp-content/uploads/denmark-flag-png-large.png'},
    {'code': '+55', 'name': 'Brazil', 'flag': 'https://www.countryflags.com/wp-content/uploads/brazil-flag-png-large.png'},
    {'code': '+91', 'name': 'India', 'flag': 'https://www.countryflags.com/wp-content/uploads/india-flag-png-large.png'},
    {'code': '+1', 'name': 'Canada', 'flag': 'https://www.countryflags.com/wp-content/uploads/canada-flag-png-large.png'},
    {'code': '+49', 'name': 'Germany', 'flag': 'https://www.countryflags.com/wp-content/uploads/germany-flag-png-large.png'},
    {'code': '+81', 'name': 'Japan', 'flag': 'https://www.countryflags.com/wp-content/uploads/japan-flag-png-large.png'},
    {'code': '+39', 'name': 'Italy', 'flag': 'https://www.countryflags.com/wp-content/uploads/italy-flag-png-large.png'},
    {'code': '+7', 'name': 'Russia', 'flag': 'https://www.countryflags.com/wp-content/uploads/russia-flag-png-large.png'},
    {'code': '+27', 'name': 'South Africa', 'flag': 'https://www.countryflags.com/wp-content/uploads/south-africa-flag-png-large.png'},
  ];

  // GlobalKey for form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // method to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // method to upload image to Firebase Storage and get the download URL
  Future<String> _uploadImage(File image) async {
    String fileName = Uuid().v4(); // Generate a unique file name
    Reference storageReference = FirebaseStorage.instance.ref().child('user_images/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot storageSnapshot = await uploadTask;
    return await storageSnapshot.ref.getDownloadURL();
  }

  // sign up user method
  void SignUserUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user with email and password
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Get the current user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String? photoURL;
          if (_image != null) {
            photoURL = await _uploadImage(_image!);
          }

          // Update user profile
          await user.updateProfile(
            displayName: usernameController.text,
            photoURL: photoURL,
          );

          // Save additional information in Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'username': usernameController.text,
            'email': emailController.text,
            'photoURL': photoURL ?? '' ,
            'phoneNumber': '${countryCodeController.text}${phoneController.text}',
            'firstname': 'first name',
            'lastname': 'last name',
            'dob': '1/1/2024',
          });

          // Navigate to the next screen
          FirebaseAuth.instance.currentUser!.sendEmailVerification();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerificationPage(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(40, 40, 40, 100),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Padding(
                    padding: const EdgeInsets.only(top: 45.0, bottom: 15.0, right: 20.0, left: 20.0),
                    child: Image.asset('assets/images/logo2.png',),
                  ),
                  // username and image picker in one row
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  // Row(
                  //   children: [
                  //
                  //     Padding(
                  //       padding: const EdgeInsets.only(right: 0, left: 5.0),
                  //       child: GestureDetector(
                  //         onTap: _pickImage,
                  //         child: CircleAvatar(
                  //           radius: 30,
                  //           backgroundColor: Colors.grey[300],
                  //           backgroundImage: _image != null ? FileImage(_image!) : null,
                  //           child: _image == null
                  //               ? Icon(
                  //             Icons.camera_alt,
                  //             color: Colors.grey[800],
                  //             size: 30,
                  //           )
                  //               : null,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 5),
                  // email textfield
                  MyTextField(
                    hintText: 'Email',
                    obscureText: false,
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  // firstname textfield
                  // MyTextField(
                  //   hintText: 'Firstname',
                  //   obscureText: false,
                  //   controller: firstnameController,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter your firstname';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // const SizedBox(height: 5),
                  // // lastname textfield
                  // MyTextField(
                  //   hintText: 'Lastname',
                  //   obscureText: false,
                  //   controller: lastnameController,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter your lastname';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // const SizedBox(height: 5),
                  // dob textfield
                  // MyTextField(
                  //   hintText: 'Date of Birth',
                  //   obscureText: false,
                  //   controller: dobController,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter your date of birth';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // const SizedBox(height: 5),
                  // phone number and country code
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: DropdownButtonFormField<Map<String, String>>(
                          items: _countryCodes
                              .map((code) => DropdownMenuItem<Map<String, String>>(
                            value: code,
                            child: Row(
                              children: [
                                Image.network(
                                  code['flag']!,
                                  width: 20,
                                  height: 15,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(width: 5),
                                Text(code['code']!),
                              ],
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              countryCodeController.text = value!['code']!;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Code',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: MyTextField(
                          hintText: 'Phone Number',
                          obscureText: false,
                          controller: phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  // signup button
                  MyButton(
                    text: 'Sign Up',
                    onTap: SignUserUp,
                  ),
                  const SizedBox(height: 5),
                  // Or sign up with
                  Row(
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
                          'Or Sign Up with',
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
                  // const SizedBox(height: 10),
                  // // Google sign up button
                  // SingleChildScrollView(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: Expanded(
                  //           child: Container(
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(10.0),
                  //               border: Border.all(color: Colors.black),
                  //             ),
                  //             height: 50,
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   Image.network(
                  //                     'https://p7.hiclipart.com/preview/543/934/536/google-logo-g-suite-google-thumbnail.jpg',
                  //                     height: 25,
                  //                     width: 25,
                  //                   ),
                  //                   SizedBox(width: 5.0,),
                  //                   Text(
                  //                     'Google',
                  //                     style: TextStyle(
                  //                       fontSize: 15,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(width: 3.0,),
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: Expanded(
                  //           child: Container(
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(10.0),
                  //               border: Border.all(color: Colors.black),
                  //             ),
                  //             height: 50,
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   Image.asset(
                  //                     'assets/images/facebook.png',
                  //                     height: 30,
                  //                     width: 30,
                  //                   ),
                  //                   SizedBox(width: 5.0,),
                  //                   Text(
                  //                     'Facebook',
                  //                     style: TextStyle(
                  //                       fontSize: 15,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(width: 3.0,),
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: Expanded(
                  //           child: Container(
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(10.0),
                  //               border: Border.all(color: Colors.black),
                  //             ),
                  //             height: 50,
                  //             child: Padding(
                  //               padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   Padding(
                  //                     padding: const EdgeInsets.only(bottom: 3.0),
                  //                     child: Image.network(
                  //                       'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/814px-Apple_logo_black.svg.png',
                  //                     ),
                  //                   ),
                  //                   SizedBox(width: 5.0,),
                  //                   Text(
                  //                     'Apple',
                  //                     style: TextStyle(
                  //                       fontSize: 15,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 8.0),
                  // Terms and conditions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'By signing up you agree to our ',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Terms and Conditions ',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 170, 4, 10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'and',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 170, 4, 10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // already have an account log in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Text(
                          'Log In',
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
      ),
    );
  }
}
