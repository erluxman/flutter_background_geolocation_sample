import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Text("Locations")),
                Tab(icon: Text("Headless Events")),
              ],
            ),
            title: const Text('Tabs Demo'),
          ),
          body: const TabBarView(
            children: [
              LocationsWidget(),
              HeadlessEventsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class HeadlessEventsWidget extends StatelessWidget {
  const HeadlessEventsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("this is headless events list"),
    );
  }
}

class LocationsWidget extends StatelessWidget {
  const LocationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Collected locations list"),
    );
  }
}
