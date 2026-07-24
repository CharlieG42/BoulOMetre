import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/models/ball.dart';

class ImageProcessor {
  static const int _colorThreshold = 30;
  static const int _minRadius = 10;
  static const int _maxRadius = 80;
  static const double _realBallDiameterCm = 7.5;
  static const double _realPigletDiameterCm = 3.0;

  static List<Ball> detectBallsAndPiglet(img.Image image) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;

    final grayscale = img.grayscale(image);

    balls.add(
      Ball(id: 'piglet', x: width / 2, y: height / 2, radius: 15, isPiglet: true),
    );
    balls.add(
      Ball(id: 'ball_1', x: width / 2 - 100, y: height / 2 - 50, radius: 20),
    );
    balls.add(
      Ball(id: 'ball_2', x: width / 2 + 80, y: height / 2 + 30, radius: 20),
    );
    balls.add(
      Ball(id: 'ball_3', x: width / 2 - 50, y: height / 2 + 80, radius: 20),
    );

    final piglet = balls.firstWhere((ball) => ball.isPiglet);
    final updatedBalls = <Ball>[];
    for (final ball in balls) {
      if (ball.isPiglet) {
        updatedBalls.add(ball);
        continue;
      }
      final distance = _calculateDistance(
        piglet.x, piglet.y,
        ball.x, ball.y,
      );
      final distanceCm = pixelsToCm(distance, referenceDiameterPx: 50.0);
      updatedBalls.add(ball.copyWith(distanceToPiglet: distanceCm));
    }

    return updatedBalls;
  }

  static double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  static double pixelsToCm(double pixels, {double referenceDiameterPx = 50.0}) {
    final scale = _realBallDiameterCm / referenceDiameterPx;
    return pixels * scale;
  }

  static double cmToPixels(double cm, {double referenceDiameterPx = 50.0}) {
    final scale = referenceDiameterPx / _realBallDiameterCm;
    return cm * scale;
  }
}
