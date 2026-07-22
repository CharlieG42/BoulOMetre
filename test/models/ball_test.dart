import 'package:flutter_test/flutter_test.dart';
import 'package:boul_o_metre/models/ball.dart';

void main() {
  group('Ball Model Tests', () {
    // Test de création d'une boule
    test('Ball creation with required parameters', () {
      const ball = Ball(
        id: 'ball_1',
        x: 100.0,
        y: 200.0,
        radius: 15.0,
      );

      expect(ball.id, 'ball_1');
      expect(ball.x, 100.0);
      expect(ball.y, 200.0);
      expect(ball.radius, 15.0);
      expect(ball.distanceToPiglet, 0.0);
      expect(ball.isPiglet, false);
    });

    // Test de création d'un cochonnet
    test('Piglet creation', () {
      const piglet = Ball(
        id: 'piglet',
        x: 50.0,
        y: 50.0,
        radius: 10.0,
        isPiglet: true,
      );

      expect(piglet.id, 'piglet');
      expect(piglet.isPiglet, true);
    });

    // Test de toMap
    test('Ball toMap conversion', () {
      const ball = Ball(
        id: 'ball_1',
        x: 100.0,
        y: 200.0,
        radius: 15.0,
        distanceToPiglet: 50.0,
        isPiglet: false,
      );

      final map = ball.toMap();

      expect(map['id'], 'ball_1');
      expect(map['x'], 100.0);
      expect(map['y'], 200.0);
      expect(map['radius'], 15.0);
      expect(map['distanceToPiglet'], 50.0);
      expect(map['isPiglet'], false);
    });

    // Test de fromMap
    test('Ball fromMap conversion', () {
      final map = {
        'id': 'ball_2',
        'x': 150.0,
        'y': 250.0,
        'radius': 20.0,
        'distanceToPiglet': 75.0,
        'isPiglet': true,
      };

      final ball = Ball.fromMap(map);

      expect(ball.id, 'ball_2');
      expect(ball.x, 150.0);
      expect(ball.y, 250.0);
      expect(ball.radius, 20.0);
      expect(ball.distanceToPiglet, 75.0);
      expect(ball.isPiglet, true);
    });

    // Test de copyWith
    test('Ball copyWith', () {
      const original = Ball(
        id: 'ball_1',
        x: 100.0,
        y: 200.0,
        radius: 15.0,
        distanceToPiglet: 50.0,
        isPiglet: false,
      );

      final modified = original.copyWith(
        x: 120.0,
        distanceToPiglet: 60.0,
      );

      expect(modified.id, original.id);
      expect(modified.x, 120.0);
      expect(modified.y, original.y);
      expect(modified.radius, original.radius);
      expect(modified.distanceToPiglet, 60.0);
      expect(modified.isPiglet, original.isPiglet);
    });

    // Test de toString
    test('Ball toString', () {
      const ball = Ball(
        id: 'ball_1',
        x: 100.0,
        y: 200.0,
        radius: 15.0,
      );

      final string = ball.toString();
      expect(string.contains('ball_1'), true);
      expect(string.contains('100.0'), true);
      expect(string.contains('200.0'), true);
    });

    // Test d'égalité
    test('Ball equality', () {
      const ball1 = Ball(id: 'ball_1', x: 100.0, y: 200.0, radius: 15.0);
      const ball2 = Ball(id: 'ball_1', x: 100.0, y: 200.0, radius: 15.0);
      const ball3 = Ball(id: 'ball_2', x: 100.0, y: 200.0, radius: 15.0);

      expect(ball1 == ball2, true);
      expect(ball1 == ball3, false);
    });

    // Test de hashCode
    test('Ball hashCode', () {
      const ball1 = Ball(id: 'ball_1', x: 100.0, y: 200.0, radius: 15.0);
      const ball2 = Ball(id: 'ball_1', x: 100.0, y: 200.0, radius: 15.0);

      expect(ball1.hashCode, ball2.hashCode);
    });
  });
}
