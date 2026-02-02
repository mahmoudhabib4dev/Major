import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/widgets/app_loader.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late Player _player;
  late VideoController _videoController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    // Set status bar to dark icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializePlayer() async {
    try {
      _player = Player();
      _videoController = VideoController(_player);

      // Listen for errors
      _player.stream.error.listen((error) {
        if (mounted) {
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        }
      });

      // Listen for when video is ready
      _player.stream.playing.listen((playing) {
        if (mounted && playing && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      });

      // Open and play video
      await _player.open(Media(widget.videoUrl));
      await _player.play();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: const SizedBox(width: 48),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        body: Center(
          child: _isLoading
              ? const AppLoader(size: 60)
              : _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'خطأ في تشغيل الفيديو',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A8A8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'رجوع',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Video(
                      controller: _videoController,
                      controls: MaterialVideoControls,
                      fill: Colors.black,
                    ),
        ),
      ),
    );
  }
}
