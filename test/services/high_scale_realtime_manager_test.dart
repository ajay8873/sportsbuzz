import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbuzz/core/services/high_scale_realtime_manager.dart';
import 'package:sportsbuzz/features/matches/models/match_state_model.dart';
import 'package:sportsbuzz/features/matches/models/match_status.dart';
import 'package:sportsbuzz/features/matches/models/sport_score.dart';

void main() {
  group('HighScaleRealtimeManager Tests', () {
    late HighScaleRealtimeManager manager;

    setUp(() {
      manager = HighScaleRealtimeManager();
    });

    test('Bypasses 200 WebSocket limit with local & REST adaptive stream fallback', () async {
      const matchId = 'm001-cricket';
      const initialScore = RunBasedScore(
        runs: 100,
        wickets: 2,
        overs: 10.0,
      );

      final stream = manager.subscribeToMatch(
        matchId: matchId,
        initialStatus: MatchStatus.live,
        restFetcher: (id) async {
          return MatchStateModel(
            id: 'state_$id',
            matchId: id,
            currentScore: initialScore,
            updatedAt: DateTime.now(),
          );
        },
      );

      final expectation = expectLater(
        stream,
        emits(predicate<MatchStateModel>((state) {
          return state.matchId == matchId &&
              (state.currentScore as RunBasedScore).runs == 100;
        })),
      );

      await expectation;
    });

    test('Broadcasts and delivers score update across subscribers without WebSocket errors', () async {
      const matchId = 'm002-football';
      final stream = manager.subscribeToMatch(
        matchId: matchId,
        initialStatus: MatchStatus.live,
      );

      const updatedScore = TimeBasedScore(
        teamAScore: 1,
        teamBScore: 0,
        elapsedSeconds: 900,
      );

      final newState = MatchStateModel(
        id: 'state_m002',
        matchId: matchId,
        currentScore: updatedScore,
        updatedAt: DateTime.now(),
      );

      final expectation = expectLater(
        stream,
        emits(predicate<MatchStateModel>((state) {
          return state.matchId == matchId &&
              (state.currentScore as TimeBasedScore).teamAScore == 1;
        })),
      );

      await manager.broadcastScoreUpdate(
        matchId: matchId,
        state: newState,
      );

      await expectation;
    });
  });
}
