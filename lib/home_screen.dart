import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:geolocation_sample/green_log.dart';
import 'location_tracker.dart';
import 'main.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initTracking();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Text("Locations")),
                Tab(icon: Text("Headless Events")),
                Tab(icon: Text("Logs")),
              ],
            ),
            title: const Text('Tabs Demo'),
          ),
          body: const TabBarView(
            children: [
              LocationsWidget(),
              HeadlessEventsWidget(),
              LogsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class HeadlessEventsWidget extends StatelessWidget {
  const HeadlessEventsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getHeadlessEventsFromSharedPrefs(),
      initialData: const [],
      builder: (context, snapshot) {
        final events = snapshot.data;
        if (events == null || events.isEmpty) {
          return const Center(child: Text("No locations recorded "));
        }
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final String event = events[index];
            final List<String> titleAndBody = event.split("//split");
            final title = titleAndBody[0];
            final body = titleAndBody[1];
            return ExpansionTile(
              title: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    body,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}

class LocationsWidget extends StatelessWidget {
  const LocationsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<bg.Location>>(
      future: getRecordedLocations(),
      initialData: const [],
      builder: (context, snapshot) {
        final locations = snapshot.data;
        if (locations == null || locations.isEmpty) {
          return const Center(child: Text("No locations recorded "));
        }
        return ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final bg.Location location = locations[index];
            return ExpansionTile(
              title: Row(
                children: [
                  Text(
                    location.timestamp.toString() +
                        " : " +
                        location.activity.type,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    location.map.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              ],
            );
          },
          reverse: false,
        );
      },
    );
  }
}

class LogsWidget extends StatelessWidget {
  const LogsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LogModel>>(
      future: GreenLogs.getLogs(),
      initialData: const [],
      builder: (context, snapshot) {
        final logs = snapshot.data;
        if (logs == null || logs.isEmpty) {
          return const Center(child: Text("No locations recorded "));
        }
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final LogModel log = logs[index];
            return ExpansionTile(
              title: Row(
                children: [
                  Text(
                    log.emoji + " " + log.logKey + " " + log.title,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: log.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    log.toMap().toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              ],
            );
          },
          reverse: false,
        );
      },
    );
  }
}
