import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/green_log.dart';
import 'package:geolocation_sample/sensor_plugin.dart';

import 'home_screen.dart';

void main() async {
  runApp(const MyApp());
  BackgroundGeolocation.registerHeadlessTask(headlessTask);
  await SensorPlugin.startSensorService();
  await GreenLogs.logInfo("App started", "this is just a simple log");
}

Future<void> headlessTask(HeadlessEvent headlessEvent) async {
  final timeStamp = DateTime.now().toIso8601String();
  final nameOfEvent = headlessEvent.name + " : " + timeStamp;
  final payload = headlessEvent.event.toString();
  final String newEntry = "$nameOfEvent//split$payload";
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  await greenPrefs.putHeadlessEvent(newEntry);
  await GreenLogs.logInfo("Before starting sensor", "Before starting sensor");

  await SensorPlugin.startSensorService();
  await GreenLogs.logInfo("After starting sensor", "After starting sensor");
}

Future<List<String>> getHeadLessEventsListFromHive() async {
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  return greenPrefs.getHeadlessEvents();
}

const String prefsKey = "headlessEvents";
