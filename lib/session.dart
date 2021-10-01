import 'dart:math' as math;

class Session {
  Session(
      {this.createdOn,
      this.timeLine,
      this.deleted,
      this.id,
      this.name,
      this.nameFrench,
      this.updatedOn,
      this.activityType,
      this.distance,
      this.endTimestamp,
      this.sessionType,
      this.startTimestamp,
      this.isComputedRaw = true,
      this.calories,
      this.isValid,
      this.edited,
      this.greenhouseGazes,
      this.greenpoints,
      this.isIntermodalityTripSession,
      this.distanceEdited,
      this.originalActivityType});

  factory Session.fromMap(Map<String, dynamic> map,
      {bool isComputed = true, String id}) {
    return Session(
      id: id ?? map['id'] as String,
      name: map['name'] as String,
      nameFrench: map['nameFrench'] as String,
      activityType: map['activityType'] as String,
      originalActivityType: map['originalActivityType'] as String,
      sessionType: map['sessionType'] as String,
      distance: map['distance'] as num,
      timeLine: (map['timeline'] as List)
          .map((entry) =>
              Latlng.fromMap((entry as Map<String, dynamic>) ?? {"": ""}))
          .toList(),
      createdOn: ((map['createdOn'] as num) ?? 0).dateTime,
      startTimestamp: (map['startTimestamp'] as num).dateTime,
      updatedOn: ((map['updatedOn'] as num) ?? 0).dateTime,
      endTimestamp: (map['endTimestamp'] as num).dateTime,
      deleted: map['deleted'] as bool,
      isValid: map['isValid'] as bool,
      distanceEdited: map['distanceEdited'] as bool,
      isIntermodalityTripSession: map['isIntermodalityTripSession'] as bool,
      edited: map['edited'] as bool,
      calories: map['calories'] as num,
      greenpoints: map['greenpoints'] as num,
      greenhouseGazes: map['greenhouseGazes'] as num,
      isComputedRaw: isComputed,
    );
  }

  factory Session.newInstance() => Session(
        deleted: false,
        name: "New Session",
        createdOn: DateTime.now(),
        updatedOn: DateTime.now(),
      );

  String id;
  String name;
  String nameFrench;
  String activityType;
  String originalActivityType;
  String sessionType;
  num distance;
  List<Latlng> timeLine;
  DateTime createdOn;
  DateTime startTimestamp;
  DateTime updatedOn;
  DateTime endTimestamp;
  bool isComputedRaw;
  num greenhouseGazes;
  num calories;
  num greenpoints;
  bool deleted;
  bool isIntermodalityTripSession;
  bool edited;
  bool distanceEdited;
  final bool isValid;

  String get elapsedTime {
    final duration = endTimestamp.difference(startTimestamp);
    final hours = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return "${hours > 0 ? "$hours Hours " : ""}$mins Minutes";
  }

  String get durationHHMMss {
    final duration = endTimestamp.difference(startTimestamp);
    final pureHours = duration.inHours;
    final pureMinutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final showHours = pureHours > 0;
    // ignore: lines_longer_than_80_chars
    return "${showHours ? "$pureHours h : " : ""} ${pureMinutes}m : ${seconds}s";
  }

  Session copyWith({
    String id,
    String name,
    String nameFrench,
    String activityType,
    String originalActivityType,
    String sessionType,
    double distance,
    List<Latlng> timeLine,
    DateTime createdOn,
    DateTime startTime,
    DateTime updatedOn,
    DateTime endTime,
    bool deleted,
    bool edited,
    bool distanceEdited,
    bool isValid,
    bool isIntermodalityTripSession,
    num calories,
    num greenpoints,
    num greenhouseGazes,
  }) {
    return Session(
        id: id ?? this.id,
        name: name ?? this.name,
        nameFrench: nameFrench ?? this.nameFrench,
        activityType: activityType ?? this.activityType,
        originalActivityType: originalActivityType ?? this.originalActivityType,
        sessionType: sessionType ?? this.sessionType,
        distance: distance ?? this.distance,
        timeLine: timeLine ?? this.timeLine,
        createdOn: createdOn ?? this.createdOn,
        startTimestamp: startTime ?? startTimestamp,
        updatedOn: updatedOn ?? this.updatedOn,
        endTimestamp: endTime ?? endTimestamp,
        deleted: deleted ?? this.deleted,
        edited: edited ?? this.edited,
        distanceEdited: distanceEdited ?? this.distanceEdited,
        isValid: isValid ?? this.isValid,
        isIntermodalityTripSession:
            isIntermodalityTripSession ?? this.isIntermodalityTripSession,
        greenhouseGazes: greenpoints ?? this.greenpoints,
        calories: calories ?? this.calories,
        greenpoints: greenpoints ?? this.greenpoints);
  }

  String get timePerKM {
    final totalMinutes = endTimestamp.difference(startTimestamp).inMinutes;
    final speed = totalMinutes / distance * 1000;

    return "${speed.toStringAsFixed(2)} min / KM";
  }

  double get distanceKM => distance / 1000;

  String get durationMMss {
    final totalSeconds = endTimestamp.difference(startTimestamp).inSeconds;
    final int pureMinutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return "${pureMinutes}m : ${seconds}s";
  }

  Map<String, dynamic> toMap() {
    try {
      return {
        'id': id,
        'name': name,
        'nameFrench': nameFrench,
        'activityType': activityType,
        'originalActivityType': originalActivityType,
        'sessionType': sessionType,
        'distance': distance,
        'timeline': timeLine.map((latlng) => latlng.toMap()),
        'createdOn': createdOn.millisecondsSinceEpoch,
        'startTimestamp': startTimestamp.millisecondsSinceEpoch,
        'updatedOn': updatedOn.millisecondsSinceEpoch,
        'endTimestamp': endTimestamp.millisecondsSinceEpoch,
        'deleted': deleted,
        'edited': edited,
        'distanceEdited': distanceEdited,
        'isValid': isValid,
        'isIntermodalityTripSession': isIntermodalityTripSession,
        'greenpoints': greenpoints,
        'greenhouseGazes': greenhouseGazes,
        'calories': calories
      };
    } catch (e) {
      return null;
    }
  }
}

class ActivityType {
  static const String walk = "walk";
  static const String run = "run";
  static const String bike = "bike";
  static const String car = "car";
  static const String train = "train";
}

class Latlng {
  Latlng({
    this.latitude,
    this.longitude,
    this.timestamp,
    this.altitude,
  });

  factory Latlng.quick(
    double latitude,
    double longitude, {
    int timestamp,
    double altitude,
  }) {
    return Latlng(
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
        altitude: altitude);
  }

  factory Latlng.fromMap(Map<String, dynamic> map) {
    return Latlng(
      latitude: ((map['latitude'] ?? 0) as num).toDouble(),
      altitude: ((map['altitude'] ?? 0) as num).toDouble(),
      longitude: ((map['longitude'] ?? 0) as num).toDouble(),
      timestamp: map['timestamp'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'altitude': altitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }

  double latitude, altitude, longitude;
  int timestamp;
}

extension NumExt on num {
  String get iso8601String =>
      DateTime.fromMillisecondsSinceEpoch(toInt()).toIso8601String();

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(toInt());

  double get sqrt => math.sqrt(this);

  num get squared => math.pow(this, 2);

  num get cubed => math.pow(this, 3);

  bool isInRange(num a, num b, {bool isInclusive = true}) {
    final bigger = math.max(a, b);
    final smaller = math.min(a, b);

    return isInclusive
        ? this >= smaller && this <= bigger
        : this > smaller && this < bigger;
  }
}
