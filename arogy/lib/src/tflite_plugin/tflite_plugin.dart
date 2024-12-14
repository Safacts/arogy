library;

import 'dart:typed_data';
import 'package:flutter/services.dart';

class TflitePlugin {
  static const MethodChannel _channel = MethodChannel('tflite_plugin');

  Future<String> loadModel(String modelPath) async {
    final String result = await _channel.invokeMethod('loadModel', {'modelPath': modelPath});
    return result;
  }

  Future<Map<String, dynamic>> predict(Uint8List input) async {
    final Map<String, dynamic> result = await _channel.invokeMethod('predict', {'input': input});
    return result;
  }
}
