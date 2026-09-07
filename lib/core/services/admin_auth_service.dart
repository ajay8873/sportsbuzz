import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../../features/events/models/event_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which event IDs have been unlocked via PIN on this device
class UnlockedEventsNotifier extends Notifier<Set<String>> {
  static const _prefKey = 'unlocked_tournament_ids';

  @override
  Set<String> build() {
    _loadFromStorage();
    return <String>{};
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey);
      if (list != null && list.isNotEmpty) {
        state = {...state, ...list};
      }
    } catch (_) {}
  }

  Future<void> unlock(String eventId) async {
    state = {...state, eventId};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.toList());
    } catch (_) {}
  }

  Future<void> lock(String eventId) async {
    state = state.where((id) => id != eventId).toSet();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.toList());
    } catch (_) {}
  }

  bool isUnlocked(String eventId) => state.contains(eventId);
}

final unlockedEventsProvider =
    NotifierProvider<UnlockedEventsNotifier, Set<String>>(
  UnlockedEventsNotifier.new,
);

/// Tracks tournament IDs that have been shared with, created on, or accessed by this device
class SharedTournamentsNotifier extends Notifier<Set<String>> {
  static const _prefKey = 'shared_tournament_ids';

  @override
  Set<String> build() {
    _loadFromStorage();
    return <String>{};
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey);
      if (list != null && list.isNotEmpty) {
        state = {...state, ...list};
      }
    } catch (_) {}
  }

  Future<void> addSharedEvent(String eventId) async {
    if (state.contains(eventId)) return;
    state = {...state, eventId};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.toList());
    } catch (_) {}
  }

  Future<void> removeSharedEvent(String eventId) async {
    state = state.where((id) => id != eventId).toSet();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.toList());
    } catch (_) {}
  }

  bool isShared(String eventId) => state.contains(eventId);
}

final sharedTournamentsProvider =
    NotifierProvider<SharedTournamentsNotifier, Set<String>>(
  SharedTournamentsNotifier.new,
);

/// Tracks recently opened tournament IDs in chronological order (most recent first)
class RecentTournamentsNotifier extends Notifier<List<String>> {
  static const _prefKey = 'recent_opened_tournament_ids';

  @override
  List<String> build() {
    _loadFromStorage();
    return <String>[];
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey);
      if (list != null && list.isNotEmpty) {
        state = list;
      }
    } catch (_) {}
  }

  Future<void> addRecentEvent(String eventId) async {
    final updated = [eventId, ...state.where((id) => id != eventId)];
    if (updated.length > 25) {
      updated.removeRange(25, updated.length);
    }
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, updated);
    } catch (_) {}
  }

  Future<void> clearRecent() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (_) {}
  }
}

final recentTournamentsProvider =
    NotifierProvider<RecentTournamentsNotifier, List<String>>(
  RecentTournamentsNotifier.new,
);

/// Tracks tournament IDs that have been bookmarked/saved by this user/device
class BookmarkedTournamentsNotifier extends Notifier<Set<String>> {
  static const _prefKey = 'bookmarked_tournament_ids';

  @override
  Set<String> build() {
    _loadFromStorage();
    return <String>{};
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey);
      if (list != null && list.isNotEmpty) {
        state = {...state, ...list};
      }
    } catch (_) {}
  }

  Future<void> toggleBookmark(String eventId) async {
    if (state.contains(eventId)) {
      state = state.where((id) => id != eventId).toSet();
    } else {
      state = {...state, eventId};
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.toList());
    } catch (_) {}
  }

  bool isBookmarked(String eventId) => state.contains(eventId);
}

final bookmarkedTournamentsProvider =
    NotifierProvider<BookmarkedTournamentsNotifier, Set<String>>(
  BookmarkedTournamentsNotifier.new,
);

class AdminAuthService {
  AdminAuthService._();

  /// Prompt the user to enter the Event Admin Passcode / PIN
  static Future<bool> promptPin({
    required BuildContext context,
    required WidgetRef ref,
    required EventModel event,
  }) async {
    // If already unlocked in this session, allow immediately
    if (ref.read(unlockedEventsProvider).contains(event.id)) {
      return true;
    }

    final expectedPin = (event.adminPin != null && event.adminPin!.isNotEmpty)
        ? event.adminPin!
        : '1234';

    final pinController = TextEditingController();
    bool isObscured = true;
    String? errorMessage;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.lock,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Organizer PIN Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the 4-digit admin passcode for "${event.name}" to manage matches and scorecards.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: isObscured,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Admin Passcode / PIN',
                      hintText: 'Enter 4-digit PIN',
                      counterText: '',
                      prefixIcon: const Icon(LucideIcons.keyRound, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscured ? LucideIcons.eye : LucideIcons.eyeOff,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                      ),
                      errorText: errorMessage,
                    ),
                    onSubmitted: (_) {
                      final input = pinController.text.trim();
                      if (input == expectedPin) {
                        ref.read(unlockedEventsProvider.notifier).unlock(event.id);
                        ref.read(sharedTournamentsProvider.notifier).addSharedEvent(event.id);
                        Navigator.of(ctx).pop(true);
                      } else {
                        setState(() {
                          errorMessage = 'Incorrect PIN. Please try again.';
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final input = pinController.text.trim();
                    if (input == expectedPin) {
                      ref.read(unlockedEventsProvider.notifier).unlock(event.id);
                      ref.read(sharedTournamentsProvider.notifier).addSharedEvent(event.id);
                      Navigator.of(ctx).pop(true);
                    } else {
                      setState(() {
                        errorMessage = 'Incorrect PIN. Please try again.';
                      });
                    }
                  },
                  child: const Text('Unlock Console'),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }
}
