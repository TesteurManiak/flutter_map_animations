import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
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
  static const _useTransformerId = 'useTransformerId';

  final markers = ValueNotifier<List<AnimatedMarker>>([]);
  final center = const LatLng(51.509364, -0.128928);

  bool _useTransformer = true;
  int _lastMovedToMarkerIndex = -1;

  late final _animatedMapController = AnimatedMapController(vsync: this);

  @override
  void dispose() {
    markers.dispose();
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<AnimatedMarker>>(
        valueListenable: markers,
        builder: (context, markers, _) {
          return FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: center,
              onTap: (_, point) => _addMarker(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                tileUpdateTransformer: _animatedMoveTileUpdateTransformer,
                tileProvider: CancellableNetworkTileProvider(),
              ),
              AnimatedMarkerLayer(markers: markers, culling: false),
            ],
          );
        },
      ),
      floatingActionButton: SeparatedColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        separator: const SizedBox(height: 8),
        children: [
          FloatingActionButton(
            onPressed: () => _animatedMapController.animatedRotateFrom(
              90,
              customId: _useTransformer ? _useTransformerId : null,
            ),
            tooltip: 'Rotate 90°',
            child: const Icon(Icons.rotate_right),
          ),
          FloatingActionButton(
            onPressed: () => _animatedMapController.animatedRotateFrom(
              -90,
              customId: _useTransformer ? _useTransformerId : null,
            ),
            tooltip: 'Rotate -90°',
            child: const Icon(Icons.rotate_left),
          ),
          FloatingActionButton(
            onPressed: () {
              markers.value = [];
              _animatedMapController.animateTo(
                dest: center,
                rotation: 0,
                customId: _useTransformer ? _useTransformerId : null,
              );
            },
            tooltip: 'Clear modifications',
            child: const Icon(Icons.clear_all),
          ),
          FloatingActionButton(
            onPressed: () => _animatedMapController.animatedZoomIn(
              customId: _useTransformer ? _useTransformerId : null,
            ),
            tooltip: 'Zoom in',
            child: const Icon(Icons.zoom_in),
          ),
          FloatingActionButton(
            onPressed: () => _animatedMapController.animatedZoomOut(
              customId: _useTransformer ? _useTransformerId : null,
            ),
            tooltip: 'Zoom out',
            child: const Icon(Icons.zoom_out),
          ),
          FloatingActionButton(
            tooltip: 'Center on markers',
            onPressed: () {
              if (markers.value.length < 2) return;

              final points = markers.value.map((m) => m.point).toList();
              _animatedMapController.animatedFitCamera(
                cameraFit: CameraFit.coordinates(
                  coordinates: points,
                  padding: const EdgeInsets.all(12),
                ),
                rotation: 0,
                customId: _useTransformer ? _useTransformerId : null,
              );
            },
            child: const Icon(Icons.center_focus_strong),
          ),
          FloatingActionButton(
            tooltip: 'Move last marker to center',
            onPressed: () {
              if (markers.value.isEmpty) return;

              final newMarkers = List.of(markers.value);
              final lastMarker = newMarkers.removeLast().copyWith(
                    point: _animatedMapController.mapController.camera.center,
                    animatePosition: true,
                  );
              newMarkers.add(lastMarker);
              markers.value = newMarkers;
            },
            child: const Icon(Icons.play_arrow_rounded),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                tooltip: 'Move to next marker with offset',
                onPressed: () {
                  if (markers.value.isEmpty) return;

                  final points = markers.value.map((m) => m.point);
                  setState(
                    () => _lastMovedToMarkerIndex =
                        (_lastMovedToMarkerIndex + 1) % points.length,
                  );

                  _animatedMapController.animateTo(
                    dest: points.elementAt(_lastMovedToMarkerIndex),
                    customId: _useTransformer ? _useTransformerId : null,
                    offset: const Offset(100, 100),
                  );
                },
                child: const Icon(Icons.multiple_stop),
              ),
              const SizedBox.square(dimension: 8),
              FloatingActionButton(
                tooltip: 'Move to next marker',
                onPressed: () {
                  if (markers.value.isEmpty) return;

                  final points = markers.value.map((m) => m.point);
                  setState(
                    () => _lastMovedToMarkerIndex =
                        (_lastMovedToMarkerIndex + 1) % points.length,
                  );

                  _animatedMapController.animateTo(
                    dest: points.elementAt(_lastMovedToMarkerIndex),
                    customId: _useTransformer ? _useTransformerId : null,
                  );
                },
                child: const Icon(Icons.polyline_rounded),
              ),
            ],
          ),
          FloatingActionButton.extended(
            label: Row(
              children: [
                const Text('Transformer'),
                Switch(
                  activeColor: Colors.blue.shade200,
                  activeTrackColor: Colors.black38,
                  value: _useTransformer,
                  onChanged: (newValue) {
                    setState(() => _useTransformer = newValue);
                  },
                ),
              ],
            ),
            onPressed: () {
              setState(() => _useTransformer = !_useTransformer);
            },
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng point) {
    markers.value = List.from(markers.value)
      ..add(
        MyMarker(
          point: point,
          onTap: () => _animatedMapController.animateTo(
            dest: point,
            customId: _useTransformer ? _useTransformerId : null,
          ),
        ),
      );
  }
}

class MyMarker extends AnimatedMarker {
  MyMarker({
    required super.point,
    VoidCallback? onTap,
  }) : super(
          width: markerSize,
          height: markerSize,
          builder: (context, animation) {
            final size = markerSize * animation.value;

            return GestureDetector(
              onTap: onTap,
              child: Opacity(
                opacity: animation.value,
                child: Icon(
                  Icons.room,
                  size: size,
                ),
              ),
            );
          },
        );

  static const markerSize = 50.0;
}

class SeparatedColumn extends StatelessWidget {
  const SeparatedColumn({
    super.key,
    required this.separator,
    this.children = const [],
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final Widget separator;
  final List<Widget> children;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
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
final _animatedMoveTileUpdateTransformer = TileUpdateTransformer.fromHandlers(
  handleData: (updateEvent, sink) {
    final id = AnimationId.fromMapEvent(updateEvent.mapEvent);

    if (id == null) return sink.add(updateEvent);
    if (id.customId != _MyHomePageState._useTransformerId) {
      if (id.moveId == AnimatedMoveId.started) {
        debugPrint('TileUpdateTransformer disabled, using default behaviour.');
      }
      return sink.add(updateEvent);
    }

    switch (id.moveId) {
      case AnimatedMoveId.started:
        debugPrint('Loading tiles at animation destination.');
        sink.add(
          updateEvent.loadOnly(
            loadCenterOverride: id.destLocation,
            loadZoomOverride: id.destZoom,
          ),
        );
        break;
      case AnimatedMoveId.inProgress:
        // Do not prune or load during movement.
        break;
      case AnimatedMoveId.finished:
        debugPrint('Pruning tiles after animated movement.');
        sink.add(updateEvent.pruneOnly());
        break;
    }
  },
);
