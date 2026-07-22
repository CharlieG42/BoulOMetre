import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/utils/constants.dart';

/// Service de traitement d'image pour la détection des boules et du cochonnet.
class ImageProcessor {
  /// Seuil de couleur pour la détection de contours (0-255).
  static const int _edgeThreshold = 50;

  /// Rayon minimum d'un cercle détecté (en pixels).
  static const int _minRadius = 8;

  /// Rayon maximum d'un cercle détecté (en pixels).
  static const int _maxRadius = 100;

  /// Rayon maximum du cochonnet (en pixels).
  static const int _maxPigletRadius = 25;

  /// Seuil de circularité pour filtrer les fausses détections.
  static const double _circularityThreshold = 0.7;

  /// Distance minimale entre deux cercles pour éviter les doublons.
  static const double _minCircleDistance = 20;

  /// Détecte les boules et le cochonnet dans une image.
  /// Retourne une liste de [Ball] avec leurs positions et distances.
  static List<Ball> detectBallsAndPiglet(img.Image image) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;

    // 1. Prétraitement de l'image
    final grayscale = img.grayscale(image);
    final blurred = img.gaussianBlur(grayscale, radius: 3);

    // 2. Détection des contours avec Canny (simplifié)
    final edges = _detectEdges(blurred);

    // 3. Détection des cercles avec Hough Circle Transform (simplifié)
    final circles = _detectCircles(edges, width, height);

    // 4. Filtrer et classer les cercles
    final filteredCircles = _filterCircles(circles);

    // 5. Créer les objets Ball
    for (final circle in filteredCircles) {
      final isPiglet = circle.radius <= _maxPigletRadius;
      balls.add(Ball(
        id: isPiglet ? 'piglet' : 'ball_${balls.length + 1}',
        x: circle.x.toDouble(),
        y: circle.y.toDouble(),
        radius: circle.radius.toDouble(),
        isPiglet: isPiglet,
      ));
    }

    // 6. Calculer les distances par rapport au cochonnet
    final piglet = balls.firstWhere((b) => b.isPiglet, orElse: () => null);
    if (piglet != null) {
      for (final ball in balls.where((b) => !b.isPiglet)) {
        final distancePx = _calculateDistance(piglet.x, piglet.y, ball.x, ball.y);
        final distanceCm = pixelsToCm(
          distancePx,
          referenceDiameterPx: piglet.radius * 2, // Diamètre du cochonnet
        );
        // Mettre à jour la distance dans la liste
        for (var i = 0; i < balls.length; i++) {
          if (balls[i].id == ball.id) {
            balls[i] = balls[i].copyWith(distanceToPiglet: distanceCm);
            break;
          }
        }
      }
    }

