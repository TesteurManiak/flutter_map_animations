import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(vsync: this);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(51.509364, -0.128928),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => _mapController.animateTo(
              dest: LatLng(48.5, 2.2),
              zoom: 5,
            ),
            tooltip: 'Animate to Paris',
            child: const Icon(Icons.zoom_in_map),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => _mapController.animatedRotateFrom(90),
            tooltip: 'Rotate 90°',
            child: const Icon(Icons.rotate_right),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => _mapController.animatedRotateFrom(-90),
            tooltip: 'Rotate -90°',
            child: const Icon(Icons.rotate_left),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _mapController.animatedRotateReset,
            tooltip: 'Reset rotation',
            child: const Icon(Icons.clear_all),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _mapController.animatedZoomIn,
            tooltip: 'Zoom in',
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _mapController.animatedZoomOut,
            tooltip: 'Zoom out',
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}
