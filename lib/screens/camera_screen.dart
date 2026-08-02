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

      final balls = ImageProcessor.detectBallsAndPiglet(image);
      if (mounted) {
        setState(() => _balls = balls);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Reset balls overlay before navigating
          setState(() => _balls = []);
          Navigator.pushNamed(
            context,
            Routes.results,
            arguments: balls,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _balls = []);
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
        setState(() => _balls = []);
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
          CameraPreview(_cameraService.controller),
          CameraOverlay(balls: _balls),
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
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Text(
                  'Pointez la camera vers les boules et le cochonnet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
