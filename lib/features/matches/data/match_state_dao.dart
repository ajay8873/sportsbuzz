import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/services/high_scale_realtime_manager.dart';
import '../models/match_state_model.dart';
import '../models/match_status.dart';
import '../models/sport_score.dart';

import '../../../features/sports/models/scoring_model.dart';

class MatchStateDao {
  static final Map<String, MatchStateModel> _mockMatchStates = {
    'm_cricket_001': MatchStateModel(
      id: 'state_m_cricket_001',
      matchId: 'm_cricket_001',
      currentScore: SportScore.createInitial(ScoringModel.runBased, sportName: 'Cricket'),
      updatedAt: DateTime.now(),
    ),
    'm_volleyball_001': MatchStateModel(
      id: 'state_m_volleyball_001',
      matchId: 'm_volleyball_001',
      currentScore: SportScore.createInitial(ScoringModel.setBased, sportName: 'Volleyball'),
      updatedAt: DateTime.now(),
    ),
    'm_football_001': MatchStateModel(
      id: 'state_m_football_001',
      matchId: 'm_football_001',
      currentScore: SportScore.createInitial(ScoringModel.timeBased, sportName: 'Football'),
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
          return MatchStateModel.fromJson(response);
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
    final stateModel = MatchStateModel(
      id: 'state_$matchId',
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
