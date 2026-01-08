import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../theme/app_colors.dart';

/// Custom network image widget that handles HTTP 206 (Partial Content) responses
/// which are commonly returned by media servers for range requests.
class NetworkAvatar extends StatefulWidget {
  final String imageUrl;
  final double size;
  final String? fallbackAsset;
  final BoxFit fit;

  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    this.fallbackAsset,
    this.fit = BoxFit.cover,
  });

  @override
  State<NetworkAvatar> createState() => _NetworkAvatarState();
}

class _NetworkAvatarState extends State<NetworkAvatar> {
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(NetworkAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageData = null;
    });

    try {
      final response = await http.get(Uri.parse(widget.imageUrl));

      // Accept both 200 (OK) and 206 (Partial Content) as successful responses
      if (response.statusCode == 200 || response.statusCode == 206) {
        if (mounted) {
          setState(() {
            _imageData = response.bodyBytes;
            _isLoading = false;
          });
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Container(
          color: AppColors.grey200,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    if (_hasError || _imageData == null) {
      // Show fallback asset image
      if (widget.fallbackAsset != null) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Image.asset(
            widget.fallbackAsset!,
            fit: widget.fit,
          ),
        );
      }
      // Show placeholder
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Container(
          color: AppColors.grey200,
          child: const Icon(Icons.person, color: AppColors.grey400),
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Image.memory(
        _imageData!,
        fit: widget.fit,
      ),
    );
  }
}
