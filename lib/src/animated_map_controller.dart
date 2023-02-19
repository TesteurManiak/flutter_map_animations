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

  /// Current rotation of the map.
  ///
  /// This needs to be overridden because the rotation of the map is not
  /// normalized to be between 0° and 360°.
  @override
  double get rotation {
    var effectiveRotation = super.rotation;
    if (effectiveRotation >= 360) {
      effectiveRotation -= 360;
    } else if (effectiveRotation < 0) {
      effectiveRotation += 360;
    }
    return effectiveRotation;
  }

  /// Animate the map to [dest] with an optional [zoom] level and [rotation] in
  /// degrees.
  ///
  /// If specified, [zoom] must be greater or equal to 0.
  Future<void> animateTo({LatLng? dest, double? zoom, double? rotation}) {
    assert(zoom == null || zoom >= 0, 'Zoom must be greater or equal to 0');

    final effectiveRotation = rotation ?? this.rotation;
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
      end: effectiveRotation,
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
  Future<void> centerOnPoint(LatLng point, {double? zoom}) {
    return animateTo(dest: point, zoom: zoom);
  }

  /// Apply a rotation of [degree] to the current rotation.
  Future<void> animatedRotateFrom(double degree) {
    return animateTo(rotation: rotation + degree);
  }

  /// Set the rotation to [degree].
  Future<void> animatedRotateTo(double degree) => animateTo(rotation: degree);

  /// Reset the rotation to 0.
  Future<void> animatedRotateReset() => animateTo(rotation: 0);

  /// Add one level to the current zoom level.
  Future<void> animatedZoomIn() => animateTo(zoom: zoom + 1);

  /// Remove one level to the current zoom level.
  Future<void> animatedZoomOut() async {
    final newZoom = zoom - 1;
    if (newZoom < 0) return;

    return animateTo(zoom: newZoom);
  }

  /// Set the zoom level to [newZoom].
  ///
  /// [newZoom] must be greater or equal to 0.
  Future<void> animatedZoomTo(double newZoom) => animateTo(zoom: newZoom);
}
