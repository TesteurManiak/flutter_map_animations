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
        children: () sync* {
          for (final m in markers) {
            // Resolve real alignment
            final effectiveAlignment = m.alignment ?? alignment;
            final left = 0.5 * m.width * (effectiveAlignment.x + 1);
            final top = 0.5 * m.height * (effectiveAlignment.y + 1);
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

            yield _MarkerPosition(
              alignment: effectiveAlignment,
              rotate: rotate,
              pos: pos,
              marker: m,
            );
          }
        }()
            .toList(),
      ),
    );
  }
}

class _MarkerPosition extends StatefulWidget {
  const _MarkerPosition({
    required this.rotate,
    required this.alignment,
    required this.pos,
    required this.marker,
  });

  final bool rotate;
  final Alignment alignment;
  final Point<double> pos;
  final AnimatedMarker marker;

  @override
  State<_MarkerPosition> createState() => _MarkerPositionState();
}

class _MarkerPositionState extends State<_MarkerPosition>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  late Tween<double> leftTween;
  late Tween<double> topTween;

  double get left => 0.5 * widget.marker.width * (widget.alignment.x + 1);
  double get top => 0.5 * widget.marker.height * (widget.alignment.y + 1);
  double get right => widget.marker.width - left;
  double get bottom => widget.marker.height - top;

  double calcLeftPos(Point<double> pos) => pos.x - right;
  double calcTopPos(Point<double> pos) => pos.y - bottom;

  @override
  void initState() {
    super.initState();

    final leftPos = calcLeftPos(widget.pos);
    final topPos = calcTopPos(widget.pos);

    leftTween = Tween<double>(begin: leftPos);
    topTween = Tween<double>(begin: topPos);
    controller = AnimationController(
      vsync: this,
      duration: widget.marker.duration,
    );
  }

  @override
  void didUpdateWidget(covariant _MarkerPosition oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldPos = oldWidget.pos;
    final newPos = widget.pos;
    if (oldPos != newPos) {
      leftTween =
          Tween<double>(begin: calcLeftPos(oldPos), end: calcLeftPos(newPos));
      topTween =
          Tween<double>(begin: calcTopPos(oldPos), end: calcTopPos(newPos));
      controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapCamera = MapCamera.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final left = leftTween.evaluate(controller);
        final top = topTween.evaluate(controller);
        return Positioned(
          key: widget.marker.key,
          width: widget.marker.width,
          height: widget.marker.height,
          left: left,
          top: top,
          child: (widget.marker.rotate ?? widget.rotate)
              ? Transform.rotate(
                  angle: -mapCamera.rotationRad,
                  alignment: widget.alignment * -1,
                  child: _AnimatedMarkerWidget(widget.marker),
                )
              : _AnimatedMarkerWidget(widget.marker),
        );
      },
    );
  }
}

class _AnimatedMarkerWidget extends StatefulWidget {
  const _AnimatedMarkerWidget(this.marker);

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
