import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/admin_auth_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/event_model.dart';
import '../data/event_dao.dart';

final eventDaoProvider = Provider<EventDao>((ref) {
  return EventDao();
});

final allEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final dao = ref.watch(eventDaoProvider);
  return dao.getEvents();
});

final eventBySlugProvider =
    FutureProvider.family<EventModel?, String>((ref, shareSlug) async {
  final dao = ref.watch(eventDaoProvider);
  return dao.getEventBySlug(shareSlug);
});

final eventByIdProvider =
    FutureProvider.family<EventModel?, String>((ref, eventId) async {
  final dao = ref.watch(eventDaoProvider);
  return dao.getEventById(eventId);
});

final adminSharedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final allEvents = await ref.watch(allEventsProvider.future);
  final sharedIds = ref.watch(sharedTournamentsProvider);
  final unlockedIds = ref.watch(unlockedEventsProvider);
  final currentUserEmail = ref.watch(currentUserEmailProvider);
  final isSuperAdmin = ref.watch(isSuperAdminProvider);

  if (isSuperAdmin) {
    return allEvents;
  }

  // Show tournaments where:
  // - user has admin authority (creator or co-admin email)
  // - tournament was unlocked via PIN or shared on this device
  return allEvents.where((e) {
    if (e.canUserAdmin(currentUserEmail)) return true;
    if (sharedIds.contains(e.id) || unlockedIds.contains(e.id)) return true;
    return false;
  }).toList();
});

final personalizedFeedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final allEvents = await ref.watch(allEventsProvider.future);
  final sharedIds = ref.watch(sharedTournamentsProvider);
  final recentIds = ref.watch(recentTournamentsProvider);
  final bookmarkedIds = ref.watch(bookmarkedTournamentsProvider);
  final currentUserEmail = ref.watch(currentUserEmailProvider);
  final isSuperAdmin = ref.watch(isSuperAdminProvider);

  if (isSuperAdmin) {
    return allEvents;
  }

  return allEvents.where((e) {
    if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
      if (e.creatorEmail?.trim().toLowerCase() == currentUserEmail.trim().toLowerCase()) return true;
      if (e.canUserAdmin(currentUserEmail)) return true;
    }
    if (sharedIds.contains(e.id)) return true;
    if (recentIds.contains(e.id)) return true;
    if (bookmarkedIds.contains(e.id)) return true;
    return false;
  }).toList();
});
