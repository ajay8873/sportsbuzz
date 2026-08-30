import 'package:flutter_riverpod/flutter_riverpod.dart';
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
