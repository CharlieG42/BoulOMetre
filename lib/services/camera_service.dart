import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service pour gérer la caméra de l'appareil.
class CameraService {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _hasPermission = false;

  /// Initialise la caméra.
  /// Jette une exception si la caméra n'est pas disponible ou si les permissions sont refusées.
  Future<void> initialize() async {
    if (_isDisposed) {
      throw Exception('CameraService has been disposed');
    }
    if (_isInitialized) return;

    try {
      // Vérifier les permissions
      await _checkAndRequestPermission();
      if (!_hasPermission) {
        throw Exception('Camera permission denied');
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      // Préférer la caméra arrière
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Configurer la caméra pour une meilleure qualité
      await _controller.initialize();
      
      // Attendre que la caméra soit prête
      await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      // Configurer la focus et l'exposition
      await _controller.setFocusMode(FocusMode.locked);
      await _controller.setExposureMode(ExposureMode.locked);
      
      _initializeControllerFuture = Future.value();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Vérifie et demande les permissions caméra.
  Future<void> _checkAndRequestPermission() async {
    final status = await Permission.camera.request();
    _hasPermission = status.isGranted;
    
    if (!status.isGranted) {
      // Essayer d'ouvrir les paramètres si l'utilisateur a précédemment refusé
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        // Attendre un peu pour que l'utilisateur revienne
        await Future.delayed(const Duration(seconds: 1));
        final newStatus = await Permission.camera.status;
        _hasPermission = newStatus.isGranted;
      }
    }
  }

  /// Vérifie si les permissions caméra sont accordées.
  bool get hasPermission => _hasPermission;

  /// Libère les ressources de la caméra.
  void dispose() {
    if (!_isDisposed) {
      _controller.dispose();
      _isDisposed = true;
      _isInitialized = false;
    }
  }

  /// Prend une photo.
  /// Jette une exception si la caméra n'est pas initialisée.
  Future<XFile> takePicture() async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    if (_isDisposed) throw Exception('CameraService has been disposed');
    
    try {
      // Attendre un peu pour que la focus se stabilise
      await Future.delayed(const Duration(milliseconds: 300));
      
      final file = await _controller.takePicture();
      return file;
    } catch (e) {
      throw Exception('Failed to take picture: $e');
    }
  }

  /// Retourne le contrôleur de la caméra.
  CameraController get controller => _controller;

  /// Indique si la caméra est initialisée.
  bool get isInitialized => _isInitialized;

  /// Indique si la caméra est libérée.
  bool get isDisposed => _isDisposed;

  /// Active ou désactive le flash.
  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    await _controller.setFlashMode(mode);
  }

  /// Change de caméra (avant/arrière).
  Future<void> switchCamera() async {
    if (_isDisposed) throw Exception('CameraService has been disposed');
    
    await dispose();
    await initialize();
  }

  /// Met à jour la focus de la caméra.
  Future<void> setFocusMode(FocusMode mode) async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    await _controller.setFocusMode(mode);
  }

  /// Met à jour le mode d'exposition.
  Future<void> setExposureMode(ExposureMode mode) async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    await _controller.setExposureMode(mode);
  }

  /// Verrouille l'orientation de capture.
  Future<void> lockCaptureOrientation(DeviceOrientation orientation) async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    await _controller.lockCaptureOrientation(orientation);
  }
}
