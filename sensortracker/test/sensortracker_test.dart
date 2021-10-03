import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensortracker/sensortracker.dart';

void main() {
  const MethodChannel channel = MethodChannel('sensortracker');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Sensortracker.platformVersion, '42');
  });
}
