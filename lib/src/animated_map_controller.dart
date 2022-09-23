import 'package:flutter/animation.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMapController extends MapControllerImpl {
  AnimatedMapController({
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastOutSlowIn,
  });

  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;

  Future<void> animatedTo({LatLng? dest, double? zoom, double? rotation}) {
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

  Future<void> animatedRotateFrom(double degree) =>
      animatedTo(rotation: rotation + degree);
  Future<void> animatedRotateTo(double degree) => animatedTo(rotation: degree);
  Future<void> animatedRotateReset() => animatedTo(rotation: 0);

  Future<void> animatedZoomIn() => animatedTo(zoom: zoom + 1);
  Future<void> animatedZoomOut() => animatedTo(zoom: zoom - 1);
  Future<void> animatedZoomTo(double newZoom) => animatedTo(zoom: newZoom);
}
