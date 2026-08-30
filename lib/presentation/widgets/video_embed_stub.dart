import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../core/constants/app_colors.dart';

Widget buildPlatformVideoPlayer({
  required String streamUrl,
  required bool isLive,
}) {
  return _EmbeddedMobileLivePlayer(streamUrl: streamUrl, isLive: isLive);
}

class _EmbeddedMobileLivePlayer extends StatefulWidget {
  final String streamUrl;
  final bool isLive;

  const _EmbeddedMobileLivePlayer({
    required this.streamUrl,
    required this.isLive,
  });

  @override
  State<_EmbeddedMobileLivePlayer> createState() =>
      _EmbeddedMobileLivePlayerState();
}

class _EmbeddedMobileLivePlayerState extends State<_EmbeddedMobileLivePlayer> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant _EmbeddedMobileLivePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _initPlayer();
    }
  }

  String _getEmbedUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    // VDO.Ninja (transform to clean autoplay WebRTC view)
    if (trimmed.contains('vdo.ninja')) {
      if (trimmed.contains('push=')) {
        final pushId = Uri.parse(trimmed).queryParameters['push'];
        if (pushId != null) {
          return 'https://vdo.ninja/?view=$pushId&autoplay=1&cleanoutput=1&transparent=1&scale=100';
        }
      }
      if (!trimmed.contains('cleanoutput')) {
        final separator = trimmed.contains('?') ? '&' : '?';
        return '$trimmed${separator}autoplay=1&cleanoutput=1&transparent=1&scale=100';
      }
      return trimmed;
    }

    // YouTube Live / Video
    if (trimmed.contains('youtube.com') || trimmed.contains('youtu.be')) {
      String? videoId;
      if (trimmed.contains('youtu.be/')) {
        videoId = trimmed.split('youtu.be/').last.split('?').first;
      } else if (trimmed.contains('watch?v=')) {
        videoId = Uri.parse(trimmed).queryParameters['v'];
      } else if (trimmed.contains('/live/')) {
        videoId = trimmed.split('/live/').last.split('?').first;
      } else if (trimmed.contains('/embed/')) {
        videoId = trimmed.split('/embed/').last.split('?').first;
      }
      if (videoId != null && videoId.isNotEmpty) {
        return 'https://www.youtube-nocookie.com/embed/$videoId?autoplay=1&mute=0&playsinline=1&controls=1';
      }
    }

    // Twitch Live
    if (trimmed.contains('twitch.tv/')) {
      final channel = trimmed.split('twitch.tv/').last.split('?').first;
      if (channel.isNotEmpty) {
        return 'https://player.twitch.tv/?channel=$channel&parent=localhost&parent=sportsbuzz.pages.dev&autoplay=true&muted=false';
      }
    }

    return trimmed;
  }

  void _initPlayer() {
    final embedUrl = _getEmbedUrl(widget.streamUrl);
    if (embedUrl.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView video error: ${error.description}');
          },
        ),
      );

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertTriangle,
                  color: AppColors.liveRed, size: 28),
              const SizedBox(height: 8),
              const Text(
                'Unable to load live video',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _initPlayer,
                icon: const Icon(LucideIcons.refreshCw, size: 14),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0F172A),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Native In-App Embedded WebView Video Player
          WebViewWidget(controller: _controller),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: const Color(0xFF0F172A),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Connecting to live broadcast...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top-right Fullscreen / External Launch Button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () async {
                  final uri = Uri.tryParse(widget.streamUrl.trim());
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.externalLink,
                          size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Open',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
