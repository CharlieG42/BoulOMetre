import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:boul_o_metre/utils/helpers.dart';

class CameraOverlay extends StatelessWidget {
  final List<Ball> balls;
  final double centerX; // Position X normalisée (0-1)
  final double centerY; // Position Y normalisée (0-1)
  final bool isLevel;
  final double pitch;
  final double roll;

  const CameraOverlay({
    super.key,
    required this.balls,
    this.centerX = 0.5,
    this.centerY = 0.5,
    this.isLevel = false,
    this.pitch = 0.0,
    this.roll = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        return CustomPaint(
          painter: _OverlayPainter(
            balls: balls,
            centerX: centerX * size.width,
            centerY: centerY * size.height,
            isLevel: isLevel,
            pitch: pitch,
            roll: roll,
            canvasSize: size,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final List<Ball> balls;
  final double centerX;
  final double centerY;
  final bool isLevel;
  final double pitch;
  final double roll;
  final Size canvasSize;

  _OverlayPainter({
    required this.balls,
    required this.centerX,
    required this.centerY,
    required this.isLevel,
    required this.pitch,
    required this.roll,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner le repère central pour le cochonnet
    _drawCenterMarker(canvas, size);
    
    // Dessiner l'indicateur de niveau
    _drawLevelIndicator(canvas, size);
    
    // Dessiner les boules et le cochonnet détectés
    if (balls.isNotEmpty) {
      _drawBallsAndPiglet(canvas, size);
    }
  }

  /// Dessine le repère central pour positionner le cochonnet
  void _drawCenterMarker(Canvas canvas, Size size) {
    final markerRadius = 30.0;
    final innerRadius = 10.0;
    
    // Cercle extérieur
    final outerPaint = Paint()
      ..color = AppConstants.pigletColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      markerRadius,
      outerPaint,
    );
    
    // Cercle intérieur (point central)
    final innerPaint = Paint()
      ..color = AppConstants.pigletColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      innerRadius,
      innerPaint,
    );
    
    // Lignes de visée (croix)
    final linePaint = Paint()
      ..color = AppConstants.pigletColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Ligne horizontale
    canvas.drawLine(
      Offset(centerX - markerRadius, centerY),
      Offset(centerX + markerRadius, centerY),
      linePaint,
    );
    
    // Ligne verticale
    canvas.drawLine(
      Offset(centerX, centerY - markerRadius),
      Offset(centerX, centerY + markerRadius),
      linePaint,
    );
    
    // Texte d'instruction
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Cochonnet',
        style: TextStyle(
          color: AppConstants.pigletColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY + markerRadius + 5,
      ),
    );
  }

  /// Dessine l'indicateur de niveau
  void _drawLevelIndicator(Canvas canvas, Size size) {
    final indicatorWidth = 150.0;
    final indicatorHeight = 30.0;
    final indicatorX = size.width - indicatorWidth - 20;
    final indicatorY = 50.0;
    
    // Fond de l'indicateur
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final bgRect = Rect.fromLTWH(
      indicatorX,
      indicatorY,
      indicatorWidth,
      indicatorHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      bgPaint,
    );
    
    // Calculer la position de la bulle
    final levelScore = _calculateLevelScore();
    final bubbleX = indicatorX + (indicatorWidth - 20) * (levelScore / 100) + 10;
    
    // Dessiner la bulle
    final bubblePaint = Paint()
      ..color = isLevel ? Colors.green : Colors.orange
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(bubbleX, indicatorY + indicatorHeight / 2),
      8.0,
      bubblePaint,
    );
    
    // Texte
    final textPainter = TextPainter(
      text: TextSpan(
        text: isLevel ? 'Niveau OK' : 'Incliné',
        style: TextStyle(
          color: isLevel ? Colors.green : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(
      canvas,
      Offset(
        indicatorX + 10,
        indicatorY + (indicatorHeight - textPainter.height) / 2,
      ),
    );
    
    // Indicateur visuel de l'inclinaison
    _drawInclinationVisual(canvas, size);
  }

  /// Calcule un score de niveau (0-100)
  double _calculateLevelScore() {
    const threshold = 5.0;
    final pitchScore = (pitch.abs() / threshold) * 50;
    final rollScore = (roll.abs() / threshold) * 50;
    return (pitchScore + rollScore).clamp(0, 100);
  }

  /// Dessine une représentation visuelle de l'inclinaison
  void _drawInclinationVisual(Canvas canvas, Size size) {
    final visualSize = 80.0;
    final visualX = size.width - visualSize - 20;
    final visualY = 100.0;
    
    // Cercle de base
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(
      Offset(visualX + visualSize / 2, visualY + visualSize / 2),
      visualSize / 2,
      circlePaint,
    );
    
    // Ligne horizontale de référence
    final refLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawLine(
      Offset(visualX + 10, visualY + visualSize / 2),
      Offset(visualX + visualSize - 10, visualY + visualSize / 2),
      refLinePaint,
    );
    
    // Ligne verticale de référence
    canvas.drawLine(
      Offset(visualX + visualSize / 2, visualY + 10),
      Offset(visualX + visualSize / 2, visualY + visualSize - 10),
      refLinePaint,
    );
    
    // Dessiner l'inclinaison
    // Convertir pitch et roll en déplacement visuel
    final maxAngle = 15.0;
    final scale = visualSize / 2 / maxAngle;
    
    final dx = roll * scale;
    final dy = pitch * scale;
    
    // Cercle rouge montrant l'inclinaison
    final redPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(
        visualX + visualSize / 2 + dx,
        visualY + visualSize / 2 + dy,
      ),
      4.0,
      redPaint,
    );
  }

  /// Dessine les boules et le cochonnet détectés
  void _drawBallsAndPiglet(Canvas canvas, Size size) {
    // Utiliser firstOrNull au lieu de firstWhere avec orElse
    final piglet = balls.where((ball) => ball.isPiglet).firstOrNull;
    
    if (piglet != null) {
      // Dessiner le cochonnet
      final pigletPaint = Paint()
        ..color = AppConstants.pigletColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      
      canvas.drawCircle(
        Offset(piglet.x, piglet.y),
        piglet.radius,
        pigletPaint,
      );

      final pigletFillPaint = Paint()
        ..color = AppConstants.pigletColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(piglet.x, piglet.y),
        piglet.radius,
        pigletFillPaint,
      );

      // Texte "Cochonnet"
      final pigletTextPainter = TextPainter(
        text: const TextSpan(
          text: 'Cochonnet',
          style: TextStyle(
            color: AppConstants.pigletColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      pigletTextPainter.paint(
        canvas,
        Offset(
          piglet.x - pigletTextPainter.width / 2,
          piglet.y - piglet.radius - pigletTextPainter.height - 5,
        ),
      );
    }

    final sortedBalls = [...balls.where((ball) => !ball.isPiglet)]
      ..sort((a, b) => a.distanceToPiglet.compareTo(b.distanceToPiglet));
    final closestBall = sortedBalls.isNotEmpty ? sortedBalls.first : null;

    for (final ball in balls.where((ball) => !ball.isPiglet)) {
      final isClosest = closestBall?.id == ball.id;
      final currentBallColor = isClosest
          ? AppConstants.closestBallColor
          : AppConstants.ballColor;
      
      final currentBallPaint = Paint()
        ..color = currentBallColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isClosest ? 5.0 : 3.0;
      
      final currentBallFillPaint = Paint()
        ..color = currentBallColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(ball.x, ball.y),
        ball.radius,
        currentBallFillPaint,
      );
      canvas.drawCircle(
        Offset(ball.x, ball.y),
        ball.radius,
        currentBallPaint,
      );

      // Dessiner la ligne vers le cochonnet
      if (piglet != null) {
        canvas.drawLine(
          Offset(ball.x, ball.y),
          Offset(piglet.x, piglet.y),
          linePaint,
        );

        // Texte de distance
        final distanceCm = ball.distanceToPiglet;
        final text = Helpers.formatDistance(distanceCm);
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: isClosest ? AppConstants.closestBallColor : Colors.white,
              fontSize: 16,
              fontWeight: isClosest ? FontWeight.bold : FontWeight.normal,
              shadows: [
                const Shadow(
                  blurRadius: 2,
                  color: Colors.black,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        
        final middleX = (ball.x + piglet.x) / 2;
        final middleY = (ball.y + piglet.y) / 2;
        
        textPainter.paint(
          canvas,
          Offset(
            middleX - textPainter.width / 2,
            middleY - textPainter.height / 2 - 10,
          ),
        );
      }
    }
  }

  // Déclarer linePaint au niveau de la classe pour qu'il soit accessible
  final linePaint = Paint()
    ..color = Colors.white.withOpacity(0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.balls != balls ||
           oldDelegate.centerX != centerX ||
           oldDelegate.centerY != centerY ||
           oldDelegate.isLevel != isLevel ||
           oldDelegate.pitch != pitch ||
           oldDelegate.roll != roll;
  }
}
