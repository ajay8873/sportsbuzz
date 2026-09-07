import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/admin_auth_service.dart';
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

  // Show only tournaments that were created on, unlocked by, or shared with this device
  return allEvents
      .where((e) => sharedIds.contains(e.id) || unlockedIds.contains(e.id))
      .toList();
});
