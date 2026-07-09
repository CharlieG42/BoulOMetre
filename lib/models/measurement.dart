import 'package:boul_o_metre/models/ball.dart';

class Measurement {
  final List<Ball> balls;
  final DateTime timestamp;
  final String? teamId;

  Measurement({
    required this.balls,
    DateTime? timestamp,
    this.teamId,
  }) : timestamp = timestamp ?? DateTime.now();

  Ball? get piglet => balls.firstWhere((ball) => ball.isPiglet, orElse: () => null);

  Ball? get closestBall {
    final piglet = this.piglet;
    if (piglet == null) return null;
    return balls
        .where((ball) => !ball.isPiglet)
        .reduce((a, b) => a.distanceToPiglet < b.distanceToPiglet ? a : b);
  }

  List<Ball> get sortedBalls {
    final piglet = this.piglet;
    if (piglet == null) return [];
    return [...balls.where((ball) => !ball.isPiglet)]
      ..sort((a, b) => a.distanceToPiglet.compareTo(b.distanceToPiglet));
  }

  Map<String, dynamic> toMap() => {
    'balls': balls.map((ball) => ball.toMap()).toList(),
    'timestamp': timestamp.toIso8601String(),
    'teamId': teamId,
  };

  factory Measurement.fromMap(Map<String, dynamic> map) => Measurement(
    balls: (map['balls'] as List).map((ballMap) => Ball.fromMap(ballMap)).toList(),
    timestamp: DateTime.parse(map['timestamp']),
    teamId: map['teamId'],
  );
}