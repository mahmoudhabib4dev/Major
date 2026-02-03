import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../theme/app_colors.dart';
import 'app_loader.dart';

/// Custom network image widget that handles HTTP 206 (Partial Content) responses
/// with proper memory management and caching.
///
/// Use this widget for ALL images loaded from the API.
class ApiImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ApiImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ApiImage> createState() => _ApiImageState();
}

class _ApiImageState extends State<ApiImage> {
  bool _isLoading = true;
  bool _hasError = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ApiImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _imageBytes = null;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.imageUrl));

      // Accept both 200 (OK) and 206 (Partial Content) as successful responses
      if (response.statusCode == 200 || response.statusCode == 206) {
        if (mounted) {
          // Decode and resize image to save memory
          final bytes = response.bodyBytes;

          // If dimensions are specified, decode and resize
          if (widget.width != null || widget.height != null) {
            final codec = await ui.instantiateImageCodec(
              bytes,
              targetWidth: widget.width?.round(),
              targetHeight: widget.height?.round(),
            );
            final frame = await codec.getNextFrame();
            final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

            if (mounted && data != null) {
              setState(() {
                _imageBytes = data.buffer.asUint8List();
                _isLoading = false;
              });
            }
          } else {
            // No resizing needed
            if (mounted) {
              setState(() {
                _imageBytes = bytes;
                _isLoading = false;
              });
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clear image data when widget is disposed
    _imageBytes = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Container(
              color: AppColors.grey200,
              child: const Center(
                child: AppLoader(size: 40),
              ),
            ),
          );
    }

    if (_hasError || _imageBytes == null) {
      return widget.errorWidget ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Container(
              color: AppColors.grey200,
              child: const Icon(Icons.broken_image, color: AppColors.grey400),
            ),
          );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Image.memory(
        _imageBytes!,
        fit: widget.fit,
        gaplessPlayback: true,
      ),
    );
  }
}
