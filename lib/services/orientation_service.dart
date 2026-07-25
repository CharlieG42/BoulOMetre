import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

/// Service pour gérer l'orientation du téléphone et détecter si il est à l'horizontale
class OrientationService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Seuil pour considérer le téléphone comme horizontal (en degrés)
  static const double horizontalThreshold = 5.0;
  
  // Filtre passe-bas pour lisser les valeurs
  static const double smoothingFactor = 0.2;
  
  double _smoothedPitch = 0.0;
  double _smoothedRoll = 0.0;
  
  bool _isHorizontal = false;
  double _pitch = 0.0; // Inclinaison avant/arrière (degrés)
  double _roll = 0.0;  // Inclinaison gauche/droite (degrés)
  
  bool get isHorizontal => _isHorizontal;
  double get pitch => _pitch;
  double get roll => _roll;
  
  // Callbacks pour les mises à jour
  void Function(bool)? onHorizontalChanged;
  void Function(double, double)? onOrientationChanged;

  /// Démarre la détection de l'orientation
  void start() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      _processAccelerometerEvent(event);
    });
    
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      _processGyroscopeEvent(event);
    });
  }

  /// Arrête la détection de l'orientation
  void stop() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
  }

  /// Traite les données de l'accéléromètre
  void _processAccelerometerEvent(AccelerometerEvent event) {
    final x = event.x;
    final y = event.y;
    final z = event.z;
    
    final pitchRad = atan2(-x, sqrt(y * y + z * z));
    final newPitch = pitchRad * (180 / pi);
    
    final rollRad = atan2(y, sqrt(x * x + z * z));
    final newRoll = rollRad * (180 / pi);
    
    _smoothedPitch = smoothingFactor * newPitch + (1 - smoothingFactor) * _smoothedPitch;
    _smoothedRoll = smoothingFactor * newRoll + (1 - smoothingFactor) * _smoothedRoll;
    
    _pitch = _smoothedPitch;
    _roll = _smoothedRoll;
    
    final wasHorizontal = _isHorizontal;
    _isHorizontal = _pitch.abs() <= horizontalThreshold && _roll.abs() <= horizontalThreshold;
    
    if (wasHorizontal != _isHorizontal) {
      onHorizontalChanged?.call(_isHorizontal);
    }
    
    onOrientationChanged?.call(_pitch, _roll);
  }

  /// Traite les données du gyroscope
  void _processGyroscopeEvent(GyroscopeEvent event) {
    // Le gyroscope donne la vitesse angulaire, pas l'angle absolu
  }

  /// Obtient un score de "niveau" (0 = parfait, 100 = très incliné)
  double get levelScore {
    final pitchScore = (_pitch.abs() / horizontalThreshold) * 50;
    final rollScore = (_roll.abs() / horizontalThreshold) * 50;
    return min(100, pitchScore + rollScore);
  }

  /// Obtient un message décrivant l'inclinaison
  String get orientationMessage {
    if (_isHorizontal) {
      return 'Niveau : Parfait';
    }
    
    final messages = <String>[];
    
    if (_pitch > horizontalThreshold) {
      messages.add('Incliné vers l\'avant');
    } else if (_pitch < -horizontalThreshold) {
      messages.add('Incliné vers l\'arrière');
    }
    
    if (_roll > horizontalThreshold) {
      messages.add('Incliné vers la droite');
    } else if (_roll < -horizontalThreshold) {
      messages.add('Incliné vers la gauche');
    }
    
    if (messages.isEmpty) {
      return 'Niveau : Presque parfait';
    }
    
    return 'Niveau : ${messages.join(' et ')}';
  }

  /// Dispose les ressources
  void dispose() {
    stop();
  }
}
