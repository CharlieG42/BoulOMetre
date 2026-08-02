import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraOverlay extends StatefulWidget {
  final List<Ball> balls;
  final bool showMeasurementGuides;
  final Function(Offset)? onPigletPositionChanged;

  const CameraOverlay({
    super.key,
    required this.balls,
    this.showMeasurementGuides = false,
    this.onPigletPositionChanged,
  });

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
  double _devicePitch = 0.0;
  double _deviceRoll = 0.0;
  bool _isListening = false;
  Offset? _manualPigletPosition;

  @override
  void initState() {
    super.initState();
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
        _devicePitch = event.pitch;
        _deviceRoll = event.roll;
      });
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
                  setState(() {
                    _manualPigletPosition = details.localPosition;
                  });
                  widget.onPigletPositionChanged!(_manualPigletPosition!);
                },
                onPanUpdate: (details) {
                  setState(() {
                    _manualPigletPosition = details.localPosition;
                  });
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
    // Draw concentric circles with alternating stroke widths
    final circlePaintThick = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final circlePaintThin = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final maxRadius = min(size.width, size.height) * 0.4;
    final numCircles = 5;

    for (int i = 1; i <= numCircles; i++) {
      final radius = (maxRadius * i) / numCircles;
      final paint = i % 2 == 0 ? circlePaintThick : circlePaintThin;
      canvas.drawCircle(center, radius, paint);
    }

    // Draw radial lines for better orientation
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
