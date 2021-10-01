import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/green_log.dart';
import 'package:geolocation_sample/raw_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'home_screen.dart';
import 'location_uploader.dart';

void main() async {
  runApp(const MyApp());
  BackgroundGeolocation.registerHeadlessTask(headlessTask);
  await GreenLogs.logInfo("App started", "this is just a simple log");
}

Future<void> headlessTask(HeadlessEvent headlessEvent) async {
  initSensors();
  final timeStamp = DateTime.now().toIso8601String();
  final nameOfEvent = headlessEvent.name + " : " + timeStamp;
  final payload = headlessEvent.event.toString();
  final String newEntry = "$nameOfEvent//split$payload";
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  await greenPrefs.putHeadlessEvent(newEntry);
}

Future<void> logRawSession(HeadlessEvent headlessEvent) async {
  if (headlessEvent.name == Event.LOCATION) {
    await Future.delayed(const Duration(seconds: 2));
    final RawSession rawSession = getRawSessionFromLocation(
        headlessEvent.event as Location,
        acc: acc.value.asMap,
        magnetometer: magnetoMeter.value.asMap);
    final String newEntry = "RawSession//split${rawSession.toMap().toString()}";
    GreenPrefs greenPrefs = await GreenPrefs.getInstance();
    await greenPrefs.putHeadlessEvent(newEntry);
  }
}

Future<List<String>> getHeadLessEventsListFromHive() async {
  GreenPrefs greenPrefs = await GreenPrefs.getInstance();
  return greenPrefs.getHeadlessEvents();
}

const String prefsKey = "headlessEvents";

void initSensors() {
  accelerometerEvents.listen((AccelerometerEvent event) {
    acc.add(event);
  });

  userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    userAcc.add(event);
  });

  gyroscopeEvents.listen((GyroscopeEvent event) {
    gyro.add(event);
  });
  magnetometerEvents.listen((MagnetometerEvent event) {
    magnetoMeter.add(event);
  });
}

BehaviorSubject<AccelerometerEvent> acc = BehaviorSubject.seeded(null);
BehaviorSubject<UserAccelerometerEvent> userAcc = BehaviorSubject.seeded(null);
BehaviorSubject<GyroscopeEvent> gyro = BehaviorSubject.seeded(null);
BehaviorSubject<MagnetometerEvent> magnetoMeter = BehaviorSubject.seeded(null);

extension AccelerometerEventExt on AccelerometerEvent {
  Map<String, double> get asMap {
    if (this == null) return {};
    return {"x": x, "y": y, "z": z};
  }
}

extension UserAccelerometerEventExt on UserAccelerometerEvent {
  Map<String, double> get asMap {
    if (this == null) return {};
    return {"x": x, "y": y, "z": z};
  }
}

extension GyroEventExt on GyroscopeEvent {
  Map<String, double> get asMap {
    if (this == null) return {};
    return {"x": x, "y": y, "z": z};
  }
}

extension MagnetometerEventExt on MagnetometerEvent {
  Map<String, double> get asMap {
    if (this == null) return {};
    return {"x": x, "y": y, "z": z};
  }
}

extension InternalToMap on LinkedHashMap {
  Map<String, dynamic> get toMap =>
      Map.fromEntries(entries.map((e) => MapEntry(e.key.toString(), e.value)));
}
