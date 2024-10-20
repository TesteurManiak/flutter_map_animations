import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

typedef AnimatedWidgetBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

@immutable
class AnimatedMarker {
  const AnimatedMarker({
    required this.point,
    required this.builder,
    this.key,
    this.width = 30.0,
    this.height = 30.0,
    this.rotate,
    this.alignment,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.ease,
  });

  /// Coordinates of the marker
  final LatLng point;

  /// Function that builds UI of the marker
  final AnimatedWidgetBuilder builder;

  /// Key of the marker
  final Key? key;

  /// Bounding box width of the marker
  final double width;

  /// Bounding box height of the marker
  final double height;

  final Alignment? alignment;

  /// If true marker will be counter rotated to the map rotation
  final bool? rotate;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  AnimatedMarker copyWith({
    LatLng? point,
    Key? key,
    double? width,
    double? height,
    bool? rotate,
    Alignment? alignment,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedMarker(
      point: point ?? this.point,
      key: key ?? this.key,
      width: width ?? this.width,
      height: height ?? this.height,
      rotate: rotate ?? this.rotate,
      alignment: alignment ?? this.alignment,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      builder: builder,
    );
  }
}
