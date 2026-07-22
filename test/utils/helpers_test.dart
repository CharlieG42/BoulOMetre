import 'package:flutter_test/flutter_test.dart';
import 'package:boul_o_metre/utils/helpers.dart';
import 'dart:math';

void main() {
  group('Helpers Tests', () {
    // Test de formatDistance
    test('formatDistance with integer value', () {
      expect(Helpers.formatDistance(100), '100,0 cm');
    });

    test('formatDistance with decimal value', () {
      expect(Helpers.formatDistance(123.456), '123,5 cm');
    });

    test('formatDistance with zero', () {
      expect(Helpers.formatDistance(0), '0,0 cm');
    });

    // Test de formatAngle
    test('formatAngle with 0 radians', () {
      expect(Helpers.formatAngle(0), '0,0°');
    });

    test('formatAngle with pi/2 radians (90 degrees)', () {
      expect(Helpers.formatAngle(pi / 2), '90,0°');
    });

    test('formatAngle with pi radians (180 degrees)', () {
      expect(Helpers.formatAngle(pi), '180,0°');
    });

    // Test de isPointInCircle
    test('isPointInCircle with point inside circle', () {
      // Cercle centré en (0,0) avec rayon 10
      // Point (5,5) est à une distance de sqrt(50) ≈ 7.07 < 10
      expect(Helpers.isPointInCircle(5, 5, 0, 0, 10), true);
    });

    test('isPointInCircle with point on circle edge', () {
      // Point (10,0) est exactement sur le bord du cercle
      expect(Helpers.isPointInCircle(10, 0, 0, 0, 10), true);
    });

    test('isPointInCircle with point outside circle', () {
      // Point (15,0) est à une distance de 15 > 10
      expect(Helpers.isPointInCircle(15, 0, 0, 0, 10), false);
    });

    // Test de calculateAngle
    test('calculateAngle between (0,0) and (1,0)', () {
      // Angle entre (0,0) et (1,0) = 0 radians
      expect(Helpers.calculateAngle(0, 0, 1, 0), 0.0);
    });

    test('calculateAngle between (0,0) and (0,1)', () {
      // Angle entre (0,0) et (0,1) = pi/2 radians
      expect(Helpers.calculateAngle(0, 0, 0, 1), pi / 2);
    });

    test('calculateAngle between (0,0) and (-1,0)', () {
      // Angle entre (0,0) et (-1,0) = pi radians
      expect(Helpers.calculateAngle(0, 0, -1, 0), pi);
    });

    // Test de calculateCenter
    test('calculateCenter with empty list', () {
      final center = Helpers.calculateCenter([]);
      expect(center, (0, 0));
    });

    test('calculateCenter with one point', () {
      final center = Helpers.calculateCenter([(10, 20)]);
      expect(center, (10, 20));
    });

    test('calculateCenter with multiple points', () {
      final center = Helpers.calculateCenter([(0, 0), (10, 10), (20, 20)]);
      expect(center.$1, closeTo(10, 0.001));
      expect(center.$2, closeTo(10, 0.001));
    });

    // Test de generateId
    test('generateId returns unique strings', () {
      final id1 = Helpers.generateId();
      final id2 = Helpers.generateId();

      expect(id1, isNotNull);
      expect(id2, isNotNull);
      expect(id1, isNot(equals(id2)));
    });

    // Test de calculateDistance
    test('calculateDistance between (0,0) and (3,4)', () {
      // Distance = sqrt(3^2 + 4^2) = 5
      expect(Helpers.calculateDistance(0, 0, 3, 4), 5.0);
    });

    test('calculateDistance between same points', () {
      expect(Helpers.calculateDistance(5, 5, 5, 5), 0.0);
    });

    // Test de roundTo
    test('roundTo with 1 decimal', () {
      expect(Helpers.roundTo(123.456, 1), 123.5);
    });

    test('roundTo with 2 decimals', () {
      expect(Helpers.roundTo(123.456, 2), 123.46);
    });

    test('roundTo with 0 decimals', () {
      expect(Helpers.roundTo(123.456, 0), 123.0);
    });

    // Test de toPercentage
    test('toPercentage with 0.5', () {
      expect(Helpers.toPercentage(0.5), '50,0%');
    });

    test('toPercentage with 0.1234', () {
      expect(Helpers.toPercentage(0.1234, decimals: 2), '12,34%');
    });

    // Test de circlesOverlap
    test('circlesOverlap with non-overlapping circles', () {
      // Cercle 1: centre (0,0), rayon 5
      // Cercle 2: centre (15,0), rayon 5
      // Distance entre centres = 15 > 5+5 = 10
      expect(Helpers.circlesOverlap(0, 0, 5, 15, 0, 5), false);
    });

    test('circlesOverlap with touching circles', () {
      // Cercle 1: centre (0,0), rayon 5
      // Cercle 2: centre (10,0), rayon 5
      // Distance entre centres = 10 = 5+5
      expect(Helpers.circlesOverlap(0, 0, 5, 10, 0, 5), false);
    });

    test('circlesOverlap with overlapping circles', () {
      // Cercle 1: centre (0,0), rayon 5
      // Cercle 2: centre (8,0), rayon 5
      // Distance entre centres = 8 < 5+5 = 10
      expect(Helpers.circlesOverlap(0, 0, 5, 8, 0, 5), true);
    });

    // Test de calculateCircularity
    test('calculateCircularity with perfect circle', () {
      // Cercle parfait: aire = pi*r^2, périmètre = 2*pi*r
      // Circularité = 4*pi*aire / périmètre^2 = 4*pi*(pi*r^2) / (4*pi^2*r^2) = 1
      final area = pi * 10 * 10;
      final perimeter = 2 * pi * 10;
      expect(Helpers.calculateCircularity(area, perimeter), closeTo(1.0, 0.001));
    });

    test('calculateCircularity with zero perimeter', () {
      expect(Helpers.calculateCircularity(100, 0), 0.0);
    });
  });
}
