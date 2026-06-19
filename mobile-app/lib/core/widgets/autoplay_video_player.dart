import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';
import 'glassy_container.dart';

class AutoplayVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const AutoplayVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<AutoplayVideoPlayer> createState() => _AutoplayVideoPlayerState();
}

class _AutoplayVideoPlayerState extends State<AutoplayVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.setVolume(0.0); // start muted as requested & standard for autoplay
          _controller.play();
        }
      }).catchError((error) {
        debugPrint("Video Player Error: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _controller.setVolume(_isMuted ? 0.0 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleMute,
              child: GlassyContainer(
                padding: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(30),
                opacity: 0.25,
                color: Colors.black,
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
