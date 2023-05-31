import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

@immutable
class AnimationId {
  const AnimationId({
    this.moveId = AnimatedMoveId.started,
    required this.destLocation,
    required this.destZoom,
    this.customId,
  });

  /// Parse the [id] into an [AnimationId] object.
  ///
  /// It expects the [id] to be in the format of:
  /// ```dart
  /// "moveId#latitude,longitude,destZoom[#customId]"
  /// ```
  factory AnimationId.parse(String id) {
    final parts = id.split('#');
    final moveId = AnimatedMoveId.values.byName(parts[0]);
    final destParts = parts[1].split(',');
    final lat = double.parse(destParts[0]);
    final lng = double.parse(destParts[1]);
    final zoom = double.parse(destParts[2]);
    final customId = parts.length == 3 ? parts[2] : null;

    return AnimationId(
      moveId: moveId,
      destLocation: LatLng(lat, lng),
      destZoom: zoom,
      customId: customId,
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

  static AnimationId? fromMapEvent(MapEvent mapEvent) {
    if (mapEvent is MapEventMove) return tryParse(mapEvent.id);
    if (mapEvent is MapEventRotate) return tryParse(mapEvent.id);
    return null;
  }

  final AnimatedMoveId moveId;
  final LatLng destLocation;
  final double destZoom;
  final String? customId;

  String get id {
    return '${moveId.name}#'
        '${destLocation.latitude},${destLocation.longitude},$destZoom'
        '${customId == null ? '' : '#$customId'}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnimationId &&
            runtimeType == other.runtimeType &&
            moveId == other.moveId &&
            destLocation == other.destLocation &&
            destZoom == other.destZoom &&
            customId == other.customId;
  }

  @override
  int get hashCode => Object.hash(moveId, destLocation, destZoom, customId);

  AnimationId copyWith({
    AnimatedMoveId? moveId,
    LatLng? destLocation,
    double? destZoom,
    String? customid,
  }) {
    return AnimationId(
      moveId: moveId ?? this.moveId,
      destLocation: destLocation ?? this.destLocation,
      destZoom: destZoom ?? this.destZoom,
      customId: customId,
    );
  }
}

enum AnimatedMoveId {
  started,
  inProgress,
  finished;

  static AnimatedMoveId fromAnimationAndTriggeredMove({
    required bool animationIsCompleted,
    required bool hasTriggeredMove,
  }) {
    final AnimatedMoveId moveId;
    if (animationIsCompleted) {
      moveId = AnimatedMoveId.finished;
    } else if (!hasTriggeredMove) {
      moveId = AnimatedMoveId.started;
    } else {
      moveId = AnimatedMoveId.inProgress;
    }
    return moveId;
  }
}
