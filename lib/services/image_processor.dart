import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/models/ball.dart';

class ImageProcessor {
  static const int _edgeThreshold = 120;
  static const int _minRadius = 3;
  static const int _maxRadius = 120;
  static const double _realBallDiameterCm = 7.5;
  static const double _realPigletDiameterCm = 3.0;
  static const int _circleThreshold = 15;
  static const int _radiusStep = 2;

  static List<Ball> detectBallsAndPiglet(img.Image image) {
    final List<Ball> detectedObjects = [];
    final width = image.width;
    final height = image.height;

    // Reduce image size for faster processing
    final maxSize = max(width, height);
    final scaleFactor = maxSize > 800 ? 800.0 / maxSize : 1.0;
    final scaledWidth = (width * scaleFactor).toInt();
    final scaledHeight = (height * scaleFactor).toInt();
    
    final scaledImage = img.copyResize(image, width: scaledWidth, height: scaledHeight);
    
    // Convert to grayscale
    final grayscale = img.grayscale(scaledImage);
    
    // Apply edge detection (Sobel operator)
    final edges = _detectEdges(grayscale);
    
    // Find circles using optimized approach
    final circles = _findCircles(edges, scaledWidth, scaledHeight);
    
    if (circles.isEmpty) {
      // Fallback: return empty list if no circles detected
      return [];
    }
    
    // Sort circles by radius (smallest first - likely piglet)
    circles.sort((a, b) => a['radius'].compareTo(b['radius']));
    
    // The smallest circle is likely the piglet
    final pigletCircle = circles.first;
    final piglet = Ball(
      id: 'piglet',
      x: pigletCircle['x']! / scaleFactor,
      y: pigletCircle['y']! / scaleFactor,
      radius: pigletCircle['radius']! / scaleFactor,
      isPiglet: true,
    );
    detectedObjects.add(piglet);
    
    // The remaining circles are balls
    final ballCircles = circles.sublist(1);
    for (int i = 0; i < ballCircles.length; i++) {
      final circle = ballCircles[i];
      final distance = _calculateDistance(
        piglet.x, piglet.y,
        circle['x']! / scaleFactor, circle['y']! / scaleFactor,
      );
      
      // Use piglet diameter as reference for scale
      final referenceDiameterPx = piglet.radius * 2;
      final distanceCm = pixelsToCm(distance, referenceDiameterPx: referenceDiameterPx);
      
      detectedObjects.add(Ball(
        id: 'ball_${i + 1}',
        x: circle['x']! / scaleFactor,
        y: circle['y']! / scaleFactor,
        radius: circle['radius']! / scaleFactor,
        distanceToPiglet: distanceCm,
        isPiglet: false,
      ));
    }

    return detectedObjects;
  }

  static img.Image _detectEdges(img.Image grayscale) {
    final width = grayscale.width;
    final height = grayscale.height;
    final edges = img.Image(width: width, height: height);
    
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Sobel operator - optimized
        final p11 = img.getRed(grayscale.getPixel(x - 1, y - 1));
        final p12 = img.getRed(grayscale.getPixel(x, y - 1));
        final p13 = img.getRed(grayscale.getPixel(x + 1, y - 1));
        final p21 = img.getRed(grayscale.getPixel(x - 1, y));
        final p23 = img.getRed(grayscale.getPixel(x + 1, y));
        final p31 = img.getRed(grayscale.getPixel(x - 1, y + 1));
        final p32 = img.getRed(grayscale.getPixel(x, y + 1));
        final p33 = img.getRed(grayscale.getPixel(x + 1, y + 1));
        
        final gx = p13 + 2 * p23 + p33 - p11 - 2 * p21 - p31;
        final gy = p31 + 2 * p32 + p33 - p11 - 2 * p12 - p13;
        
        final gradient = sqrt(gx * gx + gy * gy).toInt();
        final edgeValue = gradient > _edgeThreshold ? 255 : 0;
        
        edges.setPixel(x, y, img.ColorRgb8(edgeValue, edgeValue, edgeValue));
      }
    }
    
    return edges;
  }

  static List<Map<String, int>> _findCircles(img.Image edges, int width, int height) {
    final List<Map<String, int>> circles = [];
    final int maxRadius = min(_maxRadius, min(width, height) ~/ 2);
    
    // Find edge points
    final edgePoints = <Map<String, int>>[];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = edges.getPixel(x, y);
        final r = img.getRed(pixel);
        if (r > 200) {
          edgePoints.add({'x': x, 'y': y});
        }
      }
    }
    
    // If not enough edge points, return empty
    if (edgePoints.length < 100) {
      return [];
    }
    
    // Sample edge points for performance
    final sampleSize = min(edgePoints.length, 200);
    final sampledPoints = edgePoints.length > sampleSize
        ? List.generate(sampleSize, (i) => edgePoints[(i * edgePoints.length / sampleSize).floor()])
        : edgePoints;
    
    // Use a map to accumulate votes: key = "x,y,r", value = count
    final votes = <String, int>{};
    
    for (final point in sampledPoints) {
      final x = point['x']!;
      final y = point['y']!;
      
      // Sample a subset of possible radii
      for (int r = _minRadius; r < maxRadius; r += _radiusStep) {
        // Sample angles around the circle
        for (int angle = 0; angle < 360; angle += 15) {
          final rad = angle * pi / 180;
          final cx = x + r * cos(rad);
          final cy = y + r * sin(rad);
          
          if (cx >= 0 && cx < width && cy >= 0 && cy < height) {
            final cxi = cx.round();
            final cyi = cy.round();
            final key = '${cxi},${cyi},$r';
            votes[key] = (votes[key] ?? 0) + 1;
          }
        }
      }
    }
    
    // Find local maxima
    final candidates = <Map<String, int>>[];
    for (final entry in votes.entries) {
      if (entry.value > _circleThreshold) {
        final parts = entry.key.split(',');
        candidates.add({
          'x': int.parse(parts[0]),
          'y': int.parse(parts[1]),
          'radius': int.parse(parts[2]),
          'votes': entry.value,
        });
      }
    }
    
    // Sort by votes (descending)
    candidates.sort((a, b) => b['votes']!.compareTo(a['votes']!));
    
    // Filter to keep only the best candidates, removing duplicates
    final result = <Map<String, int>>[];
    for (final candidate in candidates) {
      bool isDuplicate = false;
      for (final existing in result) {
        final dx = candidate['x']! - existing['x']!;
        final dy = candidate['y']! - existing['y']!;
        final dr = candidate['radius']! - existing['radius']!;
        if (dx * dx + dy * dy + dr * dr < 400) {
          isDuplicate = true;
          break;
        }
      }
      
      if (!isDuplicate) {
        result.add(candidate);
      }
      
      // Limit number of circles
      if (result.length >= 10) break;
    }
    
    // Convert back to expected format
    return result.map((c) => {'x': c['x']!, 'y': c['y']!, 'radius': c['radius']!}).toList();
  }

  static double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  static double pixelsToCm(double pixels, {double referenceDiameterPx = 50.0}) {
    // Use piglet diameter as reference
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    final scale = _realPigletDiameterCm / referenceDiameterPx;
    return pixels * scale;
  }

  static double cmToPixels(double cm, {double referenceDiameterPx = 50.0}) {
    if (referenceDiameterPx <= 0) {
      referenceDiameterPx = 50.0;
    }
    final scale = referenceDiameterPx / _realPigletDiameterCm;
    return cm * scale;
  }
}
