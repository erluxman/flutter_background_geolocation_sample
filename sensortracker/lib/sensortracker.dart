import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Sensortracker {
  static const MethodChannel _channel = MethodChannel('sensortracker');


  static Future<String?> get platformVersion async {
    if (Platform.isIOS) {
      return "notavailiable";
    }
    try {
      await _channel.invokeMethod('getPlatformVersion');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> lastHeadlessUpdate(double timestamp) async {
    if (Platform.isIOS) {
      return;
    }
    try {
      await _channel.invokeMethod('lastHeadlessUpdate',timestamp);
    } catch (e) {
      rethrow;
    }
  }
}
