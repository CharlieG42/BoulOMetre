import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/models/ball.dart';

class ImageProcessor {
  static const double _realBallDiameterCm = 7.5;
  static const double _realPigletDiameterCm = 3.0;

  /// Returns a piglet at the center of the image
  /// The user can manually adjust its position after capture
  static List<Ball> detectBallsAndPiglet(img.Image image) {
    final width = image.width;
    final height = image.height;

    // Create a piglet at the center of the image
    // The actual position can be adjusted manually by the user
    final piglet = Ball(
      id: 'piglet',
      x: width / 2,
      y: height / 2,
      radius: 15.0,
      isPiglet: true,
    );

    // Return only the piglet - balls will be added manually by the user
    return [piglet];
  }

  /// Calculate distance between two points
  static double calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Convert pixels to centimeters using a reference diameter
  static double pixelsToCm(double pixels, {double referenceDiameterPx = 50.0}) {
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    final scale = _realPigletDiameterCm / referenceDiameterPx;
    return pixels * scale;
  }

  /// Convert centimeters to pixels using a reference diameter
  static double cmToPixels(double cm, {double referenceDiameterPx = 50.0}) {
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    final scale = referenceDiameterPx / _realPigletDiameterCm;
    return cm * scale;
  }
}
