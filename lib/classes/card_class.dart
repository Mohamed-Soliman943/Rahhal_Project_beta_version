
import 'package:cloud_firestore/cloud_firestore.dart';

class cardClass{
  final String name;
  final String coordinates;
  final  String image;
  final String discrebtion ;
  final String videoURL;
  final String modelURL;
  final GeoPoint coordinate;
  cardClass( {required this.name, required this.coordinates, required this.image, required this.discrebtion, required this.videoURL,required this.modelURL,required this.coordinate});

}