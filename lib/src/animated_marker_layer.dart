import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

typedef AnimatedWidgetBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

class AnimatedMarker {
  final LatLng point;
  final AnimatedWidgetBuilder builder;
  final Key? key;
  final double width;
  final double height;
  final Anchor anchor;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  final Duration duration;
  final Curve curve;

  AnimatedMarker({
    required this.point,
    required this.builder,
    this.key,
    this.width = 30.0,
    this.height = 30.0,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOutCirc,
    AnchorPos<dynamic>? anchorPos,
  }) : anchor = Anchor.forPos(anchorPos, width, height);
}

class AnimatedMarkerLayer extends StatelessWidget {
  final List<AnimatedMarker> markers;
  final bool rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;

  const AnimatedMarkerLayer({
    super.key,
    this.markers = const [],
    this.rotate = false,
    this.rotateOrigin,
    this.rotateAlignment = Alignment.center,
  });

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
  final AnimatedMarker marker;

  const _AnimatedMarkerWidget({
    required this.marker,
  });

  @override
  State<_AnimatedMarkerWidget> createState() => _AnimatedMarkerWidgetState();
}

class _AnimatedMarkerWidgetState extends State<_AnimatedMarkerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  late final _widthTween = Tween<double>(begin: 0.0, end: widget.marker.width);
  late final _heightTween =
      Tween<double>(begin: 0.0, end: widget.marker.height);

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
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return SizedBox(
            width: _widthTween.evaluate(_animation),
            height: _heightTween.evaluate(_animation),
            child: widget.marker.builder(context, _animation),
          );
        },
      ),
    );
  }
}
