import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rahal/screens/detailsScreen.dart';
import 'package:rive/rive.dart';
import '../classes/card_class.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late RiveAnimationController _controller;
  String _photoUrl = '';
  Position? _currentPosition;
  List<cardClass> _nearestLocations = [];

  getCurrentState() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
    print('========================================================');
    print(position.latitude);
    print(position.longitude);
    await getData();
  }

  @override
  void initState() {
    getCurrentState();
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _photoUrl = userDoc['photoUrl'] ??
              'https://d2pas86kykpvmq.cloudfront.net/images/humans-3.0/ava-4.png';
        });
      }
    }
  }

  Future<void> getData() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Location').get();
    List<cardClass> cards = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return cardClass(
        name: data['Name'],
        coordinates: data['Loc_st'],
        image: data['Image'],
        discrebtion: data['Details'],
        videoURL: data['Vid_link'],
        modelURL: data['3D_link'],
        coordinate: data['Loc_geo'],
      );
    }).toList();
    calculateNearestLocations(cards);
  }

  void calculateNearestLocations(List<cardClass> cards) {
    if (_currentPosition == null) return;
    double userLat = _currentPosition!.latitude;
    double userLng = _currentPosition!.longitude;

    cards.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
        userLat,
        userLng,
        a.coordinate.latitude,
        a.coordinate.longitude,
      );
      double distanceB = Geolocator.distanceBetween(
        userLat,
        userLng,
        b.coordinate.latitude,
        b.coordinate.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      _nearestLocations = cards.take(2).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String defultImage = 'https://d2pas86kykpvmq.cloudfront.net/images/humans-3.0/ava-4.png';
    return Scaffold(
      backgroundColor: Color.fromRGBO(40, 40, 40, 100),
      body: Stack(
        children: [
          RiveAnimation.asset('assets/animations/exploreAnimation'),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 5.0, left: 2.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(_photoUrl != ''? _photoUrl:defultImage),
                radius: 80,
              ),
            ),
          ),
          for (int i = 0; i < _nearestLocations.length; i++)

            Positioned(
              right: i == 0 ? 30 : null,
              left: i == 1 ? 30 : null,
              top: i == 0 ? 50 : null,
              bottom: i == 1 ? 50 : null,
              child: Container(
                width: 170,
                // height: 190,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(10, 10, 10, 50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:Image.network(
                          _nearestLocations[i].image ,
                          // width: double.infinity,
                          height: 100,
                        )
                      ),
                      Text(
                        _nearestLocations[i].name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailsScreen(element: _nearestLocations[i]),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: AlignmentDirectional.center,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(255, 170, 4, 1),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                height: 40,
                                child: const Text(
                                  'Go To',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '${calculateDistance(_nearestLocations[i])} km',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String calculateDistance(cardClass location) {
    if (_currentPosition == null) return '';
    double userLat = _currentPosition!.latitude;
    double userLng = _currentPosition!.longitude;

    double distance = Geolocator.distanceBetween(
      userLat,
      userLng,
      location.coordinate.latitude,
      location.coordinate.longitude,
    );

    // Convert distance from meters to kilometers and round to 1 decimal place
    return (distance / 1000).toStringAsFixed(1);
  }
}
