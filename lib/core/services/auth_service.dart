import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

class AppUserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  const AppUserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
      };

  factory AppUserProfile.fromJson(Map<String, dynamic> json) => AppUserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class AuthService {
  static const _prefUserEmailKey = 'zest_auth_user_email';
  static const _prefUserNameKey = 'zest_auth_user_name';
  static const _prefUserAvatarKey = 'zest_auth_user_avatar';
  static const _prefUserIdKey = 'zest_auth_user_id';

  static AppUserProfile? _currentProfile;
  static final _authStateController = StreamController<AppUserProfile?>.broadcast();

  static Stream<AppUserProfile?> get onAuthStateChange => _authStateController.stream;
  static AppUserProfile? get currentProfile => _currentProfile;
  static String? get currentEmail => _currentProfile?.email;

  static const String superAdminEmail = 'mehtaajay8873@gmail.com';

  static bool get isSuperAdmin =>
      currentEmail?.trim().toLowerCase() == superAdminEmail.toLowerCase();

  static Future<void> initialize() async {
    // 1. Check active Supabase session
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      final user = client.auth.currentUser;
      if (user != null && user.email != null) {
        _setProfile(
          AppUserProfile(
            id: user.id,
            email: user.email!,
            displayName: user.userMetadata?['full_name'] as String? ??
                user.userMetadata?['name'] as String? ??
                user.email!.split('@').first,
            avatarUrl: user.userMetadata?['avatar_url'] as String? ??
                user.userMetadata?['picture'] as String?,
          ),
        );
      }

      // Listen to Supabase auth changes
      client.auth.onAuthStateChange.listen((data) {
        final u = data.session?.user;
        if (u != null && u.email != null) {
          _setProfile(
            AppUserProfile(
              id: u.id,
              email: u.email!,
              displayName: u.userMetadata?['full_name'] as String? ??
                  u.userMetadata?['name'] as String? ??
                  u.email!.split('@').first,
              avatarUrl: u.userMetadata?['avatar_url'] as String? ??
                  u.userMetadata?['picture'] as String?,
            ),
          );
        } else if (data.event == AuthChangeEvent.signedOut) {
          _clearProfile();
        }
      });
    }

    // 2. Fallback to persisted SharedPreferences profile if not set yet
    if (_currentProfile == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString(_prefUserEmailKey);
        if (email != null && email.isNotEmpty) {
          _setProfile(
            AppUserProfile(
              id: prefs.getString(_prefUserIdKey) ?? email,
              email: email,
              displayName: prefs.getString(_prefUserNameKey) ?? email.split('@').first,
              avatarUrl: prefs.getString(_prefUserAvatarKey),
            ),
            persist: false,
          );
        }
      } catch (_) {}
    }
  }

  static void _setProfile(AppUserProfile profile, {bool persist = true}) {
    _currentProfile = profile;
    _authStateController.add(profile);
    if (persist) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_prefUserEmailKey, profile.email);
        prefs.setString(_prefUserIdKey, profile.id);
        if (profile.displayName != null) {
          prefs.setString(_prefUserNameKey, profile.displayName!);
        }
        if (profile.avatarUrl != null) {
          prefs.setString(_prefUserAvatarKey, profile.avatarUrl!);
        }
      });
    }
  }

  static void _clearProfile() {
    _currentProfile = null;
    _authStateController.add(null);
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_prefUserEmailKey);
      prefs.remove(_prefUserIdKey);
      prefs.remove(_prefUserNameKey);
      prefs.remove(_prefUserAvatarKey);
    });
  }

  /// Trigger Google OAuth Sign-In via Supabase
  static Future<bool> signInWithGoogle() async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.sportsbuzz://login-callback',
        );
        return true;
      } catch (e) {
        debugPrint('Google OAuth initiation error: $e');
      }
    }
    return false;
  }

  /// Direct Dev/Test Sign-In to allow testing superadmin or any custom email
  static Future<void> signInDirect({
    required String email,
    String? displayName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final profile = AppUserProfile(
      id: 'usr_${cleanEmail.hashCode.abs()}',
      email: cleanEmail,
      displayName: displayName ?? cleanEmail.split('@').first,
    );
    _setProfile(profile);
  }

  /// Sign out
  static Future<void> signOut() async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    _clearProfile();
  }
}
