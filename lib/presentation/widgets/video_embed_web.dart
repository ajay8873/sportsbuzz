// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredViews = {};

String _normalizeStreamUrl(String url) {
  final trimmed = url.trim();

  // VDO.Ninja (add clean output and autoplay params if not present)
  if (trimmed.contains('vdo.ninja')) {
    if (!trimmed.contains('autoplay')) {
      final separator = trimmed.contains('?') ? '&' : '?';
      return '$trimmed${separator}autoplay=1&cleanoutput=1';
    }
    return trimmed;
  }

  // YouTube Links: https://www.youtube.com/watch?v=ID or https://youtu.be/ID or https://youtube.com/live/ID
  if (trimmed.contains('youtube.com') || trimmed.contains('youtu.be')) {
    String? videoId;
    if (trimmed.contains('youtu.be/')) {
      videoId = trimmed.split('youtu.be/').last.split('?').first;
    } else if (trimmed.contains('watch?v=')) {
      videoId = trimmed.split('watch?v=').last.split('&').first;
    } else if (trimmed.contains('/live/')) {
      videoId = trimmed.split('/live/').last.split('?').first;
    } else if (trimmed.contains('/embed/')) {
      return trimmed;
    }
    if (videoId != null && videoId.isNotEmpty) {
      return 'https://www.youtube.com/embed/$videoId?autoplay=1&mute=0&rel=0';
    }
  }

  // Twitch: https://twitch.tv/username
  if (trimmed.contains('twitch.tv/')) {
    final channel = trimmed.split('twitch.tv/').last.split('?').first.replaceAll('/', '');
    if (channel.isNotEmpty) {
      return 'https://player.twitch.tv/?channel=$channel&parent=sportsbuzz.pages.dev&parent=localhost&autoplay=true';
    }
  }

  return trimmed;
}

Widget buildPlatformVideoPlayer({
  required String streamUrl,
  required bool isLive,
}) {
  final embedUrl = _normalizeStreamUrl(streamUrl);
  final viewId = 'video-embed-${embedUrl.hashCode.abs()}';

  if (!_registeredViews.contains(viewId)) {
    _registeredViews.add(viewId);

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) {
        // If it's a direct HLS or MP4 video URL
        if (embedUrl.endsWith('.m3u8') || embedUrl.endsWith('.mp4')) {
          final videoElement = html.VideoElement()
            ..src = embedUrl
            ..autoplay = true
            ..controls = true
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.backgroundColor = '#000000'
            ..setAttribute('playsinline', 'true');
          return videoElement;
        }

        // Otherwise render an interactive responsive iframe (VDO.Ninja, YouTube, Twitch, etc.)
        final iframe = html.IFrameElement()
          ..src = embedUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#000000'
          ..allow = 'autoplay; camera; microphone; fullscreen; picture-in-picture; display-capture'
          ..setAttribute('allowfullscreen', 'true');
        return iframe;
      },
    );
  }

  return HtmlElementView(
    key: ValueKey(viewId),
    viewType: viewId,
  );
}
