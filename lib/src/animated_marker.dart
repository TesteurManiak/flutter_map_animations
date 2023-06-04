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
    this.anchorPos,
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

  /// {@template animated_marker_anchor_pos}
  /// Positioning of the [AnimatedMarker.builder] widget relative to the center
  /// of its bounding box defined by its [AnimatedMarker.height] &
  /// [AnimatedMarker.width]
  ///
  /// Overriden on a per [AnimatedMarker] basis if [AnimatedMarker.anchorPos] is
  /// specified.
  /// {@endtemplate}
  final AnchorPos? anchorPos;

  /// If true marker will be counter rotated to the map rotation
  final bool? rotate;

  /// The origin of the coordinate system (relative to the upper left corner of
  /// this render object) in which to apply the matrix.
  ///
  /// Setting an origin is equivalent to conjugating the transform matrix by a
  /// translation. This property is provided just for convenience.
  final Offset? rotateOrigin;

  /// The alignment of the origin, relative to the size of the box.
  ///
  /// This is equivalent to setting an origin based on the size of the box.
  /// If it is specified at the same time as the [rotateOrigin], both are applied.
  ///
  /// An [AlignmentDirectional.centerStart] value is the same as an [Alignment]
  /// whose [Alignment.x] value is `-1.0` if [Directionality.of] returns
  /// [TextDirection.ltr], and `1.0` if [Directionality.of] returns
  /// [TextDirection.rtl].	 Similarly [AlignmentDirectional.centerEnd] is the
  /// same as an [Alignment] whose [Alignment.x] value is `1.0` if
  /// [Directionality.of] returns	 [TextDirection.ltr], and `-1.0` if
  /// [Directionality.of] returns [TextDirection.rtl].
  final AlignmentGeometry? rotateAlignment;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;
}
