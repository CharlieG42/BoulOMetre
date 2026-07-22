import 'package:flutter/material.dart';

/// Constantes globales de l'application.
class AppConstants {
  // Couleurs
  static const Color primaryColor = Color(0xFF8B4513);
  static const Color secondaryColor = Color(0xFFCD853F);
  static const Color accentColor = Color(0xFFFFD700);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color ballColor = Color(0xFF4682B4);
  static const Color pigletColor = Color(0xFFDC143C);
  static const Color closestBallColor = Color(0xFF228B22);
  static const Color errorColor = Color(0xFFFF4444);
  static const Color successColor = Color(0xFF4CAF50);

  // Espacements
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double tinyPadding = 4.0;

  // Bordures
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  // Texte
  static const String appName = "Boul'O'Mètre";
  static const String appTagline = "Mesurez vos lancers de pétanque avec précision";

  // Dimensions réelles (en cm)
  /// Diamètre réel d'une boule de pétanque (norme FFPJP).
  static const double realBallDiameter = 7.5;

  /// Diamètre réel du cochonnet (norme FFPJP).
  static const double realPigletDiameter = 3.0;

  // Dimensions par défaut (en pixels)
  /// Diamètre par défaut du cochonnet en pixels (pour la calibration initiale).
  static const double defaultPigletDiameterPx = 30.0;

  // Messages
  static const String cameraPermissionDenied = 'Permission caméra refusée';
  static const String noCameraFound = 'Aucune caméra disponible';
  static const String cameraInitializationError = 'Erreur lors de l\'initialisation de la caméra';
  static const String pictureError = 'Erreur lors de la prise de photo';
  static const String noPigletDetected = 'Aucun cochonnet détecté';
  static const String noBallsDetected = 'Aucune boule détectée';

  // Seuil de détection
  static const double minDetectionConfidence = 0.7;
}
