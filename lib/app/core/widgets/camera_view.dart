import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isCapturing = false;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showError('لم يتم العثور على كاميرا');
        return;
      }

      // Default to back camera
      _selectedCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

      await _setupCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      _showError('فشل في تهيئة الكاميرا');
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      _showError('فشل في تهيئة الكاميرا');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Get.back();
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.auto;
    }

    try {
      await _controller!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      // Flash not supported
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_auto;
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();

      // Save to temp directory with unique name
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${tempDir.path}/$fileName';

      // Copy file to temp directory
      final File savedFile = await File(photo.path).copy(filePath);

      if (mounted) {
        Get.back(result: savedFile);
      }
    } catch (e) {
      _showError('فشل في التقاط الصورة');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_isInitialized && _controller != null)
              Center(
                child: CameraPreview(_controller!),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),

            // Top controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  _buildControlButton(
                    icon: Icons.close,
                    onTap: () => Get.back(),
                  ),
                  // Flash button
                  _buildControlButton(
                    icon: _getFlashIcon(),
                    onTap: _toggleFlash,
                  ),
                ],
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Switch camera button
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    onTap: _cameras.length > 1 ? _switchCamera : null,
                    size: 50,
                  ),
                  // Capture button
                  GestureDetector(
                    onTap: _isCapturing ? null : _capturePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCapturing ? AppColors.grey400 : Colors.white,
                          ),
                          child: _isCapturing
                              ? const Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  // Empty space for balance
                  const SizedBox(width: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onTap,
    double size = 44,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : Colors.grey,
          size: size * 0.5,
        ),
      ),
    );
  }
}
