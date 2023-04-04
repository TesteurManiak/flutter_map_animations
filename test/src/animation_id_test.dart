import 'package:flutter_map_animations/src/animation_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('AnimationId', () {
    const validId = 'started#51.0,0.0,1.0';
    const invalidId = 'invalid#51.0,0.0,1.0';

    group('id', () {
      test('should return a formatted string', () {
        final animationId = AnimationId(
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
  });
}
