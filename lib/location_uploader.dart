
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/raw_session.dart';

RawSession getRawSessionFromLocation(
  Location location, {
  Map<String, num> acc,
  Map<String, num> magnetometer,
  Map<String, dynamic> sensorLogs,
  bool isFromSyncEngine = true,
}) {
  int ts = DateTime.parse(location.timestamp).millisecondsSinceEpoch;
  RawSession rawSession = RawSession(
    accuracy: location.coords.accuracy,
    speed: location.coords.speed,
    heading: location.coords.heading,
    longitude: location.coords.longitude,
    latitude: location.coords.latitude,
    altitude: location.coords.altitude,
    locationId: location.uuid,
    sensorActivityType: location.activity.type,
    isFromSyncEngine: isFromSyncEngine,
    timestamp: ts,
    activityType:location.activity.type.getActivityName,
  );
  return rawSession;
}
extension ActivityTypeParser on String {
  String get getActivityName {
    if (this == 'walking' || this == 'on_foot') {
      return 'walk';
    } else if (this == 'running') {
      return 'run';
    } else if (this == 'on_bicycle') {
      return 'bike';
    } else if (this == 'in_vehicle') {
      return 'car';
    } else if (this == 'still') {
      return "still";
    } else {
      return 'other';
    }
  }
}