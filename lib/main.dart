import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/green_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

void main() async {
  runApp(const MyApp());
  BackgroundGeolocation.registerHeadlessTask(headlessTask);
  await GreenLogs.logInfo("App started", "this is just a simple log");
}

Future<void> headlessTask(HeadlessEvent headlessEvent) async {
  final timeStamp = DateTime.now().toIso8601String();
  final nameOfEvent = headlessEvent.name + " : " + timeStamp;
  final payload = headlessEvent.event.toString();
  final String newEntry = "$nameOfEvent//split$payload";
  final entries = await getHeadLessEventsList();
  entries.add(newEntry);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(prefsKey, entries);
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  await greenPrefs.putHeadlessEvent(newEntry);
}

Future<List<String>> getHeadLessEventsList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> events = prefs.getStringList(prefsKey) ?? [];
  return events.reversed.toList();
}

Future<List<String>> getHeadLessEventsListFromHive() async {
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  return greenPrefs.getHeadlessEvents();
}

const String prefsKey = "headlessEvents";
