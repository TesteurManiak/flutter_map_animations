import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/src/animated_marker.dart';

class AnimatedMarkerLayer extends StatelessWidget {
  const AnimatedMarkerLayer({
    super.key,
    this.markers = const [],
    this.anchorPos,
    this.rotate = false,
    this.rotateOrigin,
    this.rotateAlignment = Alignment.center,
  });

  final List<AnimatedMarker> markers;

  /// {@macro animated_marker_anchor_pos}
  final AnchorPos? anchorPos;

  /// If true markers will be counter rotated to the map rotation.
  final bool rotate;

  /// The origin of the coordinate system (relative to the upper left corner of
  /// this render object) in which to apply the matrix.
  ///
  /// Setting an origin is equivalent to conjugating the transform matrix by a
  /// translation. This property is provided just for convenience.
  final Offset? rotateOrigin;

  /// The alignment of the origin, relative to the size of the box.
  ///
  /// This is equivalent to setting an origin based on the size of the box.
  /// If it is specified at the same time as the [rotateOrigin], both are
  /// applied.
  ///
  /// An [AlignmentDirectional.centerStart] value is the same as an [Alignment]
  /// whose [Alignment.x] value is `-1.0` if [Directionality.of] returns
  /// [TextDirection.ltr], and `1.0` if [Directionality.of] returns
  /// [TextDirection.rtl].	 Similarly [AlignmentDirectional.centerEnd] is the
  /// same as an [Alignment] whose [Alignment.x] value is `1.0` if
  /// [Directionality.of] returns	 [TextDirection.ltr], and `-1.0` if
  /// [Directionality.of] returns [TextDirection.rtl].
  final AlignmentGeometry rotateAlignment;

  @override
  Widget build(BuildContext context) {
    final mapCamera = MapCamera.maybeOf(context);
    if (mapCamera == null) {
      throw StateError('No FlutterMapState found.');
    }

    final markerWidgets = <Widget>[];

    for (final marker in markers) {
      final pxPoint = mapCamera.project(marker.point);

      // See if any portion of the Marker rect resides in the map bounds
      // If not, don't spend any resources on build function.
      // This calculation works for any Anchor position whithin the Marker
      // Note that Anchor coordinates of (0,0) are at bottom-right of the Marker
      // unlike the map coordinates.
      final anchor = Anchor.fromPos(
        marker.anchorPos ?? anchorPos ?? AnchorPos.defaultAnchorPos,
        marker.width,
        marker.height,
      );

      final rightPortion = marker.width - anchor.left;
      final leftPortion = anchor.left;
      final bottomPortion = marker.height - anchor.top;
      final topPortion = anchor.top;

      final sw = math.Point(
        pxPoint.x + leftPortion,
        pxPoint.y - bottomPortion,
      );
      final ne = math.Point(pxPoint.x - rightPortion, pxPoint.y + topPortion);

      if (!mapCamera.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
        continue;
      }

      final pos = pxPoint - mapCamera.pixelOrigin.toDoublePoint();
      final markerWidget = (marker.rotate ?? rotate)
          ? Transform.rotate(
              angle: -mapCamera.rotationRad,
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
