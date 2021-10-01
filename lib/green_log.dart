import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:geolocation_sample/raw_session.dart';

class GreenLogs {
  const GreenLogs._(this._greenPrefs);

  static Future<GreenLogs> instance() async {
    if (_instance != null) {
      return _instance;
    }
    await Hive.initFlutter();
    final greenPrefs = await GreenPrefs.getInstance();
    final logger = GreenLogs._(greenPrefs);
    _instance = logger;
    return _instance;
  }

  static GreenLogs _instance;
  final GreenPrefs _greenPrefs;

  static Future<void> logError(String title, String description) async {
    (await instance()).logGeneric(
      title: title,
      description: description,
      emoji: "❌",
      textColor: Colors.red,
    );
  }

  static Future<void> logInfo(String title, String description) async {
    (await instance()).logGeneric(
      title: title,
      description: description,
      emoji: "ℹ️",
      textColor: Colors.lightBlue,
    );
  }

  Future<void> logGeneric({
    @required String title,
    @required String description,
    @required String emoji,
    @required Color textColor,
    String stackTrace,
  }) {
    return _greenPrefs.putLog(
      LogModel(
        title: title,
        description: description,
        emoji: emoji,
        textColor: textColor,
        stackTrace: stackTrace,
        date: DateTime.now(),
      ),
    );
  }
}

class GreenPrefs {
  GreenPrefs._() {
    init();
  }

  static Future<GreenPrefs> getInstance() async {
    if (_hiveSingleton != null) {
      return _hiveSingleton;
    }
    await Hive.initFlutter();
    final prefs = GreenPrefs._();
    await prefs.init();
    _hiveSingleton = prefs;
    return _hiveSingleton;
  }

  static GreenPrefs _hiveSingleton;

  Future<void> init() async {
    _stringHive = await Hive.openBox<String>("app_strings");
    _intHive = await Hive.openBox<int>("app_ints");
    _boolHive = await Hive.openBox<bool>("app_bools");
    _sessionHive = await Hive.openBox<String>("app_session");
    _logHive = await Hive.openBox<String>("app_logs");
    _headlessEventsHive = await Hive.openBox<String>("headless_events");
  }

  Future<void> clearPrefs() async {
    await _stringHive.clear();
    await _intHive.clear();
    await _boolHive.clear();
    await _sessionHive.clear();
    await _logHive.clear();
    await _headlessEventsHive.clear();
  }

  Box<String> _stringHive;
  Box<int> _intHive;
  Box<bool> _boolHive;
  Box<String> _sessionHive;
  Box<String> _logHive;
  Box<String> _headlessEventsHive;

  bool get isInitialized => _stringHive != null && _intHive != null;

  Future<void> putString(String key, String value) async =>
      _stringHive.put(key, value);

  String getString(String key, {String defaultValue}) =>
      _stringHive.get(key, defaultValue: defaultValue);

  Future<void> putHeadlessEvent(String eventString) async {
    await _headlessEventsHive.add(eventString);
  }

  List getHeadlessEvents() => (_headlessEventsHive.values ?? []).toList();

  Future<void> putLog(LogModel log) async {
    final String encodedLogs = jsonEncode(log.toMap());
    await _logHive.put(log.logKey, encodedLogs);
  }

  List<LogModel> getLogs() {
    final logs = _logHive?.values ?? [];
    try {
      return (logs as List).map((log) {
        return LogModel.fromMap(json.decode(log));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> putSessions(List<RawSession> sessions) async {
    final String sessionList =
        jsonEncode(sessions.map((e) => e.toMap()).toList());
    _sessionHive.put("raw_sessions", sessionList);
  }

  List<RawSession> getSessions() {
    final sessions = _sessionHive?.get(
      "raw_sessions",
      defaultValue: jsonEncode([]),
    );
    try {
      return (json.decode(sessions) as List).map((e) {
        return RawSession.fromMap(Map.castFrom(e as Map));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> putInt(String key, int value) async => _intHive.put(key, value);

  int getInt(String key, {int defaultValue}) =>
      _intHive.get(key, defaultValue: defaultValue);

  Future<void> putBool(String key, {bool value}) async =>
      _boolHive.put(key, value);

  bool getBool(String key, {bool defaultValue}) =>
      _boolHive.get(key, defaultValue: defaultValue);
}

extension InternalToMap on LinkedHashMap {
  Map<String, dynamic> get toMap =>
      Map.fromEntries(entries.map((e) => MapEntry(e.key.toString(), e.value)));
}

class LogModel {
  String title;
  String description;
  String emoji;
  Color textColor;
  DateTime date;
  String stackTrace;
  LogModel(
      {this.title,
      this.description,
      this.emoji,
      this.textColor,
      this.date,
      this.stackTrace});

  LogModel copyWith(
      {String title,
      String description,
      String emoji,
      Color color,
      DateTime date,
      String stackTrace}) {
    return LogModel(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      stackTrace: stackTrace ?? this.stackTrace,
      textColor: color ?? this.textColor,
      date: date ?? this.date,
    );
  }

  String get logKey {
    final year = date.year.toString();
    final month = date.month.twoDigit;
    final day = date.day.twoDigit;
    final hour = date.hour.twoDigit;
    final minute = date.minute.twoDigit;
    final second = date.second.twoDigit;
    return "$year-$month-$day, $hour:$minute:$second";
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'textColor': textColor.value,
      'stackTrace': stackTrace.toString(),
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'],
      description: map['description'],
      emoji: map['emoji'],
      textColor: Color(map['textColor']),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}

extension StringDateUtils on int {
  String get twoDigit => '${this > 9 ? "" : "0"}${this}';
}
