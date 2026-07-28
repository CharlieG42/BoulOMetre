import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:boul_o_metre/utils/helpers.dart';
import 'package:boul_o_metre/services/orientation_service.dart';

class CameraOverlay extends StatefulWidget {
  final List<Ball> balls;

  const CameraOverlay({super.key, required this.balls});

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
  final OrientationService _orientationService = OrientationService();

  @override
  void initState() {
    super.initState();
    _orientationService.start();
  }

  @override
  void dispose() {
    _orientationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: _OverlayPainter(balls: widget.balls),
          child: Container(),
        ),
        // Reperes au centre de l'image (crosshair)
        const Center(
          child: _Crosshair(),
        ),
        // Indicateur de niveau pour l'horizontalite
        Positioned(
          top: AppConstants.largePadding,
          right: AppConstants.defaultPadding,
          child: _LevelIndicator(orientationService: _orientationService),
        ),
      ],
    );
  }
}

/// Widget pour afficher le repaire central (crosshair)
class _Crosshair extends StatelessWidget {
  const _Crosshair();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Stack(
        children: [
          // Ligne horizontale
          Center(
            child: Container(
              width: double.infinity,
              height: 2.0,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          // Ligne verticale
          Center(
            child: Container(
              width: 2.0,
              height: double.infinity,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          // Point central
          const Center(
            child: Icon(
              Icons.circle,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher l'indicateur de niveau
class _LevelIndicator extends StatelessWidget {
  final OrientationService orientationService;

  const _LevelIndicator({required this.orientationService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: orientationService.angleStream,
      initialData: 0.0,
      builder: (context, snapshot) {
        final angle = snapshot.data ?? 0.0;
        final isHorizontal = angle.abs() < OrientationService.horizontalThreshold;
        
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.smallPadding,
            vertical: AppConstants.smallPadding / 2,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isHorizontal ? Icons.check : Icons.close,
                color: isHorizontal ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isHorizontal ? 'Niveau OK' : 'Inclinez',
                style: TextStyle(
                  color: isHorizontal ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final List<Ball> balls;

  _OverlayPainter({required this.balls});

  @override
  void paint(Canvas canvas, Size size) {
    final piglet = balls.where((ball) => ball.isPiglet).firstOrNull;
    if (piglet == null) return;

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

    final ballPaint = Paint()
      ..color = AppConstants.ballColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final ballFillPaint = Paint()
      ..color = AppConstants.ballColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

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

      canvas.drawLine(
        Offset(ball.x, ball.y),
        Offset(piglet.x, piglet.y),
        linePaint,
      );

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

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.balls != balls;
  }
}
