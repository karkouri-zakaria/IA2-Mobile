import 'dart:io';
import 'package:tflite/tflite.dart';

class TFliteModel {
  bool loading = true;
  late File _image;

  TFliteModel(File image) {
    _image = image;
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

      loading = false;
    } catch (e) {
      return;
    }
  }

  Future<void> reloadModel() async {
    await Tflite.close();
    await loadModel();
  }
}
