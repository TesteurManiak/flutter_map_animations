import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/src/animation_extensions.dart';
import 'package:flutter_map_animations/src/animation_id.dart';
import 'package:flutter_map_animations/src/lat_lng_tween.dart';
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
    double effectiveRotation = super.rotation;
    if (effectiveRotation >= 360) {
      effectiveRotation -= 360;
    } else if (effectiveRotation < 0) {
      effectiveRotation += 360;
    }
    return effectiveRotation;
  }

  /// Controller of the current animation.
  AnimationController? _animationController;

  @override
  void dispose() {
    final isAnimating = _animationController?.isAnimating ?? false;
    if (isAnimating) {
      _animationController?.stop();
    }
    _animationController?.dispose();
    super.dispose();
  }

  /// Animate the map to [dest] with an optional [zoom] level and [rotation] in
  /// degrees.
  ///
  /// If specified, [zoom] must be greater or equal to 0.
  ///
  /// {@template animated_map_controller.animate_to.curve}
  /// If [curve] is not specified, the one specified in the constructor will be
  /// used.
  /// {@endtemplate}
  Future<void> animateTo({
    LatLng? dest,
    double? zoom,
    double? rotation,
    Curve? curve,
  }) {
    if (zoom != null && zoom < 0) {
      throw ArgumentError.value(
        zoom,
        'zoom',
        'Zoom must be greater or equal to 0',
      );
    }

    final effectiveDest = dest ?? center;
    final effectiveZoom = zoom ?? this.zoom;
    final effectiveRotation = rotation ?? this.rotation;
    final latLngTween = LatLngTween(
      begin: center,
      end: effectiveDest,
    );
    final zoomTween = Tween<double>(
      begin: this.zoom,
      end: effectiveZoom,
    );
    double startRotation = this.rotation;
    double endRotation = effectiveRotation;

    // If the difference between the bearings is greater than 180 degrees,
    // add or subtract 360 degrees to one of them to make the shortest
    // rotation direction counterclockwise.
    final diff = endRotation - startRotation;
    if (diff > 180.0) {
      startRotation += 360.0;
    } else if (diff < -180.0) {
      endRotation += 360.0;
    }

    final rotateTween = Tween<double>(
      begin: startRotation,
      end: endRotation,
    );

    // This controller will be disposed when the animation is completed.
    final animationController = AnimationController(
      vsync: vsync,
      duration: duration,
    );
    _animationController = animationController;

    final animation = CurvedAnimation(
      parent: animationController,
      curve: curve ?? this.curve,
    )..onEnd(() {
        animationController.dispose();
        _animationController = null;
      });

    AnimationId animationId = AnimationId(
      destLocation: effectiveDest,
      destZoom: effectiveZoom,
    );

    bool hasTriggeredMove = false;

    animationController.addListener(() {
      animationId = animationId.copyWith(
        moveId: AnimatedMoveId.fromAnimationAndTriggeredMove(
          animationValue: animation.value,
          hasTriggeredMove: hasTriggeredMove,
        ),
      );

      hasTriggeredMove |= move(
        latLngTween.evaluate(animation),
        zoomTween.evaluate(animation),
        id: animationId.id,
      );
      rotate(rotateTween.evaluate(animation));
    });

    return animationController.forward();
  }

  /// Center the map on [point] with an optional [zoom] level.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> centerOnPoint(LatLng point, {double? zoom, Curve? curve}) {
    return animateTo(dest: point, zoom: zoom, curve: curve);
  }

  /// Apply a rotation of [degree] to the current rotation.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> animatedRotateFrom(double degree, {Curve? curve}) {
    return animateTo(rotation: rotation + degree, curve: curve);
  }

  /// Set the rotation to [degree].
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> animatedRotateTo(double degree, {Curve? curve}) {
    return animateTo(rotation: degree, curve: curve);
  }

  /// Reset the rotation to 0.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> animatedRotateReset({Curve? curve}) {
    return animateTo(rotation: 0, curve: curve);
  }

  /// Add one level to the current zoom level.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> animatedZoomIn({Curve? curve}) {
    return animateTo(zoom: zoom + 1, curve: curve);
  }

  /// Remove one level to the current zoom level.
  ///
  /// If the current zoom level is 0, nothing will happen.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  FutureOr<void> animatedZoomOut({Curve? curve}) {
    final newZoom = zoom - 1;
    if (newZoom < 0) return null;

    return animateTo(zoom: newZoom, curve: curve);
  }

  /// Set the zoom level to [newZoom].
  ///
  /// [newZoom] must be greater or equal to 0.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> animatedZoomTo(double newZoom, {Curve? curve}) {
    return animateTo(zoom: newZoom, curve: curve);
  }

  /// Will use the [centerZoomFitBounds] method with [bounds] and [options] to
  /// calculate the center and zoom level and then animate to that position.
  ///
  /// If [options] is not specified, it will use a default padding of 12.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> animatedFitBounds(
    LatLngBounds bounds, {
    FitBoundsOptions? options,
    Curve? curve,
  }) {
    final localOptions =
        options ?? const FitBoundsOptions(padding: EdgeInsets.all(12));
    final centerZoom = centerZoomFitBounds(bounds, options: localOptions);

    return animateTo(
      dest: centerZoom.center,
      zoom: centerZoom.zoom,
      curve: curve,
    );
  }

  /// Will use the [LatLngBounds.fromPoints] method to calculate the bounds of
  /// the [points] and then use the [animatedFitBounds] method to animate to
  /// that position.
  ///
  /// If [options] is not specified, it will use a default padding of 12.
  ///
  /// {@macro animated_map_controller.animate_to.curve}
  Future<void> centerOnPoints(
    List<LatLng> points, {
    FitBoundsOptions? options,
    Curve? curve,
  }) {
    final bounds = LatLngBounds.fromPoints(points);

    return animatedFitBounds(bounds, options: options, curve: curve);
  }
}
