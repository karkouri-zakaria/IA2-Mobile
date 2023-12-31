import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String titre;
  final String lieu;
  final String prix;
  final String imageUrl;
  final String minPersonne;
  final String categorie;

  Activity({
    required this.titre,
    required this.lieu,
    required this.prix,
    required this.imageUrl,
    required this.minPersonne,
    required this.categorie
  });

  factory Activity.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Activity(
      titre: data['titre'].toString(),
      lieu: data['lieu'].toString(),
      prix: data['prix'].toString().toString(),
      imageUrl: data['imageUrl'].toString(),
      minPersonne: data['minPersonne'].toString(),
      categorie: data['categorie'].toString(),
    );
  }
}
