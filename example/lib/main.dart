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
  final _markerSize = 50.0;
  final _markers = ValueNotifier<List<AnimatedMarker>>([]);
  final _center = LatLng(51.509364, -0.128928);

  late final _mapController = AnimatedMapController(vsync: this);

  @override
  void dispose() {
    _markers.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<AnimatedMarker>>(
        valueListenable: _markers,
        builder: (context, markers, _) {
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _center,
              onTap: (_, point) => _addMarker(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              AnimatedMarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            onPressed: () {
              _markers.value = [];
              _mapController.animateTo(
                dest: _center,
                rotation: 0,
              );
            },
            tooltip: 'Clear modifications',
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

  void _addMarker(LatLng point) {
    _markers.value = List.from(_markers.value)
      ..add(
        AnimatedMarker(
          point: point,
          width: _markerSize,
          height: _markerSize,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (context, animation) {
            final size = _markerSize * animation.value;
            return GestureDetector(
              onTap: () => debugPrint('tapped on marker'),
              child: Icon(
                Icons.room,
                size: size,
              ),
            );
          },
        ),
      );
  }
}
