import 'package:flutter/material.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/widgets/distance_card.dart';
import 'package:boul_o_metre/utils/constants.dart';
import 'package:boul_o_metre/utils/helpers.dart';

/// Écran d'affichage des résultats de mesure.
class ResultsScreen extends StatelessWidget {
  final List<Ball> balls;

  const ResultsScreen({super.key, required this.balls});

  @override
  Widget build(BuildContext context) {
    final piglet = balls.firstWhere((ball) => ball.isPiglet, orElse: () => null);

    if (piglet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Résultats'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppConstants.errorColor,
                ),
                const SizedBox(height: AppConstants.largePadding),
                Text(
                  AppConstants.noPigletDetected,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                const Text(
                  'Veuillez vous assurer que le cochonnet est bien visible '
                  'et réessayer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: AppConstants.largePadding),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sortedBalls = [...balls.where((ball) => !ball.isPiglet)]
      ..sort((a, b) => a.distanceToPiglet.compareTo(b.distanceToPiglet));

    if (sortedBalls.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Résultats'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 80,
                  color: AppConstants.errorColor,
                ),
                const SizedBox(height: AppConstants.largePadding),
                Text(
                  AppConstants.noBallsDetected,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                const Text(
                  'Aucune boule n\'a été détectée. '
                  'Assurez-vous que les boules sont bien visibles.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: AppConstants.largePadding),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir dans la V2'),
                  backgroundColor: AppConstants.accentColor,
                ),
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
            // Titre
            const Text(
              'Distances par rapport au cochonnet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),

            // Carte du cochonnet
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
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

            // Liste des boules
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

            // Résumé
            if (sortedBalls.isNotEmpty) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Card(
                elevation: 4,
                color: AppConstants.closestBallColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  side: BorderSide(
                    color: AppConstants.closestBallColor,
                    width: 2,
                  ),
                ),
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
                      const SizedBox(height: AppConstants.tinyPadding),
                      Text(
                        'Distance: ${Helpers.formatDistance(sortedBalls.first.distanceToPiglet)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.tinyPadding),
                      Text(
                        'Écart avec la 2ème: ${sortedBalls.length > 1 ? Helpers.formatDistance(sortedBalls[1].distanceToPiglet - sortedBalls.first.distanceToPiglet) : 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
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
