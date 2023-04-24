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
                tileUpdateTransformer: _animatedMoveTileUpdateTransformer,
              ),
              AnimatedMarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: SeparatedColumn(
        mainAxisSize: MainAxisSize.min,
        separator: const SizedBox(height: 8),
        children: [
          FloatingActionButton(
            onPressed: () => _mapController.animatedRotateFrom(90),
            tooltip: 'Rotate 90°',
            child: const Icon(Icons.rotate_right),
          ),
          FloatingActionButton(
            onPressed: () => _mapController.animatedRotateFrom(-90),
            tooltip: 'Rotate -90°',
            child: const Icon(Icons.rotate_left),
          ),
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
          FloatingActionButton(
            onPressed: _mapController.animatedZoomIn,
            tooltip: 'Zoom in',
            child: const Icon(Icons.zoom_in),
          ),
          FloatingActionButton(
            onPressed: _mapController.animatedZoomOut,
            tooltip: 'Zoom out',
            child: const Icon(Icons.zoom_out),
          ),
          FloatingActionButton(
            tooltip: 'Center on markers',
            onPressed: () {
              if (_markers.value.isEmpty) return;

              final points = _markers.value.map((m) => m.point).toList();
              _mapController.centerOnPoints(points);
            },
            child: const Icon(Icons.center_focus_strong),
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
              onTap: () => _mapController.animateTo(dest: point),
              child: Opacity(
                opacity: animation.value,
                child: Icon(
                  Icons.room,
                  size: size,
                ),
              ),
            );
          },
        ),
      );
  }
}

class SeparatedColumn extends StatelessWidget {
  const SeparatedColumn({
    super.key,
    required this.separator,
    this.children = const [],
    this.mainAxisSize = MainAxisSize.max,
  });

  final Widget separator;
  final List<Widget> children;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      children: [
        ..._buildChildren(),
      ],
    );
  }

  Iterable<Widget> _buildChildren() sync* {
    for (var i = 0; i < children.length; i++) {
      yield children[i];
      if (i < children.length - 1) yield separator;
    }
  }
}

/// Inspired by the contribution of [rorystephenson](https://github.com/fleaflet/flutter_map/pull/1475/files#diff-b663bf9f32e20dbe004bd1b58a53408aa4d0c28bcc29940156beb3f34e364556)
final _animatedMoveTileUpdateTransformer =
    TileUpdateTransformer.fromHandlers(handleData: (updateEvent, sink) {
  final mapEvent = updateEvent.mapEvent;

  final id =
      mapEvent is MapEventMove ? AnimationId.tryParse(mapEvent.id) : null;
  if (id != null && id.moveId == AnimatedMoveId.started) {
    sink.add(
      updateEvent.loadOnly(
        loadCenterOverride: id.destLocation,
        loadZoomOverride: id.destZoom,
      ),
    );
  } else if (id?.moveId == AnimatedMoveId.inProgress) {
  } else if (id?.moveId == AnimatedMoveId.finished) {
    sink.add(updateEvent.pruneOnly());
  } else {
    sink.add(updateEvent);
  }
});
