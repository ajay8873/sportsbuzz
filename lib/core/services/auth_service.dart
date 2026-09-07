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

class AuthResult {
  final bool success;
  final String? errorMessage;
  final AppUserProfile? profile;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.profile,
  });
}

class AuthService {
  static const _prefUserEmailKey = 'zest_auth_user_email';
  static const _prefUserNameKey = 'zest_auth_user_name';
  static const _prefUserAvatarKey = 'zest_auth_user_avatar';
  static const _prefUserIdKey = 'zest_auth_user_id';
  static const _prefRememberedEmailKey = 'zest_remembered_login_email';

  static AppUserProfile? _currentProfile;
  static final _authStateController = StreamController<AppUserProfile?>.broadcast();

  static Stream<AppUserProfile?> get onAuthStateChange => _authStateController.stream;
  static AppUserProfile? get currentProfile => _currentProfile;
  static String? get currentEmail => _currentProfile?.email;
  static final Set<String> _superAdminEmails = <String>{};
  static final _superAdminStateController = StreamController<bool>.broadcast();

  static Stream<bool> get onSuperAdminStateChange => _superAdminStateController.stream;

  /// Check whether an email is registered as a superadmin in Supabase SQL
  static bool isSuperAdminEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final normalized = email.trim().toLowerCase();
    return _superAdminEmails.contains(normalized);
  }

  /// Whether current active session user is a verified superadmin in Supabase
  static bool get isSuperAdmin => isSuperAdminEmail(currentEmail);

  @visibleForTesting
  static void registerSuperAdminForTesting(String email) {
    _superAdminEmails.add(email.trim().toLowerCase());
  }

  @visibleForTesting
  static void clearSuperAdminsForTesting() {
    _superAdminEmails.clear();
  }

  /// Synchronize the list of superadmins from Supabase SQL table (app_superadmins)
  static Future<void> syncSuperAdmins() async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final data = await client
            .from('app_superadmins')
            .select('email');
        if (data is List) {
          _superAdminEmails.clear();
          for (final row in data) {
            final em = row['email']?.toString().trim().toLowerCase();
            if (em != null && em.isNotEmpty) {
              _superAdminEmails.add(em);
            }
          }
          _superAdminStateController.add(isSuperAdmin);
        }
      } catch (e) {
        debugPrint('Supabase app_superadmins sync note: $e');
      }
    }
  }

  /// Retrieve previously saved login email on this specific device.
  /// Returns empty string if it's another user's phone or a fresh install.
  static Future<String> getAutofetchedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefRememberedEmailKey) ?? prefs.getString(_prefUserEmailKey);
      if (saved != null && saved.trim().isNotEmpty) {
        return saved.trim();
      }
    } catch (_) {}
    return '';
  }

  static Future<void> saveRememberedEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefRememberedEmailKey, email.trim());
    } catch (_) {}
  }

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

    // 3. Fetch superadmin list from Supabase
    await syncSuperAdmins();
  }

  static void _setProfile(AppUserProfile profile, {bool persist = true}) {
    _currentProfile = profile;
    _authStateController.add(profile);
    syncSuperAdmins();
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

  /// Sign In with Email and Password
  static Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return const AuthResult(
        success: false,
        errorMessage: 'Please enter a valid email address.',
      );
    }
    if (password.isEmpty) {
      return const AuthResult(
        success: false,
        errorMessage: 'Please enter your password.',
      );
    }

    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );
        final user = response.user;
        if (user != null) {
          final profile = AppUserProfile(
            id: user.id,
            email: user.email ?? cleanEmail,
            displayName: user.userMetadata?['full_name'] as String? ??
                user.userMetadata?['name'] as String? ??
                (user.email ?? cleanEmail).split('@').first,
            avatarUrl: user.userMetadata?['avatar_url'] as String? ??
                user.userMetadata?['picture'] as String?,
          );
          _setProfile(profile);
          await saveRememberedEmail(cleanEmail);
          return AuthResult(success: true, profile: profile);
        } else {
          return const AuthResult(
            success: false,
            errorMessage: 'Login failed. Please verify credentials.',
          );
        }
      } on AuthException catch (e) {
        debugPrint('Supabase AuthException: ${e.message}');
        return AuthResult(
          success: false,
          errorMessage: e.message.contains('Invalid login credentials')
              ? 'Invalid login credentials. If you do not have an account yet, click "Create Account".'
              : e.message,
        );
      } catch (e) {
        debugPrint('Sign in error: $e');
        return AuthResult(
          success: false,
          errorMessage: 'Authentication error: ${e.toString()}',
        );
      }
    }

    // Direct fallback mode if offline / client uninitialized
    final profile = AppUserProfile(
      id: 'usr_${cleanEmail.hashCode.abs()}',
      email: cleanEmail,
      displayName: cleanEmail.split('@').first,
    );
    _setProfile(profile);
    await saveRememberedEmail(cleanEmail);
    return AuthResult(success: true, profile: profile);
  }

  /// Sign Up (Create Account) with Email and Password
  static Future<AuthResult> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return const AuthResult(
        success: false,
        errorMessage: 'Please enter a valid email address.',
      );
    }
    if (password.length < 6) {
      return const AuthResult(
        success: false,
        errorMessage: 'Password must be at least 6 characters.',
      );
    }

    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client.auth.signUp(
          email: cleanEmail,
          password: password,
        );
        final user = response.user;
        if (user != null) {
          final profile = AppUserProfile(
            id: user.id,
            email: user.email ?? cleanEmail,
            displayName: cleanEmail.split('@').first,
          );
          _setProfile(profile);
          await saveRememberedEmail(cleanEmail);
          final message = response.session == null
              ? 'Account registered! Please check your email inbox to confirm if verification is enabled.'
              : null;
          return AuthResult(success: true, profile: profile, errorMessage: message);
        } else {
          return const AuthResult(
            success: false,
            errorMessage: 'Could not complete registration. Please try again.',
          );
        }
      } on AuthException catch (e) {
        debugPrint('Supabase AuthException on signUp: ${e.message}');
        return AuthResult(success: false, errorMessage: e.message);
      } catch (e) {
        debugPrint('Sign up error: $e');
        return AuthResult(
          success: false,
          errorMessage: 'Sign up error: ${e.toString()}',
        );
      }
    }

    // Direct fallback
    final profile = AppUserProfile(
      id: 'usr_${cleanEmail.hashCode.abs()}',
      email: cleanEmail,
      displayName: cleanEmail.split('@').first,
    );
    _setProfile(profile);
    await saveRememberedEmail(cleanEmail);
    return AuthResult(success: true, profile: profile);
  }

  /// Trigger Google OAuth Sign-In via Supabase
  static Future<AuthResult> signInWithGoogle() async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.sportsbuzz://login-callback',
        );
        return const AuthResult(success: true);
      } on AuthException catch (e) {
        debugPrint('Google OAuth error: ${e.message}');
        return AuthResult(success: false, errorMessage: e.message);
      } catch (e) {
        debugPrint('Google OAuth initiation error: $e');
        return AuthResult(
          success: false,
          errorMessage: 'Google Sign-In failed: ${e.toString()}',
        );
      }
    }
    return const AuthResult(
      success: false,
      errorMessage: 'Supabase client is not initialized.',
    );
  }

  /// Direct Dev/Test Sign-In to allow testing custom email
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
    await saveRememberedEmail(cleanEmail);
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
