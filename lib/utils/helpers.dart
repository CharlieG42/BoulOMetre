import 'dart:math';

class Helpers {
  static String formatDistance(double cm) {
    return '${cm.toStringAsFixed(1)} cm';
  }

  static String formatAngle(double radians) {
    final degrees = radians * (180 / pi);
    return '${degrees.toStringAsFixed(1)}°';
  }

  static bool isPointInCircle(double px, double py, double cx, double cy, double radius) {
    final distance = sqrt(pow(px - cx, 2) + pow(py - cy, 2));
    return distance <= radius;
  }

  static double calculateAngle(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

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

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// Extension pour ajouter firstOrNull sur les iterables
extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull {
    return isEmpty ? null : first;
  }
}
