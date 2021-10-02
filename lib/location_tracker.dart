import 'dart:collection';
import 'dart:io';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/green_log.dart';
import 'package:rxdart/subjects.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'location_uploader.dart';
import 'sensor_plugin.dart';

Future<void> initTracking() async {
  //Let UI load.
  await Future.delayed(const Duration(seconds: 1));
  BackgroundGeolocation.changePace(true);
  await SensorPlugin.startSensorService();

  //initSensors();
  // BackgroundGeolocation.onLocation((location) async {
  //   await saveRawSession(location);
  // });
  BackgroundGeolocation.ready(trackerConfig).then((State state) async {
    if (!state.enabled) {
      await BackgroundGeolocation.start();
    }
  });
}

Future<List<Location>> getRecordedLocations() async {
  var locations = await BackgroundGeolocation.locations;
  final abc = locations
      .map((e) {
        final location = Location(e);
        location.timestamp =
            localTimeFromUTCTimeStamp(location.timestamp).toIso8601String();
        location.map["timestamp"] = location.timestamp;
        return location;
      })
      .toList()
      .reversed
      .toList();
  return abc;
}

Config get androidConfig => Config(
      backgroundPermissionRationale: permissionRationale,
      desiredAccuracy: Config.DESIRED_ACCURACY_NAVIGATION,
      distanceFilter: 2,
      locationUpdateInterval: 8 * 1000,
      fastestLocationUpdateInterval: 5 * 1000,
      enableHeadless: true,
      isMoving: true,
      locationAuthorizationRequest: "Always",
      minimumActivityRecognitionConfidence: 50,
      notification: Notification(
        smallIcon: 'mipmap/ic_launcher',
        channelName: "Greenplay Tracking",
        largeIcon: 'mipmap/ic_launcher',
        text: 'Collecting Locations',
        title: "GreenPlay",
        priority: Config.NOTIFICATION_PRIORITY_HIGH,
      ),
      persistMode: Config.PERSIST_MODE_ALL,
      reset: true,
      startOnBoot: true,
      speedJumpFilter: 40,
      stopOnTerminate: false,
      stopTimeout: 5,
    );

Config get iOSConfig => Config(
      desiredAccuracy: Config.DESIRED_ACCURACY_NAVIGATION,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: false,
      logLevel: Config.PERSIST_MODE_ALL,
      activityType: Config.ACTIVITY_TYPE_AUTOMOTIVE_NAVIGATION,
      preventSuspend: true,
      forceReloadOnBoot: true,
      forceReloadOnGeofence: true,
      forceReloadOnHeartbeat: true,
      forceReloadOnLocationChange: true,
      forceReloadOnMotionChange: true,
      forceReloadOnSchedule: true,
      isMoving: true,
      foregroundService: true,
      distanceFilter: 12,
      stopTimeout: 5,
      locationUpdateInterval: 8 * 1000,
      activityRecognitionInterval: 8 * 1000,
      persistMode: Config.PERSIST_MODE_LOCATION,
      locationAuthorizationRequest: 'Always',
      backgroundPermissionRationale: permissionRationale,
      maxRecordsToPersist: 2000,
      reset: true,
      allowIdenticalLocations: false,
      minimumActivityRecognitionConfidence: 50,
      heartbeatInterval: 60,
    );

Config get trackerConfig => Platform.isIOS ? iOSConfig : androidConfig;

PermissionRationale get permissionRationale => PermissionRationale(
      title: "Provide location permission",
      message: "We need location and activity to record your performance",
      positiveAction: "Sure bro, let's do it",
      negativeAction: "No bro, sorry",
    );

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

Future<void> saveRawSession(Location location) async {
  final raw = getRawSessionFromLocation(
    location,
    acc: acc.value.asMap,
    magnetometer: magnetoMeter.value.asMap,
  );

  GreenPrefs prefs = await GreenPrefs.getInstance();
  prefs.putHeadlessEvent(
      "Rawsession onLocation//split${raw.toMap().toString()}");
}
