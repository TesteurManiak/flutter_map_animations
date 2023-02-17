import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef AnimatedWidgetBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

class AnimatedMarker {
  AnimatedMarker({
    required this.point,
    required this.builder,
    this.key,
    this.width = 30.0,
    this.height = 30.0,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.ease,
    AnchorPos<dynamic>? anchorPos,
  }) : anchor = Anchor.forPos(anchorPos, width, height);

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
}
