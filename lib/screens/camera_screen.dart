import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/services/camera_service.dart';
import 'package:boul_o_metre/services/image_processor.dart';
import 'package:boul_o_metre/widgets/camera_overlay.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/app/routes.dart';
import 'package:boul_o_metre/utils/constants.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  List<Ball> _balls = [];
  bool _isProcessing = false;
  bool _isCameraReady = false;
  String? _errorMessage;
  bool _showMeasurementGuides = false;
  bool _isSelectingBalls = false;
  Offset? _manualPigletPosition;
  Uint8List? _capturedImageBytes;
  bool _isHorizontal = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraReady = false;
          _errorMessage = 'Erreur camera: ' + e.toString();
        });
      }
    }
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing || !_isCameraReady) return;
    setState(() => _isProcessing = true);

    try {
      final picture = await _cameraService.takePicture();
      final imageBytes = await picture.readAsBytes();
      final image = img.decodeImage(imageBytes)!;

      // Store captured image for display
      _capturedImageBytes = imageBytes;

      // Get the piglet at center (will be adjusted manually if needed)
      final balls = ImageProcessor.detectBallsAndPiglet(image);
      
      // If user has manually adjusted the piglet position, update it
      final updatedBalls = balls.map((ball) {
        if (ball.isPiglet && _manualPigletPosition != null) {
          return ball.copyWith(
            x: _manualPigletPosition!.dx,
            y: _manualPigletPosition!.dy,
          );
        }
        return ball;
      }).toList();

      if (mounted) {
        setState(() {
          _balls = updatedBalls;
          _showMeasurementGuides = true; // Show guides after capture
          _manualPigletPosition = null; // Reset for next capture
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ' + e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _confirmMeasurement() {
    if (_balls.isEmpty) return;
    
    // Passer en mode sélection des boules
    setState(() {
      _showMeasurementGuides = false;
      _isSelectingBalls = true;
    });
  }

  void _addBallAtPosition(Offset position) {
    if (!_isSelectingBalls) return;
    
    // Créer une nouvelle boule à la position cliquée
    final newBall = Ball(
      id: 'ball_${_balls.length + 1}',
      x: position.dx,
      y: position.dy,
      radius: 20.0,  // Rayon par défaut pour les boules
      isPiglet: false,
    );
    
    setState(() {
      _balls.add(newBall);
    });
  }

  void _finishBallSelection() {
    if (_balls.isEmpty) return;
    
    // Calculer les distances par rapport au cochonnet
    final piglet = _balls.firstWhere((ball) => ball.isPiglet);
    final updatedBalls = _balls.map((ball) {
      if (!ball.isPiglet) {
        final distance = ImageProcessor.calculateDistance(
          ball.x, ball.y, piglet.x, piglet.y
        );
        return ball.copyWith(distanceToPiglet: distance);
      }
      return ball;
    }).toList();
    
    // Trier les boules par distance (du plus proche au plus éloigné)
    final sortedBalls = [...updatedBalls.where((ball) => !ball.isPiglet)]
      ..sort((a, b) => a.distanceToPiglet.compareTo(b.distanceToPiglet));
    
    // Attribuer les rangs (1 = plus proche)
    final rankedBalls = updatedBalls.map((ball) {
      if (ball.isPiglet) return ball;
      final rank = sortedBalls.indexOf(ball) + 1;
      return ball.copyWith(id: 'Boule $rank');
    }).toList();
    
    // Naviguer vers les résultats
    setState(() {
      _isSelectingBalls = false;
      _balls = rankedBalls;
    });
    
    Navigator.pushNamed(
      context,
      Routes.results,
      arguments: rankedBalls,
    );
  }

  void _cancelMeasurement() {
    setState(() {
      _showMeasurementGuides = false;
      _isSelectingBalls = false;
      _balls = [];
      _manualPigletPosition = null;
      _capturedImageBytes = null;
    });
  }

  void _handlePigletPositionChanged(Offset position) {
    setState(() {
      _manualPigletPosition = position;
    });
  }

  Future<void> _toggleFlash() async {
    try {
      final currentMode = _cameraService.controller.value.flashMode;
      final newMode = currentMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      await _cameraService.setFlashMode(newMode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur flash: ' + e.toString())),
      );
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraService.switchCamera();
      if (mounted) {
        setState(() {
          _balls = [];
          _showMeasurementGuides = false;
          _manualPigletPosition = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur camera: ' + e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Initialisation de la camera...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesure des distances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _switchCamera,
            tooltip: 'Changer de camera',
          ),
          IconButton(
            icon: Icon(
              _cameraService.controller.value.flashMode == FlashMode.torch
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed: _toggleFlash,
            tooltip: 'Activer/Desactiver le flash',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalite a venir')),
              );
            },
            tooltip: 'Choisir une image',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Show captured image when in measurement mode, otherwise show camera preview
          if (_showMeasurementGuides && _capturedImageBytes != null)
            Positioned.fill(
              child: Image.memory(
                _capturedImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          if (!_showMeasurementGuides)
            CameraPreview(_cameraService.controller),
          CameraOverlay(
            balls: _balls,
            showMeasurementGuides: _showMeasurementGuides,
            isSelectingBalls: _isSelectingBalls,
            onPigletPositionChanged: _showMeasurementGuides ? _handlePigletPositionChanged : null,
            onBallAdded: _isSelectingBalls ? _addBallAtPosition : null,
            onHorizontalChanged: (isHorizontal) {
              setState(() {
                _isHorizontal = isHorizontal;
              });
            },
            horizontalThreshold: 0.1,
          ),
          // Instruction text at top
          Positioned(
            top: AppConstants.largePadding,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Text(
                  _isSelectingBalls
                      ? 'Cliquez sur chaque boule (${_balls.where((b) => !b.isPiglet).length})'
                      : _showMeasurementGuides
                          ? 'Ajustez le pointeur sur le cochonnet et validez'
                          : 'Pointez la camera vers les boules et le cochonnet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Horizontal guidance message
          if (!_isHorizontal && !_showMeasurementGuides)
            Positioned(
              bottom: AppConstants.largePadding * 2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.smallPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                      SizedBox(width: AppConstants.smallPadding),
                      Text(
                        'Inclinez le téléphone à l\'horizontal',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Camera button at bottom
          Positioned(
            bottom: AppConstants.largePadding,
            left: 0,
            right: 0,
            child: Center(
              child: _showMeasurementGuides
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _cancelMeasurement,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Annuler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: _confirmMeasurement,
                          icon: const Icon(Icons.check),
                          label: const Text('Valider'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : _isSelectingBalls
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isSelectingBalls = false;
                                  _balls = _balls.where((ball) => ball.isPiglet).toList();
                                });
                              },
                              icon: const Icon(Icons.cancel),
                              label: const Text('Annuler'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: _balls.length > 1 ? _finishBallSelection : null,
                              icon: const Icon(Icons.check),
                              label: Text('Terminer (${_balls.where((b) => !b.isPiglet).length})'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _balls.where((b) => !b.isPiglet).length > 0
                                    ? AppConstants.primaryColor
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : FloatingActionButton(
                          onPressed: _isProcessing || !_isCameraReady || !_isHorizontal
                              ? null
                              : _captureAndProcess,
                          backgroundColor: _isHorizontal
                              ? AppConstants.primaryColor
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          child: _isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Icon(Icons.camera, size: 30),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
