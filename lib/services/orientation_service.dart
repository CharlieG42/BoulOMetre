import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

/// Service pour gerer la detection de l'orientation du telephone
class OrientationService {
  static final OrientationService _instance = OrientationService._internal();
  
  factory OrientationService() => _instance;
  
  OrientationService._internal();
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Stream controller pour diffuser l'angle d'inclinaison
  final StreamController<double> _angleController = StreamController<double>.broadcast();
  Stream<double> get angleStream => _angleController.stream;
  
  // Dernier angle calcule
  double _lastAngle = 0.0;
  double get lastAngle => _lastAngle;
  
  // Seuil pour considerer le telephone comme horizontal (en degres)
  static const double horizontalThreshold = 5.0;
  
  // Etat actuel
  bool _isHorizontal = false;
  bool get isHorizontal => _isHorizontal;
  
  /// Demarre la detection de l'orientation
  void start() {
    if (_accelerometerSubscription != null) return;
    
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Calcul de l'angle d'inclinaison a partir de l'accelerometre
      // L'angle est calcule en utilisant l'arctangente de x et z
      // Cela donne l'angle d'inclinaison par rapport a l'horizontale
      final angle = _calculateInclinationAngle(event.x, event.y, event.z);
      _lastAngle = angle;
      _isHorizontal = angle.abs() < horizontalThreshold;
      _angleController.add(angle);
    });
  }
  
  /// Arrete la detection de l'orientation
  void stop() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }
  
  /// Dispose le service
  void dispose() {
    stop();
    _angleController.close();
  }
  
  /// Calcule l'angle d'inclinaison a partir des valeurs de l'accelerometre
  /// 
  /// L'accelerometre donne les valeurs en m/s2 pour chaque axe
  /// - x: gauche/droite
  /// - y: avant/arriere
  /// - z: haut/bas
  /// 
  /// L'angle est calcule en utilisant atan2(x, z) pour obtenir l'inclinaison
  /// laterale (roll) et atan2(y, z) pour l'inclinaison avant/arriere (pitch)
  double _calculateInclinationAngle(double x, double y, double z) {
    // Calcul de l'angle de roll (inclinaison laterale)
    final roll = math.atan2(x, z) * (180 / math.pi);
    
    // Calcul de l'angle de pitch (inclinaison avant/arriere)
    final pitch = math.atan2(y, z) * (180 / math.pi);
    
    // On utilise principalement le roll pour determiner si le telephone est horizontal
    // mais on peut aussi prendre en compte le pitch
    // Ici, on retourne la moyenne des deux pour une meilleure precision
    return (roll.abs() + pitch.abs()) / 2;
  }
  
  /// Verifie si le telephone est actuellement horizontal
  bool checkIsHorizontal() {
    return _lastAngle.abs() < horizontalThreshold;
  }
  
  /// Obtient l'angle actuel d'inclinaison
  double getCurrentAngle() {
    return _lastAngle;
  }
}
