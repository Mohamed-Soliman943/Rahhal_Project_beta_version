import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../component/profilescreen_textfield.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _image;
  String? _photoUrl;
  final defaultImageUrl = 'https://d2pas86kykpvmq.cloudfront.net/images/humans-3.0/ava-4.png';

  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final countryController = TextEditingController();
  final genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          usernameController.text = userDoc['username'] ?? '';
          firstNameController.text = userDoc['firstName'] ?? '';
          lastNameController.text = userDoc['lastName'] ?? '';
          phoneNumberController.text = userDoc['phoneNumber'] ?? '';
          dateOfBirthController.text = userDoc['dateOfBirth'] ?? '';
          countryController.text = userDoc['country'] ?? '';
          genderController.text = userDoc['gender'] ?? '';
          _photoUrl = userDoc['photoUrl'] ?? defaultImageUrl;
        });
      }
    }
  }

  Future<void> selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    if (img != null) {
      String photoUrl = await uploadImageToStorage(img);
      setState(() {
        _image = img;
        _photoUrl = photoUrl;
      });
    }
  }

  Future<String> uploadImageToStorage(Uint8List image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profilePics')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(const Uuid().v1());
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<Uint8List> pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    XFile? _file = await _picker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    throw Exception('No image selected');
  }

  Future<void> saveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': usernameController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phoneNumber': phoneNumberController.text,
        'dateOfBirth': dateOfBirthController.text,
        'country': countryController.text,
        'gender': genderController.text,
        'photoUrl': _photoUrl,
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateOfBirthController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(40, 40, 40, 100),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orangeAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await saveUserData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _image != null
                          ? MemoryImage(_image!) as ImageProvider
                          : NetworkImage(_photoUrl ?? defaultImageUrl),
                    ),
                    IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                buildProfileField('Username', 'rahal', usernameController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: buildProfileField('First Name', 'First Name', firstNameController)),
                    Expanded(child: buildProfileField('Last Name', 'Last Name', lastNameController)),
                  ],
                ),
                const SizedBox(height: 10),
                buildProfileField('Phone Number', 'Phone Number', phoneNumberController),
                const SizedBox(height: 10),
                buildProfileField('Date of Birth', '12/03/2001', dateOfBirthController, onTap: () {
                  _selectDate(context);
                }),
                const SizedBox(height: 10),
                buildProfileField('Gender', 'Gender', genderController),
                const SizedBox(height: 10),
                buildProfileField('Country', 'Country', countryController),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, String hintText, TextEditingController controller, {bool readOnly = false, Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.edit, color: Colors.orangeAccent),
            ),
            style: TextStyle(color: Colors.white),
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
