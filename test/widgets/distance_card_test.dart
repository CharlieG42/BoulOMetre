import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boul_o_metre/widgets/distance_card.dart';
import 'package:boul_o_metre/models/ball.dart';

void main() {
  group('DistanceCard Widget Tests', () {
    // Boule pour les tests
    final ball = Ball(
      id: 'ball_1',
      x: 100.0,
      y: 200.0,
      radius: 15.0,
      distanceToPiglet: 50.0,
    );

    // Test de rendu de base
    testWidgets('DistanceCard renders with ball', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DistanceCard(ball: ball),
          ),
        ),
      );

      // Vérifier que le texte de la distance est présent
      expect(find.text('50,0 cm'), findsOneWidget);
      // Vérifier que l'ID de la boule est présent
      expect(find.text('Boule ball_1'), findsOneWidget);
    });

    // Test avec isClosest = true
    testWidgets('DistanceCard renders as closest', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DistanceCard(ball: ball, isClosest: true),
          ),
        ),
      );

      // Vérifier que le texte "La plus proche" est présent
      expect(find.text('La plus proche'), findsOneWidget);
    });

    // Test avec isClosest = false
    testWidgets('DistanceCard renders not as closest', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DistanceCard(ball: ball, isClosest: false),
          ),
        ),
      );

      // Vérifier que le texte "La plus proche" n'est pas présent
      expect(find.text('La plus proche'), findsNothing);
    });

    // Test de l'icône
    testWidgets('DistanceCard shows sports icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DistanceCard(ball: ball),
          ),
        ),
      );

      // Vérifier que l'icône de sport est présente
      expect(find.byIcon(Icons.sports), findsOneWidget);
    });

    // Test de l'icône étoile pour la boule la plus proche
    testWidgets('DistanceCard shows star icon for closest ball', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DistanceCard(ball: ball, isClosest: true),
          ),
        ),
      );

      // Vérifier que l'icône étoile est présente
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    // Test des positions
    testWidgets('DistanceCard shows position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DistanceCard(ball: ball),
          ),
        ),
      );

      // Vérifier que la position est affichée
      expect(find.textContaining('100,0'), findsOneWidget);
      expect(find.textContaining('200,0'), findsOneWidget);
    });

    // Test de l'élévation de la carte
    testWidgets('DistanceCard has correct elevation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DistanceCard(ball: ball, isClosest: false),
                DistanceCard(ball: ball, isClosest: true),
              ],
            ),
          ),
        ),
      );

      // Vérifier que les cartes ont les bonnes élévations
      final cards = tester.widgetList<Card>(find.byType(Card));
      expect(cards.length, 2);
      expect(cards[0].elevation, 2); // isClosest = false
      expect(cards[1].elevation, 4); // isClosest = true
    });
  });
}
