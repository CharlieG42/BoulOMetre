import 'package:flutter/material.dart';
import 'package:boul_o_metre/screens/home_screen.dart';
import 'package:boul_o_metre/screens/camera_screen.dart';
import 'package:boul_o_metre/screens/results_screen.dart';
import 'package:boul_o_metre/models/ball.dart';

/// Classe gérant les routes de l'application.
class Routes {
  /// Route de l'écran d'accueil.
  static const String home = '/';

  /// Route de l'écran de la caméra.
  static const String camera = '/camera';

  /// Route de l'écran des résultats.
  static const String results = '/results';

  /// Map des routes de l'application.
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    camera: (context) => const CameraScreen(),
    results: (context) => ResultsScreen(balls: []),
  };

  /// Navigue vers l'écran des résultats avec une liste de boules.
  static void navigateToResults(BuildContext context, List<Ball> balls) {
    Navigator.pushNamed(
      context,
      results,
      arguments: balls,
    );
  }

  /// Récupère les arguments de la route des résultats.
  static List<Ball>? getResultsArguments(ModalRoute<dynamic> route) {
    final arguments = route.settings.arguments;
    if (arguments is List<Ball>) {
      return arguments;
    }
    return null;
  }
}
