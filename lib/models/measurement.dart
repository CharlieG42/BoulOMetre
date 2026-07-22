import 'package:boul_o_metre/models/ball.dart';

/// Modèle représentant une mesure (une partie ou un lancer).
class Measurement {
  /// Liste des boules et du cochonnet détectés.
  final List<Ball> balls;

  /// Date et heure de la mesure.
  final DateTime timestamp;

  /// Identifiant de l'équipe associée (optionnel, pour la V2).
  final String? teamId;

  /// Crée une nouvelle mesure.
  Measurement({
    required this.balls,
    DateTime? timestamp,
    this.teamId,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Retourne le cochonnet s'il existe.
  Ball? get piglet => balls.firstWhere((ball) => ball.isPiglet, orElse: () => null);

  /// Retourne la boule la plus proche du cochonnet.
  Ball? get closestBall {
    final piglet = this.piglet;
    if (piglet == null) return null;
    
    final nonPigletBalls = balls.where((ball) => !ball.isPiglet).toList();
    if (nonPigletBalls.isEmpty) return null;
    
    return nonPigletBalls.reduce(
      (a, b) => a.distanceToPiglet < b.distanceToPiglet ? a : b
    );
  }

  /// Retourne la liste des boules triées par distance au cochonnet.
  List<Ball> get sortedBalls {
    final piglet = this.piglet;
    if (piglet == null) return [];
    
    return [...balls.where((ball) => !ball.isPiglet)]
      ..sort((a, b) => a.distanceToPiglet.compareTo(b.distanceToPiglet));
  }

  /// Convertit cette mesure en Map pour la sérialisation.
  Map<String, dynamic> toMap() => {
    'balls': balls.map((ball) => ball.toMap()).toList(),
    'timestamp': timestamp.toIso8601String(),
    'teamId': teamId,
  };

  /// Crée une mesure à partir d'une Map.
  factory Measurement.fromMap(Map<String, dynamic> map) => Measurement(
    balls: (map['balls'] as List<dynamic>)
        .map((ballMap) => Ball.fromMap(ballMap as Map<String, dynamic>))
        .toList(),
    timestamp: DateTime.parse(map['timestamp'] as String),
    teamId: map['teamId'] as String?,
  );

  /// Crée une copie de cette mesure avec des champs optionnellement modifiés.
  Measurement copyWith({
    List<Ball>? balls,
    DateTime? timestamp,
    String? teamId,
  }) {
    return Measurement(
      balls: balls ?? this.balls,
      timestamp: timestamp ?? this.timestamp,
      teamId: teamId ?? this.teamId,
    );
  }

  @override
  String toString() {
    return 'Measurement(balls: $balls, timestamp: $timestamp, teamId: $teamId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Measurement &&
           other.balls == balls &&
           other.timestamp == timestamp &&
           other.teamId == teamId;
  }

  @override
  int get hashCode {
    return balls.hashCode ^ timestamp.hashCode ^ teamId.hashCode;
  }
}
