/// Modèle représentant une boule ou un cochonnet.
class Ball {
  /// Identifiant unique de la boule.
  final String id;

  /// Coordonnée X du centre (en pixels).
  final double x;

  /// Coordonnée Y du centre (en pixels).
  final double y;

  /// Rayon de la boule (en pixels).
  final double radius;

  /// Distance par rapport au cochonnet (en centimètres).
  final double distanceToPiglet;

  /// Indique si cet objet est le cochonnet.
  final bool isPiglet;

  /// Crée une nouvelle boule.
  const Ball({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    this.distanceToPiglet = 0.0,
    this.isPiglet = false,
  });

  /// Convertit cette boule en Map pour la sérialisation.
  Map<String, dynamic> toMap() => {
    'id': id,
    'x': x,
    'y': y,
    'radius': radius,
    'distanceToPiglet': distanceToPiglet,
    'isPiglet': isPiglet,
  };

  /// Crée une boule à partir d'une Map.
  factory Ball.fromMap(Map<String, dynamic> map) => Ball(
    id: map['id'] as String,
    x: (map['x'] as num).toDouble(),
    y: (map['y'] as num).toDouble(),
    radius: (map['radius'] as num).toDouble(),
    distanceToPiglet: (map['distanceToPiglet'] as num).toDouble(),
    isPiglet: map['isPiglet'] as bool? ?? false,
  );

  /// Crée une copie de cette boule avec des champs optionnellement modifiés.
  Ball copyWith({
    String? id,
    double? x,
    double? y,
    double? radius,
    double? distanceToPiglet,
    bool? isPiglet,
  }) {
    return Ball(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
      distanceToPiglet: distanceToPiglet ?? this.distanceToPiglet,
      isPiglet: isPiglet ?? this.isPiglet,
    );
  }

  @override
  String toString() {
    return 'Ball(id: $id, x: $x, y: $y, radius: $radius, '
           'distanceToPiglet: $distanceToPiglet, isPiglet: $isPiglet)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ball &&
           other.id == id &&
           other.x == x &&
           other.y == y &&
           other.radius == radius &&
           other.distanceToPiglet == distanceToPiglet &&
           other.isPiglet == isPiglet;
  }

  @override
  int get hashCode {
    return id.hashCode ^
           x.hashCode ^
           y.hashCode ^
           radius.hashCode ^
           distanceToPiglet.hashCode ^
           isPiglet.hashCode;
  }
}
