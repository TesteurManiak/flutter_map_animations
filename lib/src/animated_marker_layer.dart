import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/src/animated_marker.dart';

class AnimatedMarkerLayer extends StatelessWidget {
  const AnimatedMarkerLayer({
    super.key,
    required this.markers,
    this.rotate = false,
    this.alignment = Alignment.center,
  });

  final List<AnimatedMarker> markers;

  /// If true markers will be counter rotated to the map rotation.
  final bool rotate;

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final mapCamera = MapCamera.maybeOf(context);
    if (mapCamera == null) {
      throw StateError('No FlutterMapState found.');
    }

    return MobileLayerTransformer(
      child: Stack(
        children: (List<AnimatedMarker> markers) sync* {
          for (final m in markers) {
            // Resolve real alignment
            final left = 0.5 * m.width * ((m.alignment ?? alignment).x + 1);
            final top = 0.5 * m.height * ((m.alignment ?? alignment).y + 1);
            final right = m.width - left;
            final bottom = m.height - top;

            // Perform projection
            final pxPoint = mapCamera.project(m.point);

            // Cull if out of bounds
            if (!mapCamera.pixelBounds.containsPartialBounds(
              Bounds(
                Point(pxPoint.x + left, pxPoint.y - bottom),
                Point(pxPoint.x - right, pxPoint.y + top),
              ),
            )) continue;

            // Apply map camera to marker position
            final pos = pxPoint - mapCamera.pixelOrigin.toDoublePoint();

            yield Positioned(
              key: m.key,
              width: m.width,
              height: m.height,
              left: pos.x - right,
              top: pos.y - bottom,
              child: (m.rotate ?? rotate)
                  ? Transform.rotate(
                      angle: -mapCamera.rotationRad,
                      alignment: (m.alignment ?? alignment) * -1,
                      child: _AnimatedMarkerWidget(marker: m),
                    )
                  : _AnimatedMarkerWidget(marker: m),
            );
          }
        }(markers)
            .toList(),
      ),
    );
  }
}

class _AnimatedMarkerWidget extends StatefulWidget {
  const _AnimatedMarkerWidget({
    required this.marker,
  });

  final AnimatedMarker marker;

  @override
  State<_AnimatedMarkerWidget> createState() => _AnimatedMarkerWidgetState();
}

class _AnimatedMarkerWidgetState extends State<_AnimatedMarkerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.marker.duration,
    )..forward();

    animation = CurvedAnimation(
      parent: controller,
      curve: widget.marker.curve,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.marker.height,
          maxWidth: widget.marker.width,
        ),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => widget.marker.builder(context, animation),
        ),
      ),
    );
  }
}
