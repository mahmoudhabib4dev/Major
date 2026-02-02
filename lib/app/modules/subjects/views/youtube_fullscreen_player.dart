import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Video;

import '../../../core/widgets/app_loader.dart';

class YoutubeFullscreenPlayer extends StatefulWidget {
  final String videoId;
  final String title;

  const YoutubeFullscreenPlayer({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<YoutubeFullscreenPlayer> createState() => _YoutubeFullscreenPlayerState();
}

class _YoutubeFullscreenPlayerState extends State<YoutubeFullscreenPlayer> {
  late Player _player;
  late VideoController _videoController;
  final YoutubeExplode _youtubeExplode = YoutubeExplode();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Force landscape for fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide system UI for immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _player = Player();
      _videoController = VideoController(_player);

      // Get direct YouTube URL
      final directUrl = await _getYouTubeDirectUrl(widget.videoId);
      if (directUrl == null) {
        setState(() {
          _errorMessage = 'فشل في الحصول على رابط الفيديو';
          _isLoading = false;
        });
        return;
      }

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
      await _player.open(Media(directUrl));
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

  Future<String?> _getYouTubeDirectUrl(String videoId) async {
    try {
      final manifest = await _youtubeExplode.videos.streamsClient.getManifest(videoId);

      // Try to get muxed stream (video + audio) first
      final muxedStreams = manifest.muxed.sortByVideoQuality();
      if (muxedStreams.isNotEmpty) {
        // Get highest quality muxed stream
        return muxedStreams.last.url.toString();
      }

      // Fallback to video-only stream
      final videoStreams = manifest.video.sortByVideoQuality();
      if (videoStreams.isNotEmpty) {
        return videoStreams.last.url.toString();
      }

      return null;
    } catch (e) {
      debugPrint('Error getting YouTube URL: $e');
      return null;
    }
  }

  @override
  void dispose() {
    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _player.dispose();
    _youtubeExplode.close();
    super.dispose();
  }

  void _exitFullscreen() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player - fill entire screen
          Center(
            child: _isLoading
                ? const AppLoader(size: 60)
                : _errorMessage != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Video(
                        controller: _videoController,
                        controls: MaterialVideoControls,
                        fill: Colors.black,
                      ),
          ),
          // Exit fullscreen button (top right)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: _exitFullscreen,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fullscreen_exit,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          // Title (top left)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
