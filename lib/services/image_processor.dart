import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/models/ball.dart';

/// Service de traitement d'image pour la détection des boules de pétanque
class ImageProcessor {
  // Diamètres réels en cm
  static const double _realBallDiameterCm = 7.5;
  static const double _realPigletDiameterCm = 3.0;
  
  // Rayons minimaux et maximaux en pixels (à ajuster selon la distance)
  static const int _minBallRadiusPx = 15;
  static const int _maxBallRadiusPx = 100;
  static const int _minPigletRadiusPx = 5;
  static const int _maxPigletRadiusPx = 40;
  
  // Seuil pour la détection des bords
  static const int _edgeThreshold = 40;
  
  // Position centrale pour le cochonnet (en % de l'image)
  static const double _centerXPercent = 0.5;
  static const double _centerYPercent = 0.5;
  static const double _centerTolerance = 0.15; // Tolérance de 15% autour du centre

  /// Détecte les boules et positionne le cochonnet au centre
  /// 
  /// Le cochonnet est supposé être positionné au centre de l'image par l'utilisateur.
  /// Les boules sont détectées automatiquement autour.
  static List<Ball> detectBallsAndPiglet(img.Image image, {double? centerX, double? centerY}) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;
    
    // Position du centre (cochonnet)
    final pigletX = centerX ?? width * _centerXPercent;
    final pigletY = centerY ?? height * _centerYPercent;
    
    // Créer le cochonnet au centre avec un rayon estimé
    // On va essayer de détecter sa taille réelle
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
    // On utilise piglet directement car on vient de l'ajouter
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
      // Si on a détecté le rayon du cochonnet, on utilise ça comme référence
      final referenceDiameterPx = piglet.radius * 2;
      final distanceCm = pixelsToCm(distance, referenceDiameterPx: referenceDiameterPx);
      
