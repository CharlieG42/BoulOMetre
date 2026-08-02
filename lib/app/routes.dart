import 'package:flutter/material.dart';
import 'package:boul_o_metre/screens/home_screen.dart';
import 'package:boul_o_metre/screens/camera_screen.dart';
import 'package:boul_o_metre/screens/results_screen.dart';
import 'package:boul_o_metre/models/ball.dart';

class Routes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String results = '/results';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    camera: (context) => const CameraScreen(),
    results: (context) => ResultsScreen(
          balls: ModalRoute.of(context)!.settings.arguments as List<Ball>? ?? [],
        ),
  };
}