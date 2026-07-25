import 'package:camera/camera.dart';

class CameraService {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isInitialized = false;
  bool _isDisposed = false;

  Future<void> initialize() async {
    if (_isDisposed) {
      throw Exception('CameraService has been disposed');
    }
    if (_isInitialized) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras found');
      }
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (!_isDisposed) {
      await _controller.dispose();
      _isDisposed = true;
      _isInitialized = false;
    }
  }

  Future<XFile> takePicture() async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    if (_isDisposed) throw Exception('CameraService has been disposed');
    try {
      final file = await _controller.takePicture();
      return file;
    } catch (e) {
      throw Exception('Failed to take picture: $e');
    }
  }

  CameraController get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isDisposed => _isDisposed;

  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    await _controller.setFlashMode(mode);
  }

  Future<void> switchCamera() async {
    if (_isDisposed) throw Exception('CameraService has been disposed');
    await dispose();
    await initialize();
  }
}
