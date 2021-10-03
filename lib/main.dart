import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/green_log.dart';
import 'package:geolocation_sample/sensor_plugin.dart';
import 'package:sensortracker/sensortracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

void main() async {
  runApp(const MyApp());
  BackgroundGeolocation.registerHeadlessTask(headlessTask);
  await GreenLogs.logInfo("App started", "this is just a simple log");
  SensorPlugin.startSensorService();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final strings = await getHeadlessEventsFromSharedPrefs();
  await addStringToPrefs("Namaste //split payload");
  await prefs.setDouble("testabc", 200);
  await dummyPlugin();
}

Future<void> dummyPlugin() async {
  await GreenLogs.logInfo(
      "Before Sensortracker.platformVersion", "this is just a simple log");
  String version = "NoversionAvailiable";
  try {
    version = await Sensortracker.platformVersion;
  } catch (e, trace) {
    await GreenLogs.logError(
        "Failed to get platformVersion ", e.toString(), trace.toString());
    Logger.error("Failed to get platformVersion  ${e.toString()}");
  }
  await GreenLogs.logInfo(
      "After Sensortracker.platformVersion", "version is $version");

  await GreenLogs.logInfo("Before SensortrackerCopy.lastHeadlessUpdate",
      "this is just a simple log");
  double lastStored = 0;
  try {
    lastStored = DateTime.now().millisecondsSinceEpoch.toDouble();
    await Sensortracker.lastHeadlessUpdate(lastStored);
  } catch (e, trace) {
    await GreenLogs.logError(
        "Failed to get platformVersion ", e.toString(), trace.toString());
    Logger.error("Failed to get platformVersion  ${e.toString()}");
  }
  await GreenLogs.logInfo(
      "After SensortrackerCopy.lastHeadlessUpdate", "version is $lastStored");
}

Future<void> headlessTask(HeadlessEvent headlessEvent) async {
  final timeStamp = DateTime.now().toStringHHMMSS();
  final nameOfEvent = timeStamp + " " + headlessEvent.name;
  final payload = headlessEvent.event.toString();
  final String newEntry = "$nameOfEvent//split$payload";
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  final prefs = await SharedPreferences.getInstance();
  prefs.setDouble(
      "lastHeartbeat", DateTime.now().millisecondsSinceEpoch.toDouble());
  await greenPrefs.putHeadlessEvent(newEntry);

  await GreenLogs.logInfo(
      "Before Sensortracker.platformVersion", "this is just a simple log");
  String version = "NoversionAvailiable";
  try {
    version = await Sensortracker.platformVersion;
  } catch (e, trace) {
    await GreenLogs.logError(
        "Failed to get platformVersion ", e.toString(), trace.toString());
    Logger.error("Failed to get platformVersion  ${e.toString()}");
  }
  await GreenLogs.logInfo(
      "After Sensortracker.platformVersion", "version is $version");

  await GreenLogs.logInfo("Before SensortrackerCopy.lastHeadlessUpdate",
      "this is just a simple log");
  double lastStored = 0;
  try {
    lastStored = DateTime.now().millisecondsSinceEpoch.toDouble();
    await Sensortracker.lastHeadlessUpdate(lastStored);
  } catch (e, trace) {
    await GreenLogs.logError(
        "Failed to get platformVersion ", e.toString(), trace.toString());
    Logger.error("Failed to get platformVersion  ${e.toString()}");
  }
  await GreenLogs.logInfo(
      "After SensortrackerCopy.lastHeadlessUpdate", "version is $lastStored");
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
