import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

@immutable
class AnimationId {
  const AnimationId({
    this.moveId = AnimatedMoveId.started,
    required this.destLocation,
    required this.destZoom,
  });

  /// Parse the [id] into an [AnimationId] object.
  ///
  /// It expects the [id] to be in the format of:
  /// ```dart
  /// "moveId#latitude,longitude,destZoom"
  /// ```
  factory AnimationId.parse(String id) {
    final parts = id.split('#');
    final moveId = AnimatedMoveId.values.byName(parts[0]);
    final destParts = parts[1].split(',');
    final lat = double.parse(destParts[0]);
    final lng = double.parse(destParts[1]);
    final zoom = double.parse(destParts[2]);

    return AnimationId(
      moveId: moveId,
      destLocation: LatLng(lat, lng),
      destZoom: zoom,
    );
  }

  /// Try to parse the [id] into an [AnimationId] object.
  ///
  /// If the [id] is null or cannot be parsed, it will return null.
  static AnimationId? tryParse(String? id) {
    if (id == null) return null;

    try {
      final animationId = AnimationId.parse(id);
      return animationId;
    } catch (e) {
      return null;
    }
  }

  final AnimatedMoveId moveId;
  final LatLng destLocation;
  final double destZoom;

  String get id {
    return '${moveId.name}#${destLocation.latitude},${destLocation.longitude},$destZoom';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnimationId &&
            runtimeType == other.runtimeType &&
            moveId == other.moveId &&
            destLocation == other.destLocation &&
            destZoom == other.destZoom;
  }

  @override
  int get hashCode => Object.hash(moveId, destLocation, destZoom);

  AnimationId copyWith({
    AnimatedMoveId? moveId,
    LatLng? destLocation,
    double? destZoom,
  }) {
    return AnimationId(
      moveId: moveId ?? this.moveId,
      destLocation: destLocation ?? this.destLocation,
      destZoom: destZoom ?? this.destZoom,
    );
  }
}

enum AnimatedMoveId {
  started,
  inProgress,
  finished;

  static AnimatedMoveId fromAnimationAndTriggeredMove({
    required double animationValue,
    required bool hasTriggeredMove,
  }) {
    final AnimatedMoveId moveId;
    if (animationValue == 1) {
      moveId = AnimatedMoveId.finished;
    } else if (!hasTriggeredMove) {
      moveId = AnimatedMoveId.started;
    } else {
      moveId = AnimatedMoveId.inProgress;
    }
    return moveId;
  }
}
