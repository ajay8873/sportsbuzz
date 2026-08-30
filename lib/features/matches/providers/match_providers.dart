import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';
import '../models/match_status.dart';
import '../models/match_state_model.dart';
import '../data/match_dao.dart';
import '../data/match_state_dao.dart';

final matchDaoProvider = Provider<MatchDao>((ref) {
  return MatchDao();
});

final matchStateDaoProvider = Provider<MatchStateDao>((ref) {
  return MatchStateDao();
});

final matchesForSportProvider =
    FutureProvider.family<List<MatchModel>, String>((ref, sportId) async {
  final dao = ref.watch(matchDaoProvider);
  return dao.getMatchesBySport(sportId);
});

final matchesForSportIdsProvider =
    FutureProvider.family<List<MatchModel>, List<String>>((ref, sportIds) async {
  final dao = ref.watch(matchDaoProvider);
  return dao.getMatchesBySportIds(sportIds);
});

final matchByIdProvider =
    FutureProvider.family<MatchModel?, String>((ref, matchId) async {
  final dao = ref.watch(matchDaoProvider);
  return dao.getMatchById(matchId);
});

final selectedMatchTabStatusProvider =
    StateProvider<MatchStatus>((ref) => MatchStatus.live);

class MatchStreamParams {
  final String matchId;
  final MatchStatus status;
  final bool isScorer;
  final bool enableVideoSyncDelay;

  const MatchStreamParams({
    required this.matchId,
    required this.status,
    this.isScorer = false,
    this.enableVideoSyncDelay = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchStreamParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          status == other.status &&
          isScorer == other.isScorer &&
          enableVideoSyncDelay == other.enableVideoSyncDelay;

  @override
  int get hashCode =>
      matchId.hashCode ^
      status.hashCode ^
      isScorer.hashCode ^
      enableVideoSyncDelay.hashCode;
}

final liveMatchStateStreamProvider =
    StreamProvider.family<MatchStateModel, MatchStreamParams>((ref, params) {
  final dao = ref.watch(matchStateDaoProvider);
  return dao.streamMatchState(
    matchId: params.matchId,
    status: params.status,
    isScorer: params.isScorer,
    enableVideoSyncDelay: params.enableVideoSyncDelay,
  );
});
