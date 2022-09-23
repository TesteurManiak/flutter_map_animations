import 'package:flutter/animation.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

/// A [MapController] that provides animated methods.
class AnimatedMapController extends MapControllerImpl {
  AnimatedMapController({
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastOutSlowIn,
  });

  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;

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

  Future<void> centerOnPoint(LatLng point, {double? zoom}) =>
      animateTo(dest: point, zoom: zoom);

  Future<void> animatedRotateFrom(double degree) =>
      animateTo(rotation: rotation + degree);
  Future<void> animatedRotateTo(double degree) => animateTo(rotation: degree);
  Future<void> animatedRotateReset() => animateTo(rotation: 0);

  Future<void> animatedZoomIn() => animateTo(zoom: zoom + 1);
  Future<void> animatedZoomOut() => animateTo(zoom: zoom - 1);
  Future<void> animatedZoomTo(double newZoom) => animateTo(zoom: newZoom);
}
