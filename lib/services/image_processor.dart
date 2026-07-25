import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/models/ball.dart';

/// Service de traitement d'image pour la détection des boules de pétanque
class ImageProcessor {
  // Diamètres réels en cm
  static const double realBallDiameterCm = 7.5;
  
  // Rayons minimaux et maximaux en pixels (à ajuster selon la distance)
  static const int minBallRadiusPx = 15;
  static const int maxBallRadiusPx = 100;
  static const int minPigletRadiusPx = 5;
  static const int maxPigletRadiusPx = 40;
  
  // Seuil pour la détection des bords
  static const int edgeThreshold = 40;
  
  // Position centrale pour le cochonnet (en % de l'image)
  static const double centerXPercent = 0.5;
  static const double centerYPercent = 0.5;

  /// Détecte les boules et positionne le cochonnet au centre
  /// 
  /// Le cochonnet est supposé être positionné au centre de l'image par l'utilisateur.
  /// Les boules sont détectées automatiquement autour.
  static List<Ball> detectBallsAndPiglet(img.Image image, {double? centerX, double? centerY}) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;
    
    // Position du centre (cochonnet)
    final pigletX = centerX ?? width * centerXPercent;
    final pigletY = centerY ?? height * centerYPercent;
    
    // Créer le cochonnet au centre avec un rayon estimé
    final pigletRadius = _detectPigletRadius(image, pigletX, pigletY);
    
    // Ajouter le cochonnet à la liste
    final piglet = Ball(
      id: 'piglet',
      x: pigletX,
      y: pigletY,
      radius: pigletRadius,
      isPiglet: true,
    );
    balls.add(piglet);
    
    // Détecter les boules dans l'image
    final detectedBalls = _detectBalls(image, pigletX, pigletY);
    balls.addAll(detectedBalls);
    
    // Calculer les distances par rapport au cochonnet
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
      
      // Calculer l'échelle basée sur le diamètre du cochonnet
      final referenceDiameterPx = piglet.radius * 2;
      final distanceCm = pixelsToCm(distance, referenceDiameterPx: referenceDiameterPx);
      
