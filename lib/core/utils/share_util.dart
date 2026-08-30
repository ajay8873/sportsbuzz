import 'package:flutter/foundation.dart';

class ShareUtil {
  ShareUtil._();

  // Configurable base URL for production public spectator portal
  static const String _defaultProductionHost = 'https://sportsbuzz.pages.dev';

  /// Returns the dynamic base domain URL (detects web host or defaults to Cloudflare Pages)
  static String get baseHost {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && !origin.startsWith('null')) {
        return origin;
      }
    }
    return _defaultProductionHost;
  }

  /// Formats the public shareable link for a university fest/event
  static String getEventShareUrl(String shareSlug) {
    final cleanSlug = shareSlug.trim().toLowerCase();
    return '$baseHost/event/$cleanSlug';
  }

  /// Formats the public shareable link for a live match scoreboard
  static String getMatchShareUrl(String matchId) {
    return '$baseHost/matches/$matchId';
  }
}
