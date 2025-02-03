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
    final map = MapCamera.maybeOf(context);
    if (map == null) {
      throw StateError('No FlutterMapState found.');
    }
    final worldWidth = map.getWorldWidthAtZoom();

    // Copies `MarkerLayer` implementation
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
            final pxPoint = map.projectAtZoom(m.point);

            Positioned? getPositioned(double worldShift) {
              final shiftedX = pxPoint.dx + worldShift;

              // Cull if out of bounds
              if (!map.pixelBounds.overlaps(
                Rect.fromPoints(
                  Offset(shiftedX + left, pxPoint.dy - bottom),
                  Offset(shiftedX - right, pxPoint.dy + top),
                ),
              )) {
                return null;
              }

              // Shift original coordinate along worlds, then move into relative
              // to origin space
              final shiftedLocalPoint =
                  Offset(shiftedX, pxPoint.dy) - map.pixelOrigin;

              return Positioned(
                key: m.key,
                width: m.width,
                height: m.height,
                left: shiftedLocalPoint.dx - right,
                top: shiftedLocalPoint.dy - bottom,
                child: (m.rotate ?? rotate)
                    ? Transform.rotate(
                        angle: -map.rotationRad,
                        alignment: (m.alignment ?? alignment) * -1,
                        child: _AnimatedMarkerWidget(marker: m),
                      )
                    : _AnimatedMarkerWidget(marker: m),
              );
            }

            // Create marker in main world, unless culled
            final main = getPositioned(0);
            if (main != null) yield main;
            // It is unsafe to assume that if the main one is culled, it will
            // also be culled in all other worlds, so we must continue

            // Repeat over all worlds (<--||-->) until culling determines that
            // that marker is out of view, and therefore all further markers in
            // that direction will also be
            if (worldWidth == 0) continue;
            for (double shift = -worldWidth;; shift -= worldWidth) {
              final additional = getPositioned(shift);
              if (additional == null) break;
              yield additional;
            }
            for (double shift = worldWidth;; shift += worldWidth) {
              final additional = getPositioned(shift);
              if (additional == null) break;
              yield additional;
            }
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
