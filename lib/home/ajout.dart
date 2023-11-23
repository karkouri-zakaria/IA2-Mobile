import 'package:flutter/material.dart';

class Ajout extends StatefulWidget {
  const Ajout({Key? key}) : super(key: key);

  @override
  _AjoutState createState() => _AjoutState();
}

class _AjoutState extends State<Ajout> {
  TextEditingController titleController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController minPersonController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // Placeholder for image URL, replace it with your actual image handling logic
  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview (replace with your image handling logic)
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 200, fit: BoxFit.cover)
                : const Placeholder(fallbackHeight: 200),

            // Add image upload button (replace with your image handling logic)
            ElevatedButton(
              onPressed: () {
                // Handle image upload (replace with your image handling logic)
                _uploadImage();
              },
              child: const Text('Upload Image'),
            ),

            // Form fields
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: placeController,
              decoration: const InputDecoration(labelText: 'Place'),
            ),
            TextField(
              controller: minPersonController,
              decoration: const InputDecoration(labelText: 'Min Person'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),

            // Submit button
            ElevatedButton(
              onPressed: () {
                // Handle form submission
                _saveDataToDatabase();
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadImage() {
    // Placeholder for image upload logic
    // Replace with your image upload implementation
    // Set the `imageUrl` with the uploaded image URL
    setState(() {
      imageUrl =
      'https://via.placeholder.com/200'; // Replace with actual uploaded image URL
    });
  }

  void _saveDataToDatabase() {
    // Placeholder for saving data to the database
    // Replace with your database saving logic
    String title = titleController.text;
    String place = placeController.text;
    int minPerson = int.tryParse(minPersonController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0.0;

    // Use the data for saving to the database
    // For simplicity, print the data in this example
    print('Title: $title, Place: $place, Min Person: $minPerson, Price: $price');
  }
}
