import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// An interpolation between two LatLng instances.
class LatLngTween extends Tween<LatLng> {
  /// Creates a [LatLng] tween.
  LatLngTween({
    required LatLng super.begin,
    required LatLng super.end,
  });

  /// Returns the value this variable has at the given animation clock value.
  @override
  LatLng lerp(double t) {
    final lat = _lerpDouble(begin?.latitude, end?.latitude, t);
    final lng = _lerpDouble(begin?.longitude, end?.longitude, t);

    return LatLng(lat, lng);
  }

  double _lerpDouble(double? a, double? b, double t) {
    final localA = a ?? 0;
    final localB = b ?? 0;

    return localA + (localB - localA) * t;
  }
}
