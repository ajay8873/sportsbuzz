import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../common/live_indicator.dart';
import 'video_embed_stub.dart' if (dart.library.html) 'video_embed_web.dart';

class VideoPlayerEmbed extends StatelessWidget {
  final String? streamUrl;
  final bool isLive;

  const VideoPlayerEmbed({
    super.key,
    this.streamUrl,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final hasStream = streamUrl != null && streamUrl!.trim().isNotEmpty;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Slate 900
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Interactive Live Video Player / Stream Embed
            if (hasStream)
              buildPlatformVideoPlayer(
                streamUrl: streamUrl!.trim(),
                isLive: isLive,
              )
            else
              Container(
                color: const Color(0xFF1E293B),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.videoOff,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 44,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No Live Video Broadcast Active',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scoreboard will continue updating live via real-time WebSocket sync.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            // Top Overlay Bar (Live badge & Stream status)
            if (!hasStream)
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isLive)
                        const LiveIndicator(label: 'LIVE BROADCAST')
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OFF AIR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.signal, size: 12, color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                              '1080p HD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
