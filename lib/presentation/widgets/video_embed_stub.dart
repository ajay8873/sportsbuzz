import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

Widget buildPlatformVideoPlayer({
  required String streamUrl,
  required bool isLive,
}) {
  return _MobileLiveStreamPlayerCard(streamUrl: streamUrl, isLive: isLive);
}

class _MobileLiveStreamPlayerCard extends StatefulWidget {
  final String streamUrl;
  final bool isLive;

  const _MobileLiveStreamPlayerCard({
    required this.streamUrl,
    required this.isLive,
  });

  @override
  State<_MobileLiveStreamPlayerCard> createState() =>
      _MobileLiveStreamPlayerCardState();
}

class _MobileLiveStreamPlayerCardState
    extends State<_MobileLiveStreamPlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _launchStream({bool external = false}) async {
    final rawUrl = widget.streamUrl.trim();
    if (rawUrl.isEmpty) return;

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;

    try {
      if (external) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
        );
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Error launching stream URL: $e');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVdoNinja = widget.streamUrl.toLowerCase().contains('vdo.ninja');
    final isYouTube = widget.streamUrl.toLowerCase().contains('youtu');
    final isTwitch = widget.streamUrl.toLowerCase().contains('twitch');

    String providerLabel = 'Live Stream';
    if (isVdoNinja) providerLabel = 'VDO.Ninja Live WebRTC';
    if (isYouTube) providerLabel = 'YouTube Live Broadcast';
    if (isTwitch) providerLabel = 'Twitch Live Stream';

    return InkWell(
      onTap: () => _launchStream(external: false),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient animated background glow
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Center(
                  child: Container(
                    width: 140 + (_animController.value * 30),
                    height: 140 + (_animController.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.liveRed.withValues(
                        alpha: 0.05 + (_animController.value * 0.08),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing Play Button
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.liveRed.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.play,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tap to Watch Action
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.tv,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to Watch $providerLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Opens live interactive video with audio & full controls',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Top Status Bar
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.liveRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.video, size: 11, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'LIVE STREAM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.externalLink,
                        size: 16, color: Colors.white70),
                    tooltip: 'Open in External App',
                    onPressed: () => _launchStream(external: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
