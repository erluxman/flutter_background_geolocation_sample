import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

Future<void> headlessTask(HeadlessEvent headlessEvent) async {
  final nameOfEvent = headlessEvent.name;
  final payload = headlessEvent.name;
  final Map<String, dynamic> newEntry = {nameOfEvent: payload};
  final encryptedString = json.encode(newEntry);
  final entries = await getHeadLessEventsList();
  entries.add(encryptedString);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(prefsKey, entries);
}

Future<List<String>> getHeadLessEventsList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> events = prefs.getStringList(prefsKey) ?? [];
  return events;
}

const String prefsKey = "headlessEvents";