      updatedBalls.add(ball.copyWith(distanceToPiglet: distanceCm));
    }
    
    return updatedBalls;
  }

  /// Détecte le rayon du cochonnet au centre de l'image
  static double _detectPigletRadius(img.Image image, double centerX, double centerY) {
    final width = image.width;
    final height = image.height;
    
    // Calculer le rayon maximum possible
    final maxPossibleRadius = min(
      min(centerX, width - centerX),
      min(centerY, height - centerY),
    ).floor() - 5;
    
    final int maxRadius = min(maxPigletRadiusPx, maxPossibleRadius);
    
    final int centerXi = centerX.toInt();
    final int centerYi = centerY.toInt();
    
    // Prendre la couleur du centre comme référence
    final centerPixel = image.getPixelSafe(centerXi, centerYi);
    final centerBrightness = _getBrightness(centerPixel);
    
    // Scanner vers l'extérieur jusqu'à trouver un bord
    for (int r = minPigletRadiusPx; r <= maxRadius; r += 2) {
      final pointsToCheck = 16;
      int edgeCount = 0;
      
      for (int i = 0; i < pointsToCheck; i++) {
        final angle = 2 * pi * i / pointsToCheck;
        final x = centerXi + r * cos(angle);
        final y = centerYi + r * sin(angle);
        
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final pixel = image.getPixelSafe(x.toInt(), y.toInt());
          final brightness = _getBrightness(pixel);
          
          // Calculer la différence de luminosité
          final brightnessDiff = (brightness - centerBrightness).abs();
          
          if (brightnessDiff > edgeThreshold) {
            edgeCount++;
          }
        }
      }
      
      if (edgeCount >= pointsToCheck ~/ 2) {
        return r.toDouble();
      }
    }
    
    return maxPigletRadiusPx * 0.6;
  }

  /// Détecte les boules dans l'image en excluant la zone du cochonnet
  static List<Ball> _detectBalls(img.Image image, double pigletX, double pigletY) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;
    
    final excludeRadius = maxPigletRadiusPx * 1.5;
    
    // Convertir l'image en niveaux de gris
    final grayscale = img.grayscale(image);
    
    // Appliquer un flou pour réduire le bruit
    final blurred = img.gaussianBlur(grayscale, radius: 2);
    
    // Détecter les bords avec Sobel
    final edges = _detectEdgesSobel(blurred);
    
    // Trouver les contours fermés (cercles potentiels)
    final circles = _findCirclesInEdges(edges, width, height);
    
    // Filtrer les cercles qui correspondent à des boules
    for (final circle in circles) {
      final cx = circle.$1;
      final cy = circle.$2;
      final radius = circle.$3;
      
      if (radius < minBallRadiusPx || radius > maxBallRadiusPx) {
        continue;
      }
      
      final distanceToPiglet = _calculateDistance(
        pigletX, pigletY,
        cx.toDouble(), cy.toDouble(),
      );
      
      if (distanceToPiglet < excludeRadius) {
        continue;
      }
      
      if (!_isValidCircle(edges, cx, cy, radius)) {
        continue;
      }
      
      balls.add(
        Ball(
          id: 'ball_${balls.length + 1}',
          x: cx.toDouble(),
          y: cy.toDouble(),
          radius: radius.toDouble(),
          isPiglet: false,
        ),
      );
    }
    
    if (balls.isEmpty) {
      return _detectBallsSimple(image, pigletX, pigletY, excludeRadius);
    }
    
    return balls;
  }

  /// Méthode simplifiée de détection des boules
  static List<Ball> _detectBallsSimple(img.Image image, double pigletX, double pigletY, double excludeRadius) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;
    
    final cellSize = 40;
    final visited = List.generate(height, (_) => List.filled(width, false));
    
    for (int y = 0; y < height; y += cellSize ~/ 2) {
      for (int x = 0; x < width; x += cellSize ~/ 2) {
        if (visited[y][x]) continue;
        
        final distanceToPiglet = _calculateDistance(pigletX, pigletY, x.toDouble(), y.toDouble());
        if (distanceToPiglet < excludeRadius) {
          continue;
        }
        
        final avgBrightness = _getAverageBrightness(image, x, y, cellSize ~/ 2);
        
        if (avgBrightness < 100) {
          final circle = _findCircleCenter(image, x, y, cellSize);
          if (circle != null) {
            final cx = circle.$1;
            final cy = circle.$2;
            final radius = circle.$3;
            
            if (radius >= minBallRadiusPx && radius <= maxBallRadiusPx) {
              balls.add(
                Ball(
                  id: 'ball_${balls.length + 1}',
                  x: cx.toDouble(),
                  y: cy.toDouble(),
                  radius: radius.toDouble(),
                  isPiglet: false,
                ),
              );
              
              _markVisited(visited, cx, cy, radius + 10, width, height);
            }
          }
        }
      }
    }
    
    return balls;
  }

  /// Calcule la luminosité moyenne dans une zone
  static double _getAverageBrightness(img.Image image, int centerX, int centerY, int radius) {
    int sum = 0;
    int count = 0;
    
    for (int y = max(0, centerY - radius); y <= min(image.height - 1, centerY + radius); y++) {
      for (int x = max(0, centerX - radius); x <= min(image.width - 1, centerX + radius); x++) {
        final pixel = image.getPixelSafe(x, y);
        final brightness = _getBrightness(pixel);
        sum += brightness.toInt();
        count++;
      }
    }
    
    return count > 0 ? sum / count : 0;
  }

  /// Extrait la luminosité d'un pixel
  static double _getBrightness(int pixel) {
    // Extraire les composantes ARGB d'un int
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;
    
    // Luminosité perçue (formule standard)
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  /// Trouve le centre et le rayon d'un cercle potentiel
  static (int, int, int)? _findCircleCenter(img.Image image, int startX, int startY, int searchRadius) {
    int bestX = startX;
    int bestY = startY;
    int bestRadius = 0;
    double bestScore = 0;
    
    for (int y = max(0, startY - searchRadius); y <= min(image.height - 1, startY + searchRadius); y += 2) {
      for (int x = max(0, startX - searchRadius); x <= min(image.width - 1, startX + searchRadius); x += 2) {
        for (int r = minBallRadiusPx; r <= maxBallRadiusPx; r += 3) {
          if (x - r < 0 || x + r >= image.width || y - r < 0 || y + r >= image.height) {
            continue;
          }
          
          final score = _calculateCircularityScore(image, x, y, r);
          
          if (score > bestScore) {
            bestScore = score;
            bestX = x;
            bestY = y;
            bestRadius = r;
          }
        }
      }
    }
    
    if (bestScore > 0.5) {
      return (bestX, bestY, bestRadius);
    }
    
    return null;
  }

  /// Calcule un score de circularité (0-1)
  static double _calculateCircularityScore(img.Image image, int centerX, int centerY, int radius) {
    int edgePoints = 0;
    int totalPoints = 0;
    
    final pointsToCheck = 20;
    final centerPixel = image.getPixelSafe(centerX, centerY);
    final centerBrightness = _getBrightness(centerPixel);
    
    for (int i = 0; i < pointsToCheck; i++) {
      final angle = 2 * pi * i / pointsToCheck;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        final pixel = image.getPixelSafe(x.toInt(), y.toInt());
        final brightness = _getBrightness(pixel);
        
        final contrast = (brightness - centerBrightness).abs();
        
        if (contrast > 30) {
          edgePoints++;
        }
        totalPoints++;
      }
    }
    
    return totalPoints > 0 ? edgePoints / totalPoints : 0;
  }

  /// Détection des bords avec l'opérateur Sobel
  static img.Image _detectEdgesSobel(img.Image image) {
    final width = image.width;
    final height = image.height;
    final edges = img.Image(width: width, height: height);
    
    // Matrices Sobel
    final sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1],
    ];
    final sobelY = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1],
    ];
    
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        int gx = 0;
        int gy = 0;
        
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = image.getPixelSafe(x + kx, y + ky);
            final gray = _getBrightness(pixel).toInt();
            
            gx += gray * sobelX[ky + 1][kx + 1];
            gy += gray * sobelY[ky + 1][kx + 1];
          }
        }
        
        final magnitude = sqrt(gx * gx + gy * gy).toInt();
        final edgeValue = min(255, magnitude);
        
        // Créer un pixel gris (ARGB: 0xAARRGGBB)
        final pixelValue = (0xFF << 24) | (edgeValue << 16) | (edgeValue << 8) | edgeValue;
        edges.setPixel(x, y, pixelValue);
      }
    }
    
    return edges;
  }

  /// Trouve les cercles dans une image de bords
  static List<(int, int, int)> _findCirclesInEdges(img.Image edges, int width, int height) {
    final List<(int, int, int)> circles = [];
    
    final edgeThreshold = 100;
    
    final contours = _findContours(edges, edgeThreshold);
    
    for (final contour in contours) {
      if (contour.length < 10) continue;
      
      double sumX = 0;
      double sumY = 0;
      for (final point in contour) {
        sumX += point.$1;
        sumY += point.$2;
      }
      final centerX = (sumX / contour.length).round();
      final centerY = (sumY / contour.length).round();
      
      double sumR = 0;
      for (final point in contour) {
        final r = _calculateDistance(
          centerX.toDouble(), centerY.toDouble(),
          point.$1.toDouble(), point.$2.toDouble(),
        );
        sumR += r;
      }
      final radius = (sumR / contour.length).round();
      
      if (radius >= minBallRadiusPx && radius <= maxBallRadiusPx) {
        circles.add((centerX, centerY, radius));
      }
    }
    
    return circles;
  }

  /// Trouve les contours dans une image binaire
  static List<List<(int, int)>> _findContours(img.Image image, int threshold) {
    final List<List<(int, int)>> contours = [];
    final width = image.width;
    final height = image.height;
    final visited = List.generate(height, (_) => List.filled(width, false));
    
    final directions = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1),           (0, 1),
      (1, -1),  (1, 0),  (1, 1),
    ];
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (!visited[y][x]) {
          final pixel = image.getPixelSafe(x, y);
          final gray = _getBrightness(pixel);
          
          if (gray >= threshold) {
            final contour = <(int, int)>[];
            final stack = <(int, int)>[(x, y)];
            visited[y][x] = true;
            
            while (stack.isNotEmpty) {
              final (cx, cy) = stack.removeLast();
              contour.add((cx, cy));
              
              for (final (dx, dy) in directions) {
                final nx = cx + dx;
                final ny = cy + dy;
                
                if (nx >= 0 && nx < width && ny >= 0 && ny < height && !visited[ny][nx]) {
                  final neighborPixel = image.getPixelSafe(nx, ny);
                  final neighborGray = _getBrightness(neighborPixel);
                  
                  if (neighborGray >= threshold) {
                    visited[ny][nx] = true;
                    stack.add((nx, ny));
                  }
                }
              }
            }
            
            if (contour.length >= 10) {
              contours.add(contour);
            }
          }
        }
      }
    }
    
    return contours;
  }

  /// Valide qu'un cercle est bien défini dans l'image de bords
  static bool _isValidCircle(img.Image edges, int centerX, int centerY, int radius) {
    int edgePoints = 0;
    int totalPoints = 0;
    
    final pointsToCheck = 24;
    for (int i = 0; i < pointsToCheck; i++) {
      final angle = 2 * pi * i / pointsToCheck;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      
      if (x >= 0 && x < edges.width && y >= 0 && y < edges.height) {
        final pixel = edges.getPixelSafe(x.toInt(), y.toInt());
        final gray = _getBrightness(pixel);
        
        if (gray >= 100) {
          edgePoints++;
        }
        totalPoints++;
      }
    }
    
    return totalPoints > 0 && edgePoints / totalPoints >= 0.6;
  }

  /// Marque une zone comme visitée
  static void _markVisited(
    List<List<bool>> visited,
    int centerX, int centerY, int radius,
    int width, int height,
  ) {
    for (int y = max(0, centerY - radius); y <= min(height - 1, centerY + radius); y++) {
      for (int x = max(0, centerX - radius); x <= min(width - 1, centerX + radius); x++) {
        if (_calculateDistance(
          centerX.toDouble(), centerY.toDouble(),
          x.toDouble(), y.toDouble(),
        ) <= radius) {
          visited[y][x] = true;
        }
      }
    }
  }

  /// Calcule la distance entre deux points
  static double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Convertit des pixels en centimètres
  static double pixelsToCm(double pixels, {double referenceDiameterPx = 50.0}) {
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    
    final scale = realBallDiameterCm / referenceDiameterPx;
    return pixels * scale;
  }

  /// Convertit des centimètres en pixels
  static double cmToPixels(double cm, {double referenceDiameterPx = 50.0}) {
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    
    final scale = referenceDiameterPx / realBallDiameterCm;
    return cm * scale;
  }
}