      updatedBalls.add(ball.copyWith(distanceToPiglet: distanceCm));
    }
    
    return updatedBalls;
  }

  /// Détecte le rayon du cochonnet au centre de l'image
  /// en analysant les pixels autour du point central
  static double _detectPigletRadius(img.Image image, double centerX, double centerY) {
    final width = image.width;
    final height = image.height;
    
    // On va scanner des cercles concentriques autour du centre
    // et détecter où se trouve le bord
    int maxRadius = min(
      _maxPigletRadiusPx,
      min(centerX, centerY, width - centerX, height - centerY).floor() - 5,
    );
    
    // Convertir en entier pour le scan
    final int centerXi = centerX.toInt();
    final int centerYi = centerY.toInt();
    
    // Prendre la couleur du centre comme référence
    final centerColor = image.getPixel(centerXi, centerYi);
    
    // Scanner vers l'extérieur jusqu'à trouver un bord
    for (int r = _minPigletRadiusPx; r <= maxRadius; r += 2) {
      // Vérifier plusieurs points sur le cercle
      final pointsToCheck = 16; // 16 points autour du cercle
      int edgeCount = 0;
      
      for (int i = 0; i < pointsToCheck; i++) {
        final angle = 2 * pi * i / pointsToCheck;
        final x = centerXi + r * cos(angle);
        final y = centerYi + r * sin(angle);
        
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final pixelColor = image.getPixel(x.toInt(), y.toInt());
          
          // Calculer la différence de couleur
          final colorDiff = _colorDifference(centerColor, pixelColor);
          
          if (colorDiff > _edgeThreshold) {
            edgeCount++;
          }
        }
      }
      
      // Si on a détecté un bord sur au moins la moitié des points
      if (edgeCount >= pointsToCheck ~/ 2) {
        return r.toDouble();
      }
    }
    
    // Si on n'a pas trouvé de bord, retourner un rayon par défaut
    return _maxPigletRadiusPx * 0.6;
  }

  /// Détecte les boules dans l'image en excluant la zone du cochonnet
  static List<Ball> _detectBalls(img.Image image, double pigletX, double pigletY) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;
    
    // Zone à exclure autour du cochonnet (pour éviter de le détecter comme une boule)
    final excludeRadius = _maxPigletRadiusPx * 1.5;
    
    // Convertir l'image en niveaux de gris pour la détection de bords
    final grayscale = img.grayscale(image);
    
    // Appliquer un flou pour réduire le bruit
    final blurred = img.gaussianBlur(grayscale, radius: 2);
    
    // Détecter les bords avec Sobel
    final edges = _detectEdgesSobel(blurred);
    
    // Trouver les contours fermés (cercles potentiels)
    final circles = _findCirclesInEdges(edges, width, height);
    
    // Filtrer les cercles qui correspondent à des boules
    for (final circle in circles) {
      final radius = circle.$2;
      
      // Vérifier la taille (doit correspondre à une boule)
      if (radius < _minBallRadiusPx || radius > _maxBallRadiusPx) {
        continue;
      }
      
      // Vérifier que le cercle n'est pas trop proche du cochonnet
      final distanceToPiglet = _calculateDistance(
        pigletX, pigletY,
        circle.$0, circle.$1,
      );
      
      if (distanceToPiglet < excludeRadius) {
        continue;
      }
      
      // Vérifier que le cercle est bien circulaire (ratio largeur/hauteur)
      // On peut aussi vérifier la circularité en analysant les pixels
      if (!_isValidCircle(edges, circle.$0, circle.$1, radius)) {
        continue;
      }
      
      balls.add(
        Ball(
          id: 'ball_${balls.length + 1}',
          x: circle.$0.toDouble(),
          y: circle.$1.toDouble(),
          radius: radius.toDouble(),
          isPiglet: false,
        ),
      );
    }
    
    // Si on n'a pas trouvé de boules avec la détection automatique,
    // essayer une méthode alternative plus simple
    if (balls.isEmpty) {
      return _detectBallsSimple(image, pigletX, pigletY, excludeRadius);
    }
    
    return balls;
  }

  /// Méthode simplifiée de détection des boules
  /// Scanne l'image en cherchant des zones sombres (boules métalliques)
  static List<Ball> _detectBallsSimple(img.Image image, double pigletX, double pigletY, double excludeRadius) {
    final List<Ball> balls = [];
    final width = image.width;
    final height = image.height;
    
    // Diviser l'image en zones et chercher des cercles
    final cellSize = 40;
    final visited = List.filled(height, List.filled(width, false));
    
    for (int y = 0; y < height; y += cellSize ~/ 2) {
      for (int x = 0; x < width; x += cellSize ~/ 2) {
        // Sauter si déjà visité
        if (visited[y][x]) continue;
        
        // Vérifier que ce n'est pas dans la zone du cochonnet
        final distanceToPiglet = _calculateDistance(pigletX, pigletY, x.toDouble(), y.toDouble());
        if (distanceToPiglet < excludeRadius) {
          continue;
        }
        
        // Vérifier si ce point fait partie d'une zone sombre (boule)
        final avgBrightness = _getAverageBrightness(image, x, y, cellSize ~/ 2);
        
        // Les boules métalliques sont généralement sombres
        // On cherche des zones avec une luminosité moyenne faible
        if (avgBrightness < 100) {
          // Essayer de trouver le centre et le rayon
          final circle = _findCircleCenter(image, x, y, cellSize);
          if (circle != null) {
            final (cx, cy, radius) = circle;
            
            // Vérifier la taille
            if (radius >= _minBallRadiusPx && radius <= _maxBallRadiusPx) {
              balls.add(
                Ball(
                  id: 'ball_${balls.length + 1}',
                  x: cx.toDouble(),
                  y: cy.toDouble(),
                  radius: radius.toDouble(),
                  isPiglet: false,
                ),
              );
              
              // Marquer la zone comme visitée
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
        final pixel = image.getPixel(x, y);
        // Luminosité = 0.299*R + 0.587*G + 0.114*B
        final brightness = 0.299 * img.getRed(pixel) + 
                          0.587 * img.getGreen(pixel) + 
                          0.114 * img.getBlue(pixel);
        sum += brightness.toInt();
        count++;
      }
    }
    
    return count > 0 ? sum / count : 0;
  }

  /// Trouve le centre et le rayon d'un cercle potentiel
  static (int, int, int)? _findCircleCenter(img.Image image, int startX, int startY, int searchRadius) {
    int bestX = startX;
    int bestY = startY;
    int bestRadius = 0;
    double bestScore = 0;
    
    // Chercher dans une petite zone autour du point de départ
    for (int y = max(0, startY - searchRadius); y <= min(image.height - 1, startY + searchRadius); y += 2) {
      for (int x = max(0, startX - searchRadius); x <= min(image.width - 1, startX + searchRadius); x += 2) {
        // Sauter si déjà visité
        // Tester différents rayons
        for (int r = _minBallRadiusPx; r <= _maxBallRadiusPx; r += 3) {
          // Vérifier que le cercle est dans l'image
          if (x - r < 0 || x + r >= image.width || y - r < 0 || y + r >= image.height) {
            continue;
          }
          
          // Calculer un score de circularité
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
    
    // Seuil minimal pour accepter un cercle
    if (bestScore > 0.5) {
      return (bestX, bestY, bestRadius);
    }
    
    return null;
  }

  /// Calcule un score de circularité (0-1)
  static double _calculateCircularityScore(img.Image image, int centerX, int centerY, int radius) {
    int edgePoints = 0;
    int totalPoints = 0;
    
    // Vérifier des points sur le cercle
    final pointsToCheck = 20;
    for (int i = 0; i < pointsToCheck; i++) {
      final angle = 2 * pi * i / pointsToCheck;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        final pixel = image.getPixel(x.toInt(), y.toInt());
        final brightness = 0.299 * img.getRed(pixel) + 
                           0.587 * img.getGreen(pixel) + 
                           0.114 * img.getBlue(pixel);
        
        // Un bord doit avoir un contraste élevé
        // Comparer avec le centre
        final centerPixel = image.getPixel(centerX, centerY);
        final centerBrightness = 0.299 * img.getRed(centerPixel) + 
                                 0.587 * img.getGreen(centerPixel) + 
                                 0.114 * img.getBlue(centerPixel);
        
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
            final pixel = image.getPixel(x + kx, y + ky);
            final gray = 0.299 * img.getRed(pixel) + 
                        0.587 * img.getGreen(pixel) + 
                        0.114 * img.getBlue(pixel);
            
            gx += gray.toInt() * sobelX[ky + 1][kx + 1];
            gy += gray.toInt() * sobelY[ky + 1][kx + 1];
          }
        }
        
        final magnitude = sqrt(gx * gx + gy * gy).toInt();
        final edgeValue = min(255, magnitude);
        
        edges.setPixel(x, y, img.getColor(edgeValue, edgeValue, edgeValue));
      }
    }
    
    return edges;
  }

  /// Trouve les cercles dans une image de bords
  static List<(int, int, int)> _findCirclesInEdges(img.Image edges, int width, int height) {
    final List<(int, int, int)> circles = [];
    
    // Seuil pour considérer un pixel comme un bord
    final edgeThreshold = 100;
    
    // Trouver les contours
    final contours = _findContours(edges, edgeThreshold);
    
    // Pour chaque contour, essayer de fitter un cercle
    for (final contour in contours) {
      if (contour.length < 10) continue; // Trop petit
      
      // Calculer le centre de masse
      double sumX = 0;
      double sumY = 0;
      for (final point in contour) {
        sumX += point.$1;
        sumY += point.$2;
      }
      final centerX = (sumX / contour.length).round();
      final centerY = (sumY / contour.length).round();
      
      // Calculer le rayon moyen
      double sumR = 0;
      for (final point in contour) {
        final r = _calculateDistance(
          centerX.toDouble(), centerY.toDouble(),
          point.$1.toDouble(), point.$2.toDouble(),
        );
        sumR += r;
      }
      final radius = (sumR / contour.length).round();
      
      // Vérifier que le rayon est dans la plage des boules
      if (radius >= _minBallRadiusPx && radius <= _maxBallRadiusPx) {
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
    final visited = List.filled(height, List.filled(width, false));
    
    // Directions pour le parcours (8-voisins)
    final directions = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1),           (0, 1),
      (1, -1),  (1, 0),  (1, 1),
    ];
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (!visited[y][x]) {
          final pixel = image.getPixel(x, y);
          final gray = 0.299 * img.getRed(pixel) + 
                      0.587 * img.getGreen(pixel) + 
                      0.114 * img.getBlue(pixel);
          
          if (gray >= threshold) {
            // Trouver le contour
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
                  final neighborPixel = image.getPixel(nx, ny);
                  final neighborGray = 0.299 * img.getRed(neighborPixel) + 
                                      0.587 * img.getGreen(neighborPixel) + 
                                      0.114 * img.getBlue(neighborPixel);
                  
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
    
    // Vérifier des points sur la circonférence
    final pointsToCheck = 24;
    for (int i = 0; i < pointsToCheck; i++) {
      final angle = 2 * pi * i / pointsToCheck;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      
      if (x >= 0 && x < edges.width && y >= 0 && y < edges.height) {
        final pixel = edges.getPixel(x.toInt(), y.toInt());
        final gray = 0.299 * img.getRed(pixel) + 
                    0.587 * img.getGreen(pixel) + 
                    0.114 * img.getBlue(pixel);
        
        if (gray >= 100) {
          edgePoints++;
        }
        totalPoints++;
      }
    }
    
    // Au moins 60% des points doivent être des bords
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

  /// Calcule la différence de couleur entre deux pixels
  static double _colorDifference(int color1, int color2) {
    final r1 = img.getRed(color1);
    final g1 = img.getGreen(color1);
    final b1 = img.getBlue(color1);
    
    final r2 = img.getRed(color2);
    final g2 = img.getGreen(color2);
    final b2 = img.getBlue(color2);
    
    // Distance euclidienne dans l'espace RGB
    return sqrt(
      pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2),
    );
  }

  /// Convertit des pixels en centimètres
  static double pixelsToCm(double pixels, {double referenceDiameterPx = 50.0}) {
    // Éviter la division par zéro
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    
    final scale = _realBallDiameterCm / referenceDiameterPx;
    return pixels * scale;
  }

  /// Convertit des centimètres en pixels
  static double cmToPixels(double cm, {double referenceDiameterPx = 50.0}) {
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    
    final scale = referenceDiameterPx / _realBallDiameterCm;
    return cm * scale;
  }
}
