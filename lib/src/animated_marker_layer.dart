import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/src/animated_marker.dart';

class AnimatedMarkerLayer extends StatelessWidget {
  const AnimatedMarkerLayer({
    super.key,
    this.markers = const [],
    this.rotate = false,
    this.rotateOrigin,
    this.rotateAlignment = Alignment.center,
  });

  final List<AnimatedMarker> markers;
  final bool rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;

  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    final markerWidgets = <Widget>[];

    for (final marker in markers) {
      final pxPoint = map.project(marker.point);

      final rightPortion = marker.width - marker.anchor.left;
      final leftPortion = marker.anchor.left;
      final bottomPortion = marker.height - marker.anchor.top;
      final topPortion = marker.anchor.top;

      final sw =
          CustomPoint(pxPoint.x + leftPortion, pxPoint.y - bottomPortion);
      final ne = CustomPoint(pxPoint.x - rightPortion, pxPoint.y + topPortion);

      if (!map.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
        continue;
      }

      final pos = pxPoint - map.pixelOrigin;
      final markerWidget = (marker.rotate ?? rotate)
          ? Transform.rotate(
              angle: -map.rotationRad,
              origin: marker.rotateOrigin ?? rotateOrigin,
              alignment: marker.rotateAlignment ?? rotateAlignment,
              child: _AnimatedMarkerWidget(marker: marker),
            )
          : _AnimatedMarkerWidget(marker: marker);

      markerWidgets.add(
        Positioned(
          key: marker.key,
          width: marker.width,
          height: marker.height,
          left: pos.x - rightPortion,
          top: pos.y - bottomPortion,
          child: markerWidget,
        ),
      );
    }
    return Stack(
      children: markerWidgets,
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
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.marker.duration,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.marker.curve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnconstrainedBox(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.marker.height,
            maxWidth: widget.marker.width,
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => widget.marker.builder(context, _animation),
          ),
        ),
      );
}
