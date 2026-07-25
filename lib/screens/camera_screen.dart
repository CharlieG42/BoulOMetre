import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/services/camera_service.dart';
import 'package:boul_o_metre/services/image_processor.dart';
import 'package:boul_o_metre/services/orientation_service.dart';
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
  final OrientationService _orientationService = OrientationService();
  
  List<Ball> _balls = [];
  bool _isProcessing = false;
  bool _isCameraReady = false;
  String? _errorMessage;
  
  // Position du centre pour le cochonnet
  double _centerX = 0.5;
  double _centerY = 0.5;
  
  // État de l'orientation
  bool _isLevel = false;
  double _pitch = 0.0;
  double _roll = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeOrientation();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _orientationService.dispose();
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
          _errorMessage = 'Erreur caméra: $e';
        });
      }
    }
  }

  Future<void> _initializeOrientation() async {
    _orientationService.onHorizontalChanged = (isHorizontal) {
      if (mounted) {
        setState(() {
          _isLevel = isHorizontal;
        });
      }
    };
    
    _orientationService.onOrientationChanged = (pitch, roll) {
      if (mounted) {
        setState(() {
          _pitch = pitch;
          _roll = roll;
        });
      }
    };
    
    _orientationService.start();
  }

  /// Réinitialise la position du centre
  void _resetCenterPosition() {
    setState(() {
      _centerX = 0.5;
      _centerY = 0.5;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Position du cochonnet réinitialisée au centre'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing || !_isCameraReady) return;
    
    if (!_isLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez tenir le téléphone à l\'horizontale'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() => _isProcessing = true);

    try {
      final picture = await _cameraService.takePicture();
      final imageBytes = await picture.readAsBytes();
      final image = img.decodeImage(imageBytes)!;

      final centerX = image.width * _centerX;
      final centerY = image.height * _centerY;

      final balls = ImageProcessor.detectBallsAndPiglet(
        image,
        centerX: centerX,
        centerY: centerY,
      );
      
      if (mounted) {
        setState(() => _balls = balls);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushNamed(
            context,
            Routes.results,
            arguments: balls,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _toggleFlash() async {
    try {
      final currentMode = _cameraService.controller.value.flashMode;
      final newMode = currentMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      await _cameraService.setFlashMode(newMode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur flash: $e')),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraService.switchCamera();
      if (mounted) {
        setState(() => _balls = []);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur caméra: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Caméra'),
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
              const Text('Initialisation de la caméra...'),
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
            tooltip: 'Changer de caméra',
          ),
          IconButton(
            icon: Icon(
              _cameraService.controller.value.flashMode == FlashMode.torch
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed: _toggleFlash,
            tooltip: 'Activer/Désactiver le flash',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
            tooltip: 'Choisir une image',
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraService.controller),
          
          CameraOverlay(
            balls: _balls,
            centerX: _centerX,
            centerY: _centerY,
            isLevel: _isLevel,
            pitch: _pitch,
            roll: _roll,
          ),
          
          Positioned(
            bottom: AppConstants.largePadding,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _captureAndProcess,
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera, size: 30),
              ),
            ),
          ),
          
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
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Positionnez le cochonnet au centre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _orientationService.orientationMessage,
                      style: TextStyle(
                        color: _isLevel ? Colors.green : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: AppConstants.largePadding + 80,
            right: AppConstants.defaultPadding,
            child: FloatingActionButton(
              onPressed: _resetCenterPosition,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              foregroundColor: AppConstants.primaryColor,
              heroTag: 'resetCenter',
              child: const Icon(Icons.center_focus_strong, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
