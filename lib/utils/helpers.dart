import 'dart:math';

/// Classe utilitaire contenant des fonctions mathématiques et de formatage.
class Helpers {
  /// Formate une distance en centimètres.
  /// Exemple: 123.456 -> "123,5 cm"
  static String formatDistance(double cm) {
    return cm.toStringAsFixed(1).replaceAll('.', ',') + ' cm';
  }

  /// Formate un angle en degrés.
  /// Exemple: 0.785 radians -> "45,0°"
  static String formatAngle(double radians) {
    final degrees = radians * (180 / pi);
    return degrees.toStringAsFixed(1).replaceAll('.', ',') + '°';
  }

  /// Vérifie si un point est à l'intérieur d'un cercle.
  static bool isPointInCircle(
    double px, double py, double cx, double cy, double radius,
  ) {
    final distance = sqrt(pow(px - cx, 2) + pow(py - cy, 2));
    return distance <= radius;
  }

  /// Calcule l'angle entre deux points (en radians).
  static double calculateAngle(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  /// Calcule le centre de gravité d'une liste de points.
  static (double, double) calculateCenter(List<(double, double)> points) {
    if (points.isEmpty) return (0, 0);
    double sumX = 0;
    double sumY = 0;
    for (final point in points) {
      sumX += point.$1;
      sumY += point.$2;
    }
    return (sumX / points.length, sumY / points.length);
  }

  /// Génère un identifiant unique basé sur le timestamp.
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Calcule la distance euclidienne entre deux points.
  static double calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Arrondit un nombre à un certain nombre de décimales.
  static double roundTo(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }

  /// Convertit une valeur en pourcentage.
  static String toPercentage(double value, {int decimals = 1}) {
    return (value * 100).toStringAsFixed(decimals).replaceAll('.', ',') + '%';
  }

  /// Vérifie si deux cercles se chevauchent.
  static bool circlesOverlap(
    double x1, double y1, double r1, double x2, double y2, double r2,
  ) {
    final distance = calculateDistance(x1, y1, x2, y2);
    return distance < (r1 + r2);
  }

  /// Calcule le ratio de circularité (4*pi*area/perimeter^2).
  /// Une valeur proche de 1 indique un cercle parfait.
  static double calculateCircularity(double area, double perimeter) {
    if (perimeter == 0) return 0;
    return (4 * pi * area) / (perimeter * perimeter);
  }
}
