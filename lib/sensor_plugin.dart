import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocation_sample/raw_session.dart';

import 'green_log.dart';

class SensorPlugin<T extends dynamic> {
  static const platform = MethodChannel('com.greenplay/sensors');
  String batteryLevel = 'Battery Level';
  static Future<void> getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    } catch (e) {
      batteryLevel = 'Method not implemented  ${e.toString()}';
    }
    return batteryLevel;
  }

  static Future<dynamic> getSensorLogs() async {
    dynamic sensorLogs;
    try {
      sensorLogs = await platform.invokeMethod('getSensorLogs');
    } on PlatformException catch (e) {
      sensorLogs = {
        "error_message": "Failed to get battery level: '${e.message}'."
      };
    } catch (e) {
      sensorLogs = {"error_message": 'Method not implemented  ${e.toString()}'};
    }
    return (sensorLogs as Map).entries.toList()
      ..sort((first, second) {
        return first.key.toString().compareTo(second.key.toString());
      });
  }

  static Future<void> startSensorService() async {
    if (Platform.isIOS) {
      return;
    }
    try {
      await platform.invokeMethod('startSensorService');
    } catch (e, trace) {
      await GreenLogs.logError(
          "Failed to start sensor", e.toString(), trace.toString());
      Logger.error("Sensorslog Failed To Start Sensor Service ${e.toString()}");
    }
  }

  static Future<void> stopSensorService() async {
    if (Platform.isIOS) {
      return;
    }
    try {
      await platform.invokeMethod('stopSensorService');
    } catch (e) {
      Logger.error("Sensorslog Failed To Stop Sensor Service ${e.toString()}");
    }
  }

  static Future<void> clearSensorLogs() async {
    try {
      await platform.invokeMethod('clearSensorLogs');
    } catch (e) {
      Logger.error("Sensorslog ailed To Clear Logs ${e.toString()}");
    }
  }

  static Future<void> removeSensorLog(String logID) async {
    try {
      await platform.invokeMethod('removeSensorLog', logID);
    } catch (e) {
      Logger.error("Sensorslog Failed To Remove Id = $logID ${e.toString()}");
    }
  }

  static Future<void> addSensorLog(String logID) async {
    try {
      await platform.invokeMethod('addSensorLog', logID);
    } catch (e) {
      Logger.error("Sensorslog Failed To Add Log ID = $logID ${e.toString()}");
    }
  }
}

Future<Map<String, dynamic>> fetchTimeSortedSensorData() async {
  final logs = await SensorPlugin.getSensorLogs();

  final Map<String, dynamic> sensorLogs = {};
  if (logs is! List) {
    return sensorLogs;
  }

  return Map.fromEntries(
    (logs as List).map((log) {
      try {
        final entry = log as MapEntry;
        final dynamic value = entry?.value;
        return MapEntry(entry?.key.toString(), value);
      } catch (e) {
        return null;
      }
    }).where((element) => element != null),
  );
}

String flooredForTenSeconds(DateTime date) {
  final String isoUS = date.toISOUs();
  final flooredSecond = flooredFor10Seconds(date.second);
  return "$isoUS:${getTwoDigitNumber(flooredSecond)}";
}

int flooredFor10Seconds(int num) {
  int second;
  if (num % 10 >= 5) {
    second = num - (num % 10) + 10;
  } else {
    second = num - (num % 10);
  }
  return second % 60;
}

String getTwoDigitNumber(int number) {
  final String prefix = (number >= 10) ? "" : "0";
  return "$prefix$number";
}

