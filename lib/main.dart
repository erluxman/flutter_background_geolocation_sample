import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/green_log.dart';
import 'package:geolocation_sample/sensor_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

void main() async {
  runApp(const MyApp());
  BackgroundGeolocation.registerHeadlessTask(headlessTask);
  await GreenLogs.logInfo("App started", "this is just a simple log");
  SensorPlugin.startSensorService();
}

Future<void> headlessTask(HeadlessEvent headlessEvent) async {
  final timeStamp = DateTime.now().toStringHHMMSS();
  final nameOfEvent = timeStamp + " " + headlessEvent.name;
  final payload = headlessEvent.event.toString();
  final String newEntry = "$nameOfEvent//split$payload";
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  final prefs = await SharedPreferences.getInstance();
  final dateNow = DateTime.now();
  prefs.setDouble("lastHeartbeat", dateNow.millisecondsSinceEpoch.toDouble());
  await greenPrefs.putHeadlessEvent(newEntry);

  await GreenLogs.logInfo("New lastHeartbeat add",
      "New log added as value ${dateNow.toIso8601String()}");
}

Future<List<String>> getHeadLessEventsListFromHive() async {
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  return greenPrefs.getHeadlessEvents();
}

const String prefsKey = "headlessEvents";
Future<void> addStringToPrefs(String newData) async {
  final strings = await getHeadlessEventsFromSharedPrefs();
  strings.add(newData);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList("headlessEvents", strings);
}

Future<List<String>> getHeadlessEventsFromSharedPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final strings = prefs.getStringList("headlessEvents") ?? [];
  return strings;
}
