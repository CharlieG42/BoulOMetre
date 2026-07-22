import 'package:flutter/material.dart';
import 'package:boul_o_metre/app/routes.dart';
import 'package:boul_o_metre/utils/constants.dart';

/// Widget racine de l'application Boul'O'Mètre.
class BoulOMetreApp extends StatelessWidget {
  /// Crée une instance de BoulOMetreApp.
  const BoulOMetreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.black26,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.all(AppConstants.smallPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultPadding / 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.home,
      routes: Routes.routes,
    );
  }
}
