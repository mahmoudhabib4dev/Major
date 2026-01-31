import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  late YoutubePlayerController _controller;

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

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        hideControls: false,
        controlsVisibleAtStart: true,
        isLive: true,
      ),
    );
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

    _controller.dispose();
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
          // YouTube Player - fill entire screen
          Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFFFB2B3A),
              progressColors: const ProgressBarColors(
                playedColor: Color(0xFFFB2B3A),
                handleColor: Color(0xFFFB2B3A),
              ),
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
