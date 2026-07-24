class Ball {
  final String id;
  final double x;
  final double y;
  final double radius;
  final double distanceToPiglet;
  final bool isPiglet;

  Ball({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    this.distanceToPiglet = 0.0,
    this.isPiglet = false,
  });

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'x': x,
    'y': y,
    'radius': radius,
    'distanceToPiglet': distanceToPiglet,
    'isPiglet': isPiglet,
  };

  factory Ball.fromMap(Map<String, dynamic> map) => Ball(
    id: map['id'],
    x: map['x'],
    y: map['y'],
    radius: map['radius'],
    distanceToPiglet: map['distanceToPiglet'] ?? 0.0,
    isPiglet: map['isPiglet'] ?? false,
  );
}
