import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/card_class.dart';
import 'Card.dart';

class CardList extends StatefulWidget {
  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  late List<cardClass> data = []; // Initialize data to an empty list

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection("PYRAMIDES").get();
    print(querySnapshot);
    List<cardClass> cards = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return cardClass(
        name: data['Name'],
        coordinates: data['Location'],
        image: data['Image'],
      );
    }).toList();

    setState(() {
      data = cards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return CardWidget(
          element: data[index],
          onTap: () {},
        );
      },
    );
  }
}
