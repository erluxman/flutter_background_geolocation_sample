import 'dart:io';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';

Future<void> initTracking() async {
  //Let UI load.
  await Future.delayed(const Duration(seconds: 1));
  BackgroundGeolocation.changePace(true);
  BackgroundGeolocation.ready(trackerConfig).then((State state) async {
    if (!state.enabled) {
      await BackgroundGeolocation.start();
    }
  });
}


Future<List<Location>> getRecordedLocations() async {
  var locations = await BackgroundGeolocation.locations;
  return locations.map((e) => Location(e)).toList();
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
