import 'package:flutter/material.dart';
import 'package:boul_o_metre/app/routes.dart';

class BoulOMetreApp extends StatelessWidget {
  const BoulOMetreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boul'O'Mètre',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.home,
      routes: Routes.routes,
    );
  }
}