import 'package:flutter/animation.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

/// A [MapController] that provides animated methods.
class AnimatedMapController extends MapControllerImpl {
  /// Creates a [MapController] that provides animated methods.
  AnimatedMapController({
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastOutSlowIn,
  });

  /// The vsync of the animation.
  final TickerProvider vsync;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  /// Animate the map to [dest] with an optional [zoom] level and [rotation] in
  /// degrees.
  Future<void> animateTo({LatLng? dest, double? zoom, double? rotation}) {
    final latTween = Tween<double>(
      begin: center.latitude,
      end: dest?.latitude ?? center.latitude,
    );
    final lngTween = Tween<double>(
      begin: center.longitude,
      end: dest?.longitude ?? center.longitude,
    );
    final zoomTween = Tween<double>(
      begin: this.zoom,
      end: zoom ?? this.zoom,
    );
    final rotateTween = Tween<double>(
      begin: this.rotation,
      end: rotation ?? this.rotation,
    );

    // This controller will be disposed when the animation is completed.
    final animationController = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    final animation = CurvedAnimation(
      parent: animationController,
      curve: curve,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          animationController.dispose();
        }
      });

    animationController.addListener(() {
      move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
      rotate(rotateTween.evaluate(animation));
    });

    return animationController.forward();
  }

  /// Center the map on [point] with an optional [zoom] level.
  Future<void> centerOnPoint(LatLng point, {double? zoom}) =>
      animateTo(dest: point, zoom: zoom);

  /// Apply a rotation of [degree] to the current rotation.
  Future<void> animatedRotateFrom(double degree) =>
      animateTo(rotation: rotation + degree);

  /// Set the rotation to [degree].
  Future<void> animatedRotateTo(double degree) => animateTo(rotation: degree);

  /// Reset the rotation to 0.
  Future<void> animatedRotateReset() => animateTo(rotation: 0);

  /// Add one level to the current zoom level.
  Future<void> animatedZoomIn() => animateTo(zoom: zoom + 1);

  /// Remove one level to the current zoom level.
  Future<void> animatedZoomOut() => animateTo(zoom: zoom - 1);

  /// Set the zoom level to [newZoom].
  Future<void> animatedZoomTo(double newZoom) => animateTo(zoom: newZoom);
}
