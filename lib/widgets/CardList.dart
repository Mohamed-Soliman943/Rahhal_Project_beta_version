import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/card_class.dart';
import '../screens/detailsScreen.dart';
import 'Card.dart';

class CardList extends StatefulWidget {
  final String searchQuery;

  CardList({required this.searchQuery});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  late Future<List<cardClass>> dataFuture;

  @override
  void initState() {
    super.initState();
    dataFuture = getData();
  }

  Future<List<cardClass>> getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("all_monuments").get();
    List<cardClass> cards = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return cardClass(
        name: data['Name'],
        coordinates: data['Loc_st'],
        image: data['Image'],
        discrebtion: data['Details'],
        videoURL: data['Vid_link'],
        modelURL: data['3D_link'], coordinate: data['Loc_geo'],

      );
    }).toList();
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<cardClass>>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: CircularProgressIndicator(),
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        List<cardClass> filteredData = snapshot.data!.where((card) {
          return card.name.toLowerCase().contains(widget.searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            return CardWidget(
              element: filteredData[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return DetailsScreen(element: filteredData[index]);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
