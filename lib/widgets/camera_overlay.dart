import 'dart:math';
import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraOverlay extends StatefulWidget {
  final List<Ball> balls;
  final bool showMeasurementGuides;
  final Function(Offset)? onPigletPositionChanged;
  final Function(bool)? onHorizontalChanged;
  final double horizontalThreshold;

  const CameraOverlay({
    super.key,
    required this.balls,
    this.showMeasurementGuides = false,
    this.onPigletPositionChanged,
    this.onHorizontalChanged,
    this.horizontalThreshold = 0.1,
  });

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
  double _devicePitch = 0.0;
  double _deviceRoll = 0.0;
  bool _isListening = false;
  bool _isHorizontal = false;
  Offset? _manualPigletPosition;
  Offset? _dragStartPosition;  // Pour suivre le début du glissement

  @override
  void initState() {
    super.initState();
    _isHorizontal = false;
    _startListening();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _startListening() {
    _isListening = true;
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!mounted) return;
      setState(() {
        // Use x and y as approximation for roll and pitch
        // For a simple level indicator, we can use x for roll and y for pitch
        _deviceRoll = event.x;
        _devicePitch = event.y;
      });
      
      // Calculer l'inclinaison totale
      final tilt = sqrt(_devicePitch * _devicePitch + _deviceRoll * _deviceRoll);
      final newIsHorizontal = tilt < widget.horizontalThreshold;
      
      // Notifier si l'état a changé
      if (newIsHorizontal != _isHorizontal) {
        _isHorizontal = newIsHorizontal;
        widget.onHorizontalChanged?.call(_isHorizontal);
      }
    });
  }

  void _stopListening() {
    _isListening = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final pigletPosition = _manualPigletPosition ?? center;

        return Stack(
          children: [
            // Main overlay with crosshair and level
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _OverlayPainter(
                center: center,
                pigletPosition: pigletPosition,
                devicePitch: _devicePitch,
                deviceRoll: _deviceRoll,
                showMeasurementGuides: widget.showMeasurementGuides,
                balls: widget.balls,
              ),
            ),
            // Touch handler for manual piglet adjustment
            if (widget.onPigletPositionChanged != null)
              GestureDetector(
                onPanDown: (details) {
                  // Stocker la position de départ - NE PAS déplacer le pointeur
                  // Cela évite que le pointeur ne se cache sous le doigt
                  _dragStartPosition = details.localPosition;
                },
                onPanUpdate: (details) {
                  // Calculer le déplacement relatif par rapport au point de départ
                  final offset = details.localPosition - _dragStartPosition!;
                  
                  // Appliquer ce déplacement à la position ACTUELLE du pointeur
                  // (ou au centre si _manualPigletPosition est null)
                  final currentPosition = _manualPigletPosition ?? center;
                  setState(() {
                    _manualPigletPosition = currentPosition + offset;
                  });
                  
                  // Mettre à jour la position de départ pour le prochain événement
                  _dragStartPosition = details.localPosition;
                  
                  widget.onPigletPositionChanged!(_manualPigletPosition!);
                },
                behavior: HitTestBehavior.translucent,
              ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Offset center;
  final Offset pigletPosition;
  final double devicePitch;
  final double deviceRoll;
  final bool showMeasurementGuides;
  final List<Ball> balls;

  _OverlayPainter({
    required this.center,
    required this.pigletPosition,
    required this.devicePitch,
    required this.deviceRoll,
    required this.showMeasurementGuides,
    required this.balls,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw crosshair at center (or at manual piglet position if adjusted)
    _drawCrosshair(canvas, pigletPosition);

    // Draw level indicator
    _drawLevelIndicator(canvas, size, devicePitch, deviceRoll);

    // Draw measurement guides if enabled
    if (showMeasurementGuides) {
      _drawMeasurementGuides(canvas, pigletPosition, size);
    }

    // Draw detected balls (if any)
    if (balls.isNotEmpty) {
      _drawDetectedBalls(canvas, balls, pigletPosition);
    }
  }

  void _drawCrosshair(Canvas canvas, Offset position) {
    final crosshairPaint = Paint()
      ..color = AppConstants.pigletColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final crosshairSize = 40.0;

    // Horizontal line
    canvas.drawLine(
      Offset(position.dx - crosshairSize, position.dy),
      Offset(position.dx + crosshairSize, position.dy),
      crosshairPaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(position.dx, position.dy - crosshairSize),
      Offset(position.dx, position.dy + crosshairSize),
      crosshairPaint,
    );

    // Center circle (piglet position)
    final centerPaint = Paint()
      ..color = AppConstants.pigletColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 8.0, centerPaint);

    // Outer ring
    final ringPaint = Paint()
      ..color = AppConstants.pigletColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, 15.0, ringPaint);
  }

  void _drawLevelIndicator(Canvas canvas, Size size, double pitch, double roll) {
    // Calculate device tilt
    final tilt = sqrt(pitch * pitch + roll * roll);
    final maxTilt = 0.5; // About 30 degrees
    final tiltPercentage = (tilt / maxTilt).clamp(0.0, 1.0);

    // Draw level indicator in top-right corner
    final indicatorSize = 60.0;
    final indicatorX = size.width - indicatorSize - 20;
    final indicatorY = 20.0;

    // Background
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(indicatorX, indicatorY, indicatorSize, indicatorSize),
        const Radius.circular(8.0),
      ),
      bgPaint,
    );

    // Level bubble
    final bubbleSize = 20.0;
    final bubbleX = indicatorX + (indicatorSize - bubbleSize) / 2 - tiltPercentage * (indicatorSize - bubbleSize) / 2;
    final bubbleY = indicatorY + (indicatorSize - bubbleSize) / 2 - tiltPercentage * (indicatorSize - bubbleSize) / 2;

    final bubblePaint = Paint()
      ..color = tiltPercentage < 0.2 ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleSize / 2, bubblePaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(indicatorX, indicatorY, indicatorSize, indicatorSize),
        const Radius.circular(8.0),
      ),
      borderPaint,
    );

    // Cross in the center of the level
    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(indicatorX + indicatorSize / 2 - 8, indicatorY + indicatorSize / 2),
      Offset(indicatorX + indicatorSize / 2 + 8, indicatorY + indicatorSize / 2),
      crossPaint,
    );
    canvas.drawLine(
      Offset(indicatorX + indicatorSize / 2, indicatorY + indicatorSize / 2 - 8),
      Offset(indicatorX + indicatorSize / 2, indicatorY + indicatorSize / 2 + 8),
      crossPaint,
    );
  }

  void _drawMeasurementGuides(Canvas canvas, Offset center, Size size) {
    final maxRadius = min(size.width, size.height) * 0.4;
    final totalCircles = 15;  // 15 cercles au total

    // 4. Dessiner les lignes radiales pour une meilleure orientation
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int angle = 0; angle < 360; angle += 45) {
      final rad = angle * pi / 180;
      final x1 = center.dx + cos(rad) * 20;
      final y1 = center.dy + sin(rad) * 20;
      final x2 = center.dx + cos(rad) * maxRadius;
      final y2 = center.dy + sin(rad) * maxRadius;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }

    // Dessiner 15 cercles avec alternance tirets/lignes et couleurs bleu/blanc/rouge
    for (int i = 1; i <= totalCircles; i++) {
      final radius = (maxRadius * i) / totalCircles;
      
      // Déterminer le style : alterner entre tirets fins et lignes continues fines
      final isDashed = i % 2 == 0;  // Pair = tirets, Impair = ligne continue
      
      // Déterminer la couleur : alterner entre bleu, blanc, rouge
      final colorIndex = i % 3;
      Color circleColor;
      switch (colorIndex) {
        case 0:
          circleColor = Colors.blue.withOpacity(0.8);
          break;
        case 1:
          circleColor = Colors.white.withOpacity(0.8);
          break;
        case 2:
          circleColor = Colors.red.withOpacity(0.8);
          break;
        default:
          circleColor = Colors.white.withOpacity(0.8);
      }
      
      if (isDashed) {
        // Cercle en tirets fins
        final dashedPaint = Paint()
          ..color = circleColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round;
        _drawDashedCircle(canvas, center, radius, dashedPaint);
      } else {
        // Cercle en ligne continue fine
        final solidPaint = Paint()
          ..color = circleColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(center, radius, solidPaint);
      }
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final angle1 = (i * (dashWidth + dashSpace)) / circumference * 2 * pi;
      final angle2 = ((i + 1) * dashWidth + i * dashSpace) / circumference * 2 * pi;

      final x1 = center.dx + cos(angle1) * radius;
      final y1 = center.dy + sin(angle1) * radius;
      final x2 = center.dx + cos(angle2) * radius;
      final y2 = center.dy + sin(angle2) * radius;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawDetectedBalls(Canvas canvas, List<Ball> balls, Offset pigletPosition) {
    if (balls.isEmpty || !balls.any((ball) => ball.isPiglet)) return;
    final piglet = balls.firstWhere((ball) => ball.isPiglet);

    // Draw piglet
    final pigletPaint = Paint()
      ..color = AppConstants.pigletColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(Offset(piglet.x, piglet.y), piglet.radius, pigletPaint);

    final pigletFillPaint = Paint()
      ..color = AppConstants.pigletColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(piglet.x, piglet.y), piglet.radius, pigletFillPaint);

    // Draw balls
    final ballPaint = Paint()
      ..color = AppConstants.ballColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (final ball in balls.where((ball) => !ball.isPiglet)) {
      canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, ballPaint);

      // Draw line to piglet
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawLine(
        Offset(ball.x, ball.y),
        Offset(piglet.x, piglet.y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.pigletPosition != pigletPosition ||
        oldDelegate.devicePitch != devicePitch ||
        oldDelegate.deviceRoll != deviceRoll ||
        oldDelegate.showMeasurementGuides != showMeasurementGuides ||
        oldDelegate.balls != balls;
  }
}
