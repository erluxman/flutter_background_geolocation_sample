import 'dart:developer';

import 'package:equatable/equatable.dart';

import 'session.dart';
class RawSession with EquatableMixin {
  const RawSession({
    this.timestamp,
    this.uploadedTimestamp,
    this.altitude,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.activityType,
    this.challenges,
    this.accelerometer,
    this.heading,
    this.magnetometer,
    this.speed,
    this.mlOptimized,
    this.mlInputSize,
    this.isFromSyncEngine,
    this.distance,
    this.locationId,
    this.trainDistance,
    this.sensorActivityType,
    this.confidenceMap,
  });

  factory RawSession.fromMap(Map map) {
    int timeStamp = parseDate(map['timestamp'])?.millisecondsSinceEpoch ?? 0;
    if (timeStamp < 1947465977) {
      timeStamp *= 1000;
    }
    try {
      return RawSession(
        timestamp: timeStamp,
        uploadedTimestamp:
            parseDate(map['uploadedTimestamp'])?.millisecondsSinceEpoch ?? 0,
        latitude: map['latitude'] as num,
        longitude: map['longitude'] as num,
        altitude: map['altitude'] as num,
        heading: map['heading'] as num,
        isFromSyncEngine: map['isFromSyncEngine'] as bool,
        mlOptimized: (map['mlOptimized'] ?? false) as bool,
        mlInputSize: (map['mlInputSize'] ?? 0) as int,
        activityType: map['activityType'] as String,
        sensorActivityType: map['sensorActivityType'] as String,
        locationId: map['locationId'] as String,
        accelerometer:
            Map<String, num>.from((map['accelerometer'] ?? {}) as Map),
        magnetometer: Map<String, num>.from((map['magnetometer'] ?? {}) as Map),
        accuracy: map['accuracy'] as num,
        speed: map['speed'] as num,
        distance: (map['distance'] as num) ?? 99999,
        trainDistance: (map['trainDistance'] as num) ?? 99999,
      );
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'uploadedTimestamp': uploadedTimestamp,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'isFromSyncEngine': isFromSyncEngine,
      'accuracy': accuracy,
      'activityType': activityType,
      'sensorActivityType': sensorActivityType,
      'locationId': locationId,
      'challenges': (challenges ?? []).map((challenge) {
        return challenge.toMap();
      }).toList(),
      'accelerometer': accelerometer,
      'heading': heading,
      'mlOptimized': mlOptimized ?? false,
      'mlInputSize': mlInputSize ?? 0,
      'magnetometer': magnetometer,
      'speed': speed,
      'distance': distance,
      'trainDistance': trainDistance,
      'accuracyML': confidenceMap
    };
  }

  final int timestamp;
  final int uploadedTimestamp;
  final num latitude, longitude;
  final num altitude, accuracy, heading, speed;
  final String activityType;
  final String sensorActivityType;
  final String locationId;

  final List<RawSessionChallenge> challenges;
  final Map<String, num> accelerometer;
  final Map<String, num> magnetometer;
  final bool mlOptimized;
  final int mlInputSize;
  final bool isFromSyncEngine;
  final num distance;
  final num trainDistance;
  final Map<String, double> confidenceMap;
  Latlng get latlng => Latlng(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      altitude: altitude.toDouble(),
      timestamp: timestamp);

  RawSession copyWith(
      {int timestamp,
      int uploadedTimestamp,
      num latitude,
      num longitude,
      num altitude,
      num accuracy,
      num heading,
      num speed,
      bool mlOptimized,
      int mlInputSize,
      bool isFromSyncEngine,
      num distance,
      num trainDistance,
      String activityType,
      String sensorActivityType,
      String locationId,
      List<RawSessionChallenge> challenges,
      Map<String, num> accelerometer,
      Map<String, num> magnetometer,
      num elevationFromApi,
      Map<String, double> confidenceMap}) {
    return RawSession(
      timestamp: timestamp ?? this.timestamp,
      uploadedTimestamp: uploadedTimestamp ?? this.uploadedTimestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      mlInputSize: mlInputSize ?? this.mlInputSize,
      mlOptimized: mlOptimized ?? this.mlOptimized,
      isFromSyncEngine: isFromSyncEngine ?? this.isFromSyncEngine,
      activityType: activityType ?? this.activityType,
      sensorActivityType: sensorActivityType ?? this.sensorActivityType,
      challenges: challenges ?? this.challenges,
      heading: heading ?? this.heading,
      locationId: locationId ?? this.locationId,
      speed: speed ?? this.speed,
      accelerometer: accelerometer ?? this.accelerometer,
      magnetometer: magnetometer ?? this.magnetometer,
      distance: distance ?? this.distance,
      trainDistance: trainDistance ?? this.trainDistance,
      confidenceMap: confidenceMap ?? this.confidenceMap,
    );
  }

  bool get validForML {
    return accuracy != null &&
        heading != null &&
        speed != null &&
        altitude != null &&
        accelerometer != null &&
        accelerometer.length == 3 &&
        magnetometer != null &&
        magnetometer.length == 3 &&
        distance != null &&
        trainDistance != null;
  }

  @override
  List<Object> get props => [
        timestamp,
        uploadedTimestamp,
        activityType,
        sensorActivityType,
        latitude,
        longitude,
        accuracy,
        speed,
        heading,
        accelerometer,
        mlOptimized,
        mlInputSize,
        magnetometer,
        distance,
        trainDistance
      ];

  @override
  bool get stringify => true;
}

class RawSessionChallenge {
  const RawSessionChallenge({this.challengeId, this.ownerId, this.ownerType});

  final String challengeId;
  final String ownerType;
  final String ownerId;

  Map<String, dynamic> toMap() {
    return {
      "id": challengeId,
      "ownerType": ownerType,
      "ownerId": ownerId,
    };
  }
}

DateTime parseDate(dynamic date) {
  if (date == null) return null;
  if (date is int) {
    return DateTime.fromMicrosecondsSinceEpoch(date);
  }
  if (date is String) {
    return DateTime.parse(date);
  }
  return null;
}
