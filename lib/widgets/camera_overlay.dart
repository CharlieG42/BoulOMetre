import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:boul_o_metre/utils/helpers.dart';

class CameraOverlay extends StatelessWidget {
  final List<Ball> balls;

  const CameraOverlay({super.key, required this.balls});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(balls: balls),
      child: Container(),
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
