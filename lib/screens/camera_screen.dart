import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:boul_o_metre/services/camera_service.dart';
import 'package:boul_o_metre/services/image_processor.dart';
import 'package:boul_o_metre/widgets/camera_overlay.dart';
import 'package:boul_o_metre/models/ball.dart';
import 'package:boul_o_metre/app/routes.dart';
import 'package:boul_o_metre/utils/constants.dart';

/// Écran de la caméra pour capturer et traiter les images.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  List<Ball> _balls = [];
  bool _isProcessing = false;
  bool _isCameraReady = false;
  String? _errorMessage;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gérer les changements de cycle de vie de l'application
    if (state == AppLifecycleState.resumed) {
      // Réinitialiser la caméra quand l'application revient au premier plan
      if (!_isCameraReady) {
        _initializeCamera();
      }
    } else if (state == AppLifecycleState.paused) {
      // Libérer la caméra quand l'application passe en arrière-plan
      _cameraService.dispose();
      setState(() {
        _isCameraReady = false;
      });
    }
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
          _errorMessage = e.toString().contains('permission')
              ? AppConstants.cameraPermissionDenied
              : AppConstants.cameraInitializationError;
        });
      }
    }
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing || !_isCameraReady) return;
    
    setState(() {
      _isProcessing = true;
      _balls = [];
    });

    try {
      final picture = await _cameraService.takePicture();
      final imageBytes = await picture.readAsBytes();
      final image = img.decodeImage(imageBytes)!;

      // Traiter l'image en arrière-plan
      final balls = ImageProcessor.detectBallsAndPiglet(image);
      
      if (mounted) {
        setState(() => _balls = balls);
        
        // Attendre un peu pour que l'utilisateur voie les détections
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          // Vérifier qu'au moins un cochonnet et une boule ont été détectés
          final hasPiglet = balls.any((b) => b.isPiglet);
          final hasBalls = balls.any((b) => !b.isPiglet);
          
          if (hasPiglet && hasBalls) {
            Navigator.pushNamed(
              context,
              Routes.results,
              arguments: balls,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  hasPiglet
                    ? AppConstants.noBallsDetected
                    : AppConstants.noPigletDetected,
                ),
                backgroundColor: AppConstants.errorColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.pictureError}: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
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
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur flash: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraService.switchCamera();
      if (mounted) {
        setState(() {
          _balls = [];
          _isCameraReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur caméra: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _toggleInstructions() {
    setState(() {
      _showInstructions = !_showInstructions;
    });
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppConstants.errorColor,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: AppConstants.largePadding),
              const CircularProgressIndicator(),
              const SizedBox(height: AppConstants.largePadding),
              const Text(
                'Initialisation de la caméra...',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Veuillez autoriser l\'accès à la caméra',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
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
            icon: const Icon(Icons.help_outline),
            onPressed: _toggleInstructions,
            tooltip: 'Afficher/Masquer les instructions',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Prévisualisation de la caméra
          CameraPreview(_cameraService.controller),

          // Overlay de détection
          CameraOverlay(balls: _balls),

          // Instructions
          if (_showInstructions)
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
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pointez la caméra vers les boules et le cochonnet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppConstants.tinyPadding),
                      Text(
                        'Assurez-vous que le cochonnet est visible',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Compteur de détections
          if (_balls.isNotEmpty)
            Positioned(
              top: AppConstants.largePadding * 2 + 80,
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
                    '${_balls.where((b) => !b.isPiglet).length} boules détectées'
                    '${_balls.any((b) => b.isPiglet) ? ' + 1 cochonnet' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Bouton de capture
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
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.camera, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