RawSession mergeRawSessionWithSensors(
  RawSession rawSession,
  Map<String, dynamic> sensorData,
) {
  // Do some transformation stuff that fixes the key of date String so that,
  // It matches the way we put in raw session but I think rather than here, we
  // We need to fix it when we create sensor data in the plugin itsel. This
  final flooredISOUS = flooredForTenSeconds(rawSession.timestamp.dateTime);
  //final rawSesionTimestamp = rawSession.timestamp.dateTime.toISOUs();
  final sensorLog = sensorData[flooredISOUS];
  if (sensorLog == null) {
    return rawSession;
  }

  Map<String, dynamic> sensorsJson;

  try {
    final decoded = json.decode(sensorLog.toString());
    sensorsJson = Map.fromEntries((decoded as Map).entries.map((entry) {
      return MapEntry(entry.key.toString(), entry.value);
    }).toList());
  } catch (_) {
    return rawSession;
  }

  return rawSession.copyWith(
    accelerometer: parseSensorModel(sensorsJson["accelerometer"]),
    magnetometer: parseSensorModel(sensorsJson["magnetometer"]),
  );
}

Map<String, num> parseSensorModel(dynamic jsonString) {
  if (jsonString == null || jsonString is! Map) return {};
  return (jsonString as Map).map((key, value) {
    final keyString = key.toString();
    num valueNum = 0;
    try {
      valueNum = num.parse(value.toString());
    } catch (_) {}
    return MapEntry(keyString, num.parse(valueNum.toString()));
  });
}

extension DateTimeExtension on DateTime {
  String formattedDate() {
    final format = DateFormat('d MMMM, y');
    return format.format(this);
  }

  bool get hasBeen10Minutes {
    return DateTime.now().difference(this).inSeconds >
        const Duration(minutes: 10).inSeconds;
  }

  bool get hasBeen10Seconds {
    return DateTime.now().difference(this).inSeconds >
        const Duration(seconds: 10).inSeconds;
  }

  String toStringMMDD(BuildContext context) {
    final format = context.locale.languageCode == "fr"
        ? DateFormat('dd MMMM')
        : DateFormat('MMMM dd');
    return format.format(this).toUpperCase();
  }

  String toStringMmDd(BuildContext context) {
    final format = context.locale.languageCode == "fr"
        ? DateFormat('dd MMMM')
        : DateFormat('MMMM dd');
    return format.format(this);
  }

  String toStringMmDdy(BuildContext context) {
    final format = context.locale.languageCode == "fr"
        ? DateFormat('dd MMMM, y')
        : DateFormat('MMMM dd, y');
    return format.format(this);
  }

  String toStringMmDdHHMM(BuildContext context) {
    return "${toStringMmDd(context)}${",  ${toStringHHMM(context)}"}";
  }

  String toStringHHMM(BuildContext context) {
    final bool twenty4Hour = MediaQuery.of(context).alwaysUse24HourFormat;
    final df = twenty4Hour ? DateFormat('kk : mm') : DateFormat('hh : mm a');
    return df.format(this);
  }

  String toStringHHMMSS() {
    final df = DateFormat('kk : mm : ss');
    return df.format(this);
  }

  String toISOUs() {
    final df = DateFormat("yyyy-MM-dd'T'HH:mm");
    return df.format(this);
  }

  String getTwoDigitNum(int num) {
    return "${num < 10 ? "0" : ""}$num";
  }

  String toStringYYYYMM() {
    final month = "${this.month > 9 ? "" : "0"}${this.month}";
    return "$year-$month";
  }

  String startOfWeekYYYYMMDD() {
    return subtract(Duration(days: weekday)).toStringYYYYMMDD();
  }

  String toStringYYYYMMDD() {
    final day = "${this.day > 9 ? "" : "0"}${this.day}";
    return "${toStringYYYYMM()}-$day";
  }
}

DateTime localTimeFromUTCTimeStamp(String timeStamp) {
  final utcTime = DateTime.parse(timeStamp);
  final date = DateTime.fromMillisecondsSinceEpoch(
      utcTime.millisecondsSinceEpoch,
      isUtc: true);
  return date.toLocal();
}

final months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sept",
  "Oct",
  "Nov",
  "Dec"
];

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
