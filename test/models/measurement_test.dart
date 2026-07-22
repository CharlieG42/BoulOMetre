import 'package:flutter_test/flutter_test.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/models/measurement.dart';

void main() {
  group('Measurement Model Tests', () {
    // Boules pour les tests
    final piglet = Ball(
      id: 'piglet',
      x: 100.0,
      y: 100.0,
      radius: 10.0,
      isPiglet: true,
    );

    final ball1 = Ball(
      id: 'ball_1',
      x: 150.0,
      y: 150.0,
      radius: 15.0,
      distanceToPiglet: 50.0,
    );

    final ball2 = Ball(
      id: 'ball_2',
      x: 200.0,
      y: 200.0,
      radius: 15.0,
      distanceToPiglet: 100.0,
    );

    final balls = [piglet, ball1, ball2];

    // Test de création
    test('Measurement creation with default timestamp', () {
      final measurement = Measurement(balls: balls);

      expect(measurement.balls, balls);
      expect(measurement.teamId, isNull);
      expect(measurement.timestamp, isNotNull);
    });

    // Test de création avec timestamp personnalisé
    test('Measurement creation with custom timestamp', () {
      final customTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final measurement = Measurement(
        balls: balls,
        timestamp: customTimestamp,
      );

      expect(measurement.timestamp, customTimestamp);
    });

    // Test de création avec teamId
    test('Measurement creation with teamId', () {
      final measurement = Measurement(
        balls: balls,
        teamId: 'team_1',
      );

      expect(measurement.teamId, 'team_1');
    });

    // Test de piglet getter
    test('Measurement piglet getter', () {
      final measurement = Measurement(balls: balls);

      expect(measurement.piglet, piglet);
    });

    // Test de piglet getter avec pas de cochonnet
    test('Measurement piglet getter with no piglet', () {
      final ballsWithoutPiglet = [ball1, ball2];
      final measurement = Measurement(balls: ballsWithoutPiglet);

      expect(measurement.piglet, isNull);
    });

    // Test de closestBall getter
    test('Measurement closestBall getter', () {
      final measurement = Measurement(balls: balls);

      expect(measurement.closestBall, ball1);
    });

    // Test de closestBall getter avec pas de boules
    test('Measurement closestBall getter with no balls', () {
      final measurement = Measurement(balls: [piglet]);

      expect(measurement.closestBall, isNull);
    });

    // Test de sortedBalls getter
    test('Measurement sortedBalls getter', () {
      final measurement = Measurement(balls: balls);

      final sorted = measurement.sortedBalls;
      expect(sorted.length, 2);
      expect(sorted[0], ball1); // ball1 est plus proche
      expect(sorted[1], ball2);
    });

    // Test de sortedBalls getter avec pas de cochonnet
    test('Measurement sortedBalls getter with no piglet', () {
      final ballsWithoutPiglet = [ball1, ball2];
      final measurement = Measurement(balls: ballsWithoutPiglet);

      expect(measurement.sortedBalls, isEmpty);
    });

    // Test de toMap
    test('Measurement toMap conversion', () {
      final customTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final measurement = Measurement(
        balls: balls,
        timestamp: customTimestamp,
        teamId: 'team_1',
      );

      final map = measurement.toMap();

      expect(map['teamId'], 'team_1');
      expect(map['timestamp'], customTimestamp.toIso8601String());
      expect((map['balls'] as List).length, 3);
    });

    // Test de fromMap
    test('Measurement fromMap conversion', () {
      final customTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final map = {
        'balls': [
          {'id': 'piglet', 'x': 100.0, 'y': 100.0, 'radius': 10.0, 'distanceToPiglet': 0.0, 'isPiglet': true},
          {'id': 'ball_1', 'x': 150.0, 'y': 150.0, 'radius': 15.0, 'distanceToPiglet': 50.0, 'isPiglet': false},
        ],
        'timestamp': customTimestamp.toIso8601String(),
        'teamId': 'team_1',
      };

      final measurement = Measurement.fromMap(map);

      expect(measurement.teamId, 'team_1');
      expect(measurement.timestamp, customTimestamp);
      expect(measurement.balls.length, 2);
    });

    // Test de copyWith
    test('Measurement copyWith', () {
      final original = Measurement(
        balls: balls,
        teamId: 'team_1',
      );

      final modified = original.copyWith(teamId: 'team_2');

      expect(modified.balls, original.balls);
      expect(modified.teamId, 'team_2');
    });

    // Test d'égalité
    test('Measurement equality', () {
      final measurement1 = Measurement(balls: balls, teamId: 'team_1');
      final measurement2 = Measurement(balls: balls, teamId: 'team_1');
      final measurement3 = Measurement(balls: balls, teamId: 'team_2');

      expect(measurement1 == measurement2, true);
      expect(measurement1 == measurement3, false);
    });

    // Test de hashCode
    test('Measurement hashCode', () {
      final measurement1 = Measurement(balls: balls, teamId: 'team_1');
      final measurement2 = Measurement(balls: balls, teamId: 'team_1');

      expect(measurement1.hashCode, measurement2.hashCode);
    });
  });
}
