import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../BottomBar/bottom_bar.dart';
import '../ajouter/ajout.dart';
import '../auth/login.dart';
import '../home/activities_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: const Profil(),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        hintColor: Colors.purpleAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}

class Profil extends StatefulWidget {
  final Function? onRefresh;
  const Profil({Key? key, this.onRefresh}) : super(key: key);

  @override
  ProfilState createState() => ProfilState();
}

class ProfilState extends State<Profil> {
  bool isEditing = false;
  TextEditingController nameController = TextEditingController();
  String originalName = 'Username';
  late String imageUrl = '';

  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');

  final FirebaseStorage storage = FirebaseStorage.instance;
  late Reference imageReference;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                  if (isEditing) {
                    nameController.text = originalName;
                  }
                });
              },
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (isEditing) {
                  await updateUserInFirestore(nameController.text, imageUrl);
                }
                setState(() {
                  originalName = nameController.text;
                  isEditing = false;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (imageUrl.isNotEmpty)
                  InkWell(
                    onTap: () => _showImagePickerDialog(context),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl,
                        height: 400,
                        width: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _showImagePickerDialog(context),
                    child: Container(
                      height: 400,
                      width: 400,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                isEditing
                    ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.purple,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Enter your name',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.purple, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                )
                    : Text(
                  originalName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                            (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjust padding
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8), // Adjust spacing
                      Text(
                        'Log Out',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Adjust font size
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            if (_currentIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Ajout(),
                ),
              );
            }
          });
        },
      ),
    );
  }

  Future<void> _showImagePickerDialog(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                if (pickedFile != null) {
                  await uploadImageToStorage(pickedFile.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                if (pickedFile != null) {
                  await uploadImageToStorage(pickedFile.path);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserInFirestore(String name, String imageUrl) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        String userId = auth.currentUser!.uid;
        await usersCollection.doc(userId).set({
          'name': name,
          'imageUrl': imageUrl,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User name changed successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {}
    } catch (e) {
      return;
    }
  }

  Future<void> fetchUserData() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        String userId = auth.currentUser!.uid;
        final DocumentSnapshot snapshot = await usersCollection.doc(userId)
            .get();
        if (snapshot.exists) {
          setState(() {
            originalName = snapshot['name'];
            imageUrl = snapshot['imageUrl'];
          });
        }
      } else {}
    } catch (e) {
      return;
    }
  }

  Future<void> uploadImageToStorage(String imagePath) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    imageReference = storage.ref().child('user_images').child(
        '${auth.currentUser!.uid}.jpg');
    try {
      await imageReference.putFile(File(imagePath));
      String newImageUrl = await imageReference.getDownloadURL();
      setState(() {
        imageUrl = newImageUrl;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo changed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      return;
    }
  }

  Future<void> fetchImageFromStorage() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    imageReference = storage.ref().child('user_images').child(
        '${auth.currentUser!.uid}.jpg');
    try {
      imageUrl = await imageReference.getDownloadURL();
    } catch (e) {
      imageUrl = '';
    }
  }
}
