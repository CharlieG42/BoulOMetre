import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:boul_o_metre/utils/helpers.dart';

class DistanceCard extends StatelessWidget {
  final Ball ball;
  final bool isClosest;

  const DistanceCard({
    super.key,
    required this.ball,
    this.isClosest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      elevation: isClosest ? 4 : 2,
      color: isClosest ? AppConstants.closestBallColor.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: isClosest
            ? BorderSide(color: AppConstants.closestBallColor, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.sports,
              color: isClosest ? AppConstants.closestBallColor : AppConstants.ballColor,
              size: 30,
            ),
            if (isClosest)
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 15,
              ),
          ],
        ),
        title: Text(
          'Boule ${ball.id}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isClosest ? AppConstants.closestBallColor : null,
          ),
        ),
        subtitle: Text(
          'Position: (${ball.x.toStringAsFixed(1)}, ${ball.y.toStringAsFixed(1)})',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Helpers.formatDistance(ball.distanceToPiglet),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isClosest ? AppConstants.closestBallColor : null,
              ),
            ),
            if (isClosest)
              const Text(
                'La plus proche',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
