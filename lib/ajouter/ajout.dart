import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../home/activities_screen.dart';
import '../home/tflite.dart';
import '../profil/profil.dart';

class Ajout extends StatefulWidget {
  final Function? onRefresh;

  const Ajout({Key? key, this.onRefresh}) : super(key: key);

  @override
  AjoutState createState() => AjoutState();
}

class AjoutState extends State<Ajout> {
  bool loading = true;
  late File _image = File('');
  late String _categorie = '';

  TextEditingController titreController = TextEditingController();
  TextEditingController lieuController = TextEditingController();
  TextEditingController minPersonController = TextEditingController();
  TextEditingController prixController = TextEditingController();

  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajout',
          style: TextStyle(
              color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue, // Change the app bar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _image.path.isNotEmpty
                  ? Container(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Image.file(
                        _image,
                        height: 200,
                        width: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              )
                  : Container(),
              TextField(
                controller: titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lieuController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minPersonController,
                decoration: const InputDecoration(
                  labelText: 'Minimum de Personne',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: prixController,
                decoration: const InputDecoration(
                  labelText: 'Prix',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _categorie),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Categorie',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  )
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveDataToDatabase();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // text color
                ),
                child: const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: PopupMenuButton(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: const Icon(
            Icons.image,
            size: 30,
            color: Colors.white,
          ),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivitiesScreen(onRefresh: () {}),
                ),
              );
            }
            if (_currentIndex == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Profil(),
                ),
              );
            }
          });
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    var image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (image == null) {
      return;
    } else {
      setState(() {
        _image = File(image.path);
      });
      List<dynamic>? output = await TFliteModel(_image).detectImage();
      setState(() {
        if (output?[0]['confidence'] > 0.8) {
          _categorie = output![0]['label'].toString().substring(2);
        } else {
          _categorie = 'autre';
        }
      });
    }
  }


void _saveDataToDatabase() async {
    String titre = titreController.text;
    String lieu = lieuController.text;
    int minPerson = int.tryParse(minPersonController.text) ?? 0;
    double prix = double.tryParse(prixController.text) ?? 0.0;

    if (titre.isEmpty || lieu.isEmpty || minPerson <= 0 || prix <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs et sélectionner une image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$imageName.jpg');

      await ref.putFile(_image);
      String imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('Activities').add({
        'titre': titre,
        'lieu': lieu,
        'minPersonne': minPerson,
        'prix': prix,
        'imageUrl': imageUrl,
        'categorie' : _categorie
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données enregistrées avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      }
    }
    widget.onRefresh!();
  }


}
