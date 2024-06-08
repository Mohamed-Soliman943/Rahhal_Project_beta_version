import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rahal/screens/qrScan.dart';
import 'package:rahal/screens/scanningScreen.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import '../classes/card_class.dart';
import 'detailsScreen.dart';
import 'exploreScreen.dart';
import 'home.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int selectedIndex = 0;
  late PageController pageController;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final defaultImageUrl = 'https://d2pas86kykpvmq.cloudfront.net/images/humans-3.0/ava-4.png';
  String? _photoUrl;
  String? _appBarIconUrl;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
    loadUserData();
    checkVirtualTourGuideStatus();
    startLocationUpdates();
    fetchAppBarIcon();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _photoUrl = userDoc['photoUrl'] ?? defaultImageUrl;
        });
      }
    }
  }

  Future<void> checkVirtualTourGuideStatus() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('virtual tour guide').doc('rahhal info').get();
    if (doc.exists) {
      String status = doc['status'];
      String message = doc['message'];
      if (status != 'active') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Information'),
              content: Text(message),
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
  }

  Future<void> fetchAppBarIcon() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('virtual tour guide').doc('rahhal info').get();
    if (doc.exists) {
      String pal = doc['pal'];
      if (pal == 'yes') {
        setState(() {
          _appBarIconUrl = doc['icon'];
        });
      }
    }
  }

  Future<void> startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: LocationAccuracy.high)).listen((Position position) async {
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Location').get();
      for (var doc in snapshot.docs) {
        GeoPoint locGeo = doc['Loc_geo'];
        double distanceInMeters = Geolocator.distanceBetween(
          userLatitude,
          userLongitude,
          locGeo.latitude,
          locGeo.longitude,
        );

        if (distanceInMeters < 100) {
          cardClass locationCard = cardClass(
            name: doc['Name'],
            coordinates: doc['coordinates'],
            image: doc['Image'],
            discrebtion: doc['Details'],
            videoURL: doc['Vid_link'],
            modelURL: doc['3D_link'],
            coordinate: doc['Loc_geo'],
          );

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('You have arrived'),
                content: Text('You have arrived at ${locationCard.name}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(element: locationCard,),
                        ),
                      );
                    },
                    child: Text('Go to'),
                  ),
                ],
              );
            },
          );
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(_isSearching ? Icons.arrow_back : Icons.search_outlined),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _isSearching = false;
                _searchController.clear();
                _searchQuery = '';
              } else {
                _isSearching = true;
              }
            });
          },
          color: Colors.white,
        ),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white, fontSize: 20.0),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _appBarIconUrl != null
                ? Image.network(_appBarIconUrl!, width: 30, height: 30)
                : Image.asset('assets/images/horas.png', width: 30, height: 30),
            const Text(
              'R A H H A L',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'raleway',
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Color.fromRGBO(40, 40, 40, 10),
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white,
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.settings, color: Color.fromRGBO(255, 170, 4, 10)),
                          title: Text('Settings', style: TextStyle(color: Color.fromRGBO(255, 170, 4, 10))),
                          onTap: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.logout, color: Color.fromRGBO(255, 170, 4, 10)),
                          title: Text('Sign Out', style: TextStyle(color: Color.fromRGBO(255, 170, 4, 10))),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(_photoUrl ?? defaultImageUrl),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            HomeScreen(searchQuery: _searchQuery),
            ScanScreen(),
            QrScan(),
            ExploreScreen(),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(40, 40, 40, 100),
      bottomNavigationBar: WaterDropNavBar(
        waterDropColor: const Color.fromRGBO(255, 170, 4, 10),
        inactiveIconColor: Colors.white,
        iconSize: 30,
        bottomPadding: 5.0,
        backgroundColor: Colors.transparent,
        onItemSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
          pageController.animateToPage(selectedIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad);
        },
        selectedIndex: selectedIndex,
        barItems: <BarItem>[
          BarItem(
            filledIcon: Icons.home,
            outlinedIcon: Icons.home_outlined,
          ),
          BarItem(
            filledIcon: Icons.camera_alt,
            outlinedIcon: Icons.camera_alt_outlined,
          ),
          BarItem(
            filledIcon: Icons.qr_code,
            outlinedIcon: Icons.qr_code_outlined,
          ),
          BarItem(
            filledIcon: Icons.explore,
            outlinedIcon: Icons.explore_outlined,
          ),
        ],
      ),
    );
  }
}
