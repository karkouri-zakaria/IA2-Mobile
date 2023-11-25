import 'dart:io';
import 'package:tflite/tflite.dart';

class TFliteModel {
  bool loading = true;
  late File _image;

  TFliteModel(File image) {
    _image = image;
    // Load the model in the constructor
    loadModel();
  }

  Future<List?> detectImage() async {
    try {
      var prediction = await Tflite.runModelOnImage(
        path: _image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5,
        asynch: true,
      );

      return prediction;
    } catch (e) {
      print('Error during inference: $e');
      return null;
    } finally {
      Tflite.close();
    }
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model/model_unquant.tflite',
        labels: 'assets/model/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );

      // Set loading to false after successfully loading the model
      loading = false;
    } catch (e) {
      print('Error loading TFLite model: $e');
    }
  }

  // Additional method to reload the model if needed
  Future<void> reloadModel() async {
    // Add any cleanup or additional setup logic if needed
    await Tflite.close();
    await loadModel();
  }
}
