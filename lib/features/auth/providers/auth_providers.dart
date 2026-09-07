import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';

class AuthUserNotifier extends Notifier<AppUserProfile?> {
  @override
  AppUserProfile? build() {
    final sub = AuthService.onAuthStateChange.listen((profile) {
      state = profile;
    });
    ref.onDispose(sub.cancel);
    return AuthService.currentProfile;
  }
}

final authUserProvider = NotifierProvider<AuthUserNotifier, AppUserProfile?>(
  AuthUserNotifier.new,
);

final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authUserProvider)?.email;
});

final isSuperAdminProvider = Provider<bool>((ref) {
  final email = ref.watch(currentUserEmailProvider);
  if (email == null) return false;
  return email.trim().toLowerCase() == AuthService.superAdminEmail.toLowerCase();
});
