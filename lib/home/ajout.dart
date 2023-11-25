import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/home/tflite.dart';

import 'activities_screen.dart';

class Ajout extends StatefulWidget {
  final VoidCallback? onRefresh;

  const Ajout({Key? key, this.onRefresh}) : super(key: key);

  @override
  _AjoutState createState() => _AjoutState();
}

class _AjoutState extends State<Ajout> {
  bool loading = true;
  late File _image = File('');
  late String _categorie = '';

  TextEditingController titreController = TextEditingController();
  TextEditingController lieuController = TextEditingController();
  TextEditingController minPersonController = TextEditingController();
  TextEditingController prixController = TextEditingController();

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout'),
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
                      margin: const EdgeInsets.only(top: 16),
                      child: Text(_categorie),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
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
                decoration: const InputDecoration(labelText: 'titre'),
              ),
              TextField(
                controller: lieuController,
                decoration: const InputDecoration(labelText: 'lieu'),
              ),
              TextField(
                controller: minPersonController,
                decoration:
                const InputDecoration(labelText: 'Minimum de Personne'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: prixController,
                decoration: const InputDecoration(labelText: 'prix'),
                keyboardType: TextInputType.number,
              ),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  _saveDataToDatabase();
                },
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
            Icons.add,
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
                Navigator.pop(context);
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
          });
        },
      ),
    );
  }


  Future<void> _pickImage(ImageSource source) async {
    var image = await ImagePicker().pickImage(source: source, maxWidth: 1800, maxHeight: 1800,);
    if (image == null) {
      return;
    } else {
      setState(() {
        _image = File(image.path);
      });
      List<dynamic>? output = await TFliteModel(_image).detectImage();
      setState(() {
        if (output?[0]['confidence']>0.8) _categorie = output![0]['label'].toString().substring(2);
        else _categorie = 'autre';
      });
    }
  }


  void _saveDataToDatabase() async {
    String titre = titreController.text;
    String lieu = lieuController.text;
    int minPerson = int.tryParse(minPersonController.text) ?? 0;
    double prix = double.tryParse(prixController.text) ?? 0.0;

    //if (titre.isEmpty || lieu.isEmpty || minPerson <= 0 || prix <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs et sélectionner une image.'),
          backgroundColor: Colors.red,
        ),
      );
      //return;
    //}

    // Upload image to Firebase Storage
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$imageName.jpg');

      await ref.putFile(_image);
      String imageUrl = await ref.getDownloadURL();

      // Save data to Firebase Firestore
      await FirebaseFirestore.instance.collection('Activities').add({
        'titre': titre,
        'lieu': lieu,
        'minPerson': minPerson,
        'prix': prix,
        'imageUrl': imageUrl,
        'categorie' : _categorie
      });

      List<dynamic>? output = await TFliteModel(_image).detectImage();
      if (output != null) {
        print('Output: ${output[0]['confidence']}');
      } else {
        print('Error during inference or output is null.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données enregistrées avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onRefresh?.call();
    } catch (error) {
      print('Error saving data to Firestore and uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


}
