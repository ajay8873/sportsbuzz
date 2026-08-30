import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/services/high_scale_realtime_manager.dart';
import '../../events/data/event_dao.dart';
import '../models/match_state_model.dart';
import '../models/match_status.dart';
import '../models/sport_score.dart';
import '../../../features/sports/models/scoring_model.dart';

class MatchStateDao {
  static final Map<String, MatchStateModel> _mockMatchStates = {
    EventDao.defaultCricketMatchId: MatchStateModel(
      id: const Uuid().v4(),
      matchId: EventDao.defaultCricketMatchId,
      currentScore: SportScore.createInitial(ScoringModel.runBased, sportName: 'Cricket'),
      updatedAt: DateTime.now(),
    ),
    EventDao.defaultVolleyballMatchId: MatchStateModel(
      id: const Uuid().v4(),
      matchId: EventDao.defaultVolleyballMatchId,
      currentScore: SportScore.createInitial(ScoringModel.setBased, sportName: 'Volleyball'),
      updatedAt: DateTime.now(),
    ),
  };

  final HighScaleRealtimeManager _scalingManager = HighScaleRealtimeManager();

  Future<MatchStateModel?> getMatchState(String matchId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('match_state')
            .select()
            .eq('match_id', matchId)
            .maybeSingle();
        if (response != null) {
          final model = MatchStateModel.fromJson(response);
          _mockMatchStates[matchId] = model;
          return model;
        }
      } catch (e) {
        debugPrint('Supabase getMatchState error: $e');
      }
    }
    return _mockMatchStates[matchId];
  }

  Future<void> updateScore({
    required String matchId,
    required SportScore newScore,
  }) async {
    final existing = _mockMatchStates[matchId];
    final stateModel = MatchStateModel(
      id: existing?.id ?? const Uuid().v4(),
      matchId: matchId,
      currentScore: newScore,
      updatedAt: DateTime.now(),
    );

    // 1. Update in-memory fallback
    _mockMatchStates[matchId] = stateModel;

    // 2. Broadcast via high-scale manager
    await _scalingManager.broadcastScoreUpdate(
      matchId: matchId,
      state: stateModel,
    );

    // 3. Persist to Supabase
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client.from('match_state').upsert(
              stateModel.toJson(),
              onConflict: 'match_id',
            );
      } catch (e) {
        debugPrint('Supabase updateScore error: $e');
      }
    }
  }

  /// Subscribe to live score updates using 4-tier high-scale engine
  Stream<MatchStateModel> streamMatchState({
    required String matchId,
    required MatchStatus status,
    bool isScorer = false,
    bool enableVideoSyncDelay = false,
  }) {
    return _scalingManager.subscribeToMatch(
      matchId: matchId,
      initialStatus: status,
      isScorer: isScorer,
      enableVideoSyncDelay: enableVideoSyncDelay,
      restFetcher: getMatchState,
    );
  }
}
