import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Configurable URL and Anon Key
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xskpdmbqntvgbujktpke.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_Gw_z6b8dIysnrJT2AVKNGA_D1q3UHHp',
  );

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Safely initialize Supabase client if not already running
  static Future<void> initialize({
    String? url,
    String? anonKey,
  }) async {
    if (_isInitialized) return;

    final targetUrl = url ?? supabaseUrl;
    final targetKey = anonKey ?? supabaseAnonKey;

    try {
      await Supabase.initialize(
        url: targetUrl,
        anonKey: targetKey,
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 10,
        ),
      );
      _isInitialized = true;
    } catch (_) {
      // Allow demo/mock fallback when running without backend credentials
      _isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (!_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return Supabase.instance.client;
  }
}
