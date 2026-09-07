import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../common/live_indicator.dart';
import '../widgets/video_embed_stub.dart'
    if (dart.library.html) '../widgets/video_embed_web.dart';

/// Fullscreen Landscape Live Video Streaming Screen
/// Unlocks landscape orientation and enters immersive fullscreen mode for video watching,
/// and securely restores portrait orientation upon exit.
class FullscreenVideoScreen extends StatefulWidget {
  final String streamUrl;
  final bool isLive;

  const FullscreenVideoScreen({
    super.key,
    required this.streamUrl,
    required this.isLive,
  });

  @override
  State<FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<FullscreenVideoScreen> {
  @override
  void initState() {
    super.initState();
    // Allow and rotate to landscape for streaming video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore strict portrait orientation and standard system UI upon exiting video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The Video Player
          buildPlatformVideoPlayer(
            streamUrl: widget.streamUrl,
            isLive: widget.isLive,
          ),

          // Top Floating Overlay Bar
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back / Exit Fullscreen Button
                Material(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft,
                        color: Colors.white, size: 20),
                    tooltip: 'Exit Fullscreen',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Live Indicator / Landscape Badge
                Row(
                  children: [
                    if (widget.isLive)
                      const LiveIndicator(label: 'LIVE STREAM'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.maximize,
                              size: 12, color: Colors.white70),
                          SizedBox(width: 4),
                          Text(
                            'LANDSCAPE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
