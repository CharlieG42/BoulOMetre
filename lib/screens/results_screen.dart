import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/widgets/distance_card.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:boul_o_metre/utils/helpers.dart';

class ResultsScreen extends StatelessWidget {
  final List<Ball> balls;

  const ResultsScreen({super.key, required this.balls});

  @override
  Widget build(BuildContext context) {
    final piglet = balls.where((ball) => ball.isPiglet).firstOrNull;
    
    if (piglet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resultats'),
        ),
        body: const Center(
          child: Text(
            'Aucun cochonnet detecte. Veuillez reessayer.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final sortedBalls = [...balls.where((ball) => !ball.isPiglet)]
      ..sort((a, b) => a.distanceToPiglet.compareTo(b.distanceToPiglet));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalite a venir')),
              );
            },
            tooltip: 'Partager',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Nouvelle mesure',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Distances par rapport au cochonnet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: AppConstants.pigletColor,
                      size: 30,
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    const Text(
                      'Cochonnet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Position: (${piglet.x.toStringAsFixed(1)}, ${piglet.y.toStringAsFixed(1)})',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Expanded(
              child: ListView.builder(
                itemCount: sortedBalls.length,
                itemBuilder: (context, index) {
                  final ball = sortedBalls[index];
                  return DistanceCard(
                    ball: ball,
                    isClosest: index == 0,
                  );
                },
              ),
            ),
            if (sortedBalls.isNotEmpty) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Card(
                color: AppConstants.closestBallColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      Text(
                        'Boule la plus proche: ${sortedBalls.first.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.closestBallColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding / 2),
                      Text(
                        'Distance: ${Helpers.formatDistance(sortedBalls.first.distanceToPiglet)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
