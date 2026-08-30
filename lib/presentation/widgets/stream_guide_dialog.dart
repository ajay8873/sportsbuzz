import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class StreamGuideDialog extends StatelessWidget {
  const StreamGuideDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StreamGuideDialog(),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('$label copied to clipboard!')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.video,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Video Streaming Guide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Step-by-step methods to get a live stream link for your match',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Method 1: VDO.Ninja (Zero downloads)
                    _MethodCard(
                      badge: 'EASIEST • NO APPS REQUIRED',
                      badgeColor: Colors.blue,
                      title: 'Method 1: VDO.Ninja (Instant Mobile Browser)',
                      description:
                          'Broadcast directly from your phone camera using Google Chrome without installing any app.',
                      steps: const [
                        '1. Open Chrome on the camera phone and go to: vdo.ninja',
                        '2. Tap "Add your Camera to OBS / Live".',
                        '3. Enter your fest room name (e.g. "plexus_ground1") and allow camera access.',
                        '4. Copy the generated "View Link" (e.g. https://vdo.ninja/?view=plexus_ground1).',
                        '5. Paste that View Link into the Stream URL input box in SportsBuzz!',
                      ],
                      quickCopyText: 'https://vdo.ninja/?view=YOUR_FEST_NAME',
                      quickCopyLabel: 'VDO.Ninja Template Link',
                      onCopy: () => _copyToClipboard(
                        context,
                        'https://vdo.ninja/?view=plexus_match1',
                        'VDO.Ninja sample link',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Method 2: Livepeer Studio (White-label & 1,000+ Viewers)
                    _MethodCard(
                      badge: 'RECOMMENDED FOR BIG CROWDS • NO ADS',
                      badgeColor: Colors.green,
                      title: 'Method 2: Livepeer Studio + Larix (HD & Ad-Free)',
                      description:
                          'Global video CDN designed for campus tournaments. Handles 1,000+ simultaneous viewers with 0 ads.',
                      steps: const [
                        '1. On your PC or phone, open livepeer.studio and create a free account.',
                        '2. Click "Create Stream", name your match (e.g. "Final Match"), and click Create.',
                        '3. Copy the "Playback URL" (ends in .m3u8).',
                        '4. Paste that .m3u8 Playback URL into the Stream URL box in SportsBuzz!',
                        '5. On the camera phone, open the free "Larix Broadcaster" app (Play Store), enter the Livepeer RTMP URL & Key, and tap the red button to stream!',
                      ],
                      quickCopyText: 'https://livepeercdn.studio/hls/YOUR_STREAM_ID/index.m3u8',
                      quickCopyLabel: 'Livepeer HLS (.m3u8) format',
                      onCopy: () => _copyToClipboard(
                        context,
                        'https://livepeercdn.studio',
                        'Livepeer website URL',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Method 3: YouTube Live (RTMP Key via Larix)
                    _MethodCard(
                      badge: 'NO 50 SUBSCRIBER LIMIT (VIA RTMP)',
                      badgeColor: Colors.red,
                      title: 'Method 3: YouTube Live (Bypass Sub Limit)',
                      description:
                          'Use your standard YouTube channel without needing 50 subscribers on mobile.',
                      steps: const [
                        '1. Open studio.youtube.com in your browser (use "Desktop site" on phone).',
                        '2. Click "Create" ➔ "Go Live" and copy your public YouTube watch link (e.g. https://youtube.com/watch?v=...).',
                        '3. Paste the YouTube link into the Stream URL box in SportsBuzz.',
                        '4. Copy the YouTube RTMP Stream Key into Larix Broadcaster or Prism Live on your camera phone and start streaming!',
                      ],
                      quickCopyText: 'https://youtube.com/watch?v=VIDEO_ID',
                      quickCopyLabel: 'YouTube URL format',
                      onCopy: () => _copyToClipboard(
                        context,
                        'https://studio.youtube.com',
                        'YouTube Studio URL',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Method 4: Twitch
                    _MethodCard(
                      badge: 'FREE & SIMPLE',
                      badgeColor: Colors.purple,
                      title: 'Method 4: Twitch Live',
                      description:
                          'Stream directly from the official Twitch mobile app with 1 tap.',
                      steps: const [
                        '1. Download the Twitch app on your camera phone and create a channel (e.g. "plexus_sports").',
                        '2. Tap "Go Live" in the Twitch app.',
                        '3. Paste your Twitch channel URL: https://twitch.tv/YOUR_CHANNEL_NAME into SportsBuzz!',
                      ],
                      quickCopyText: 'https://twitch.tv/YOUR_CHANNEL_NAME',
                      quickCopyLabel: 'Twitch URL format',
                      onCopy: () => _copyToClipboard(
                        context,
                        'https://twitch.tv/',
                        'Twitch base link',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it!'),
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

class _MethodCard extends StatelessWidget {
  final String badge;
  final Color badgeColor;
  final String title;
  final String description;
  final List<String> steps;
  final String quickCopyText;
  final String quickCopyLabel;
  final VoidCallback onCopy;

  const _MethodCard({
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.description,
    required this.steps,
    required this.quickCopyText,
    required this.quickCopyLabel,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Steps list
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Quick action row
          Row(
            children: [
              Expanded(
                child: Text(
                  quickCopyText,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(LucideIcons.copy, size: 13),
                label: Text(
                  'Copy Link',
                  style: const TextStyle(fontSize: 11),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
