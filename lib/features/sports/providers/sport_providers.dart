import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sport_model.dart';
import '../models/sport_category.dart';
import '../data/sport_dao.dart';

final sportDaoProvider = Provider<SportDao>((ref) {
  return SportDao();
});

final sportsForEventProvider =
    FutureProvider.family<List<SportModel>, String>((ref, eventId) async {
  final dao = ref.watch(sportDaoProvider);
  return dao.getSportsByEvent(eventId);
});

final selectedSportCategoryProvider =
    StateProvider<SportCategory>((ref) => SportCategory.outdoor);

final selectedSportIdProvider = StateProvider<String?>((ref) => null);

final sportByIdProvider =
    FutureProvider.family<SportModel?, String>((ref, sportId) async {
  final dao = ref.watch(sportDaoProvider);
  return dao.getSportById(sportId);
});
