import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/src/animation_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('AnimationId', () {
    const validId = 'started#51.0,0.0,1.0';
    const validIdWithCustomId = 'started#51.0,0.0,1.0#aCustomId';
    const invalidId = 'invalid#51.0,0.0,1.0';

    group('id', () {
      test('should return a formatted string', () {
        const animationId = AnimationId(
          destLocation: LatLng(51, 0),
          destZoom: 1,
        );

        expect(animationId.id, validId);
      });
    });

    group('parse', () {
      test('should return an AnimationId', () {
        final animationId = AnimationId.parse(validId);

        expect(animationId, isA<AnimationId>());
      });

      test('should return a customId', () {
        final animationId = AnimationId.parse(validIdWithCustomId);

        expect(
          animationId,
          isA<AnimationId>().having(
            (animationId) => animationId.customId,
            'customId',
            'aCustomId',
          ),
        );
      });

      test('should throw an error if the moveId is invalid', () {
        expect(() => AnimationId.parse(invalidId), throwsArgumentError);
      });
    });

    group('tryParse', () {
      test('should return an AnimationId', () {
        final animationId = AnimationId.tryParse(validId);

        expect(animationId, isNotNull);
      });

      test('should return null if the moveId is invalid', () {
        final animationId = AnimationId.tryParse(invalidId);

        expect(animationId, isNull);
      });
    });

    group('fromMapEvent', () {
      test('should return an AnimationId', () {
        final animationId = AnimationId.fromMapEvent(
          MapEventMove(
            oldCamera: MapCamera(
              center: const LatLng(1, 2),
              zoom: 6,
              crs: const CrsSimple(),
              rotation: 0,
              nonRotatedSize: const math.Point(50, 100),
            ),
            camera: MapCamera(
              center: const LatLng(2, 4),
              zoom: 5,
              crs: const CrsSimple(),
              rotation: 0,
              nonRotatedSize: const math.Point(50, 100),
            ),
            source: MapEventSource.custom,
            id: validId,
          ),
        );

        expect(animationId, isNotNull);
      });

      test('should return null if the MapEvent is not a MapEventMove', () {
        final animationId = AnimationId.fromMapEvent(
          MapEventTap(
            camera: MapCamera(
              center: const LatLng(1, 2),
              zoom: 6,
              crs: const CrsSimple(),
              rotation: 0,
              nonRotatedSize: const math.Point(50, 100),
            ),
            source: MapEventSource.custom,
            tapPosition: const LatLng(3, 4),
          ),
        );

        expect(animationId, isNull);
      });
    });
  });
}