    return balls;
  }

  /// Détecte les contours dans une image (implémentation simplifiée de Canny).
  static img.Image _detectEdges(img.Image image) {
    final width = image.width;
    final height = image.height;
    final output = img.Image(width: width, height: height);

    // Appliquer un filtre Sobel pour détecter les contours
    for (var y = 1; y < height - 1; y++) {
      for (var x = 1; x < width - 1; x++) {
        final p1 = image.getPixel(x - 1, y - 1);
        final p2 = image.getPixel(x + 1, y - 1);
        final p3 = image.getPixel(x - 1, y + 1);
        final p4 = image.getPixel(x + 1, y + 1);

        final gx = (p2.r + p2.g + p2.b) - (p1.r + p1.g + p1.b) +
                   (p4.r + p4.g + p4.b) - (p3.r + p3.g + p3.b);
        final gy = (p2.r + p2.g + p2.b) - (p4.r + p4.g + p4.b) +
                   (p1.r + p1.g + p1.b) - (p3.r + p3.g + p3.b);

        final magnitude = sqrt(gx * gx + gy * gy).toInt();
        
        if (magnitude > _edgeThreshold) {
          output.setPixel(x, y, img.ColorRgb8(magnitude, magnitude, magnitude));
        } else {
          output.setPixel(x, y, img.ColorRgb8(0, 0, 0));
        }
      }
    }

    return output;
  }

  /// Détection de cercles avec une implémentation simplifiée de Hough Circle Transform.
  static List<_Circle> _detectCircles(img.Image edges, int width, int height) {
    final List<_Circle> circles = [];
    final minRadius = _minRadius;
    final maxRadius = _maxRadius;

    // Accumulateur pour Hough Circle Transform
    final accumulator = List.generate(
      maxRadius - minRadius + 1,
      (_) => List.generate(height, (_) => List.filled(width, 0)),
    );

    // Remplir l'accumulateur
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = edges.getPixel(x, y);
        if (pixel.r > 0 || pixel.g > 0 || pixel.b > 0) {
          // Ce pixel fait partie d'un contour
          for (var r = minRadius; r <= maxRadius; r++) {
            // Dessiner un cercle dans l'accumulateur
            for (var angle = 0; angle < 360; angle += 5) {
              final rad = angle * pi / 180;
              final cx = x + r * cos(rad);
              final cy = y + r * sin(rad);
              
              if (cx >= 0 && cx < width && cy >= 0 && cy < height) {
                accumulator[r - minRadius][cy.toInt()][cx.toInt()]++;
              }
            }
          }
        }
      }
    }

    // Trouver les maxima locaux dans l'accumulateur
    for (var r = minRadius; r <= maxRadius; r++) {
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          final value = accumulator[r - minRadius][y][x];
          if (value > 30) { // Seuil pour considérer un cercle valide
            // Vérifier si c'est un maximum local
            bool isLocalMax = true;
            for (var dy = -5; dy <= 5 && isLocalMax; dy++) {
              for (var dx = -5; dx <= 5 && isLocalMax; dx++) {
                if (dx == 0 && dy == 0) continue;
                final nx = x + dx;
                final ny = y + dy;
                if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                  if (accumulator[r - minRadius][ny][nx] > value) {
                    isLocalMax = false;
                  }
                }
              }
            }
            
            if (isLocalMax) {
              circles.add(_Circle(x: x, y: y, radius: r));
            }
          }
        }
      }
    }

    return circles;
  }

  /// Filtre les cercles détectés pour éliminer les doublons et les fausses détections.
  static List<_Circle> _filterCircles(List<_Circle> circles) {
    final List<_Circle> filtered = [];
    
    // Trier par score (radius pour simplifier)
    circles.sort((a, b) => b.radius.compareTo(a.radius));

    for (final circle in circles) {
      bool isDuplicate = false;
      
      // Vérifier si ce cercle est trop proche d'un cercle déjà accepté
      for (final accepted in filtered) {
        final distance = _calculateDistance(
          circle.x.toDouble(), circle.y.toDouble(),
          accepted.x.toDouble(), accepted.y.toDouble(),
        );
        
        if (distance < _minCircleDistance) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        // Vérifier la circularité (simplifié)
        // Pour une implémentation complète, il faudrait vérifier le ratio
        // entre la circonférence et l'aire du cercle détecté
        filtered.add(circle);
      }
    }

    return filtered;
  }

  /// Calcule la distance entre deux points (en pixels).
  static double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Convertit une distance en pixels en centimètres.
  /// [referenceDiameterPx] : Diamètre de référence en pixels (ex: diamètre du cochonnet).
  static double pixelsToCm(double pixels, {required double referenceDiameterPx}) {
    // Le cochonnet fait environ 3 cm de diamètre
    final scale = AppConstants.realPigletDiameter / referenceDiameterPx;
    return pixels * scale;
  }

  /// Convertit une distance en centimètres en pixels.
  static double cmToPixels(double cm, {required double referenceDiameterPx}) {
    final scale = referenceDiameterPx / AppConstants.realPigletDiameter;
    return cm * scale;
  }
}

/// Modèle interne pour représenter un cercle détecté.
class _Circle {
  final int x;
  final int y;
  final int radius;

  _Circle({required this.x, required this.y, required this.radius});
}
