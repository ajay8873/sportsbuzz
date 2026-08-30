import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbuzz/features/matches/models/sport_score.dart';
import 'package:sportsbuzz/features/sports/models/scoring_model.dart';

void main() {
  group('SportScore Sealed Hierarchy Serialization Tests', () {
    test('RunBasedScore JSON round-trip serialization', () {
      const score = RunBasedScore(
        runs: 142,
        wickets: 4,
        overs: 16.3,
        balls: 3,
        battingTeam: 'Computer Science',
        bowlingTeam: 'Mechanical Eng',
        striker: 'Aryan Sharma',
        strikerRuns: 64,
        strikerBalls: 38,
        nonStriker: 'Rohan Verma',
        nonStrikerRuns: 28,
        nonStrikerBalls: 19,
        currentBowler: 'Vikram Singh',
        bowlerOvers: 3.3,
        bowlerRunsConceded: 26,
        bowlerWickets: 2,
        extras: 8,
        recentBalls: ['1', '4', '0', 'W', '6', '1'],
      );

      final json = score.toJson();
      expect(json['type'], 'RUN_BASED');
      expect(json['runs'], 142);
      expect(json['wickets'], 4);

      final deserialized = SportScore.fromJson(json) as RunBasedScore;
      expect(deserialized.runs, 142);
      expect(deserialized.striker, 'Aryan Sharma');
      expect(deserialized.recentBalls, ['1', '4', '0', 'W', '6', '1']);
      expect(deserialized.displaySummary, '142/4 (16.3 ov)');
    });

    test('TimeBasedScore JSON round-trip serialization', () {
      const score = TimeBasedScore(
        teamAScore: 3,
        teamBScore: 2,
        elapsedSeconds: 4120,
        isClockRunning: true,
        period: '2nd Half',
        teamAYellowCards: 1,
        teamBYellowCards: 2,
        timeline: [
          MatchEventLog(
            id: 'evt-1',
            timestampSeconds: 1200,
            eventType: 'GOAL',
            team: 'TEAM_A',
            playerName: 'Sameer Khan',
          ),
        ],
      );

      final json = score.toJson();
      expect(json['type'], 'TIME_BASED');

      final deserialized = SportScore.fromJson(json) as TimeBasedScore;
      expect(deserialized.teamAScore, 3);
      expect(deserialized.formattedClock, '68:40');
      expect(deserialized.timeline.length, 1);
      expect(deserialized.timeline.first.playerName, 'Sameer Khan');
    });

    test('SetBasedScore JSON round-trip serialization', () {
      const score = SetBasedScore(
        currentSetPointsA: 23,
        currentSetPointsB: 21,
        currentSetNumber: 3,
        setsWonA: 1,
        setsWonB: 1,
        servingTeam: 'TEAM_A',
        completedSets: [
          SetScoreDetail(setNumber: 1, scoreA: 25, scoreB: 20, winner: 'TEAM_A'),
          SetScoreDetail(setNumber: 2, scoreA: 22, scoreB: 25, winner: 'TEAM_B'),
        ],
      );

      final json = score.toJson();
      expect(json['type'], 'SET_BASED');

      final deserialized = SportScore.fromJson(json) as SetBasedScore;
      expect(deserialized.currentSetPointsA, 23);
      expect(deserialized.setsWonA, 1);
      expect(deserialized.completedSets.length, 2);
      expect(deserialized.displaySummary, 'Sets: 1-1 | Set 3: 23-21');
    });

    test('BoardBasedScore JSON round-trip serialization', () {
      const score = BoardBasedScore(
        matchPointsA: 1.0,
        matchPointsB: 0.0,
        boardNumber: 2,
        timeRemainingSecondsA: 340,
        timeRemainingSecondsB: 120,
        statusDetail: 'Checkmate',
        movesCount: 34,
      );

      final json = score.toJson();
      expect(json['type'], 'BOARD_BASED');

      final deserialized = SportScore.fromJson(json) as BoardBasedScore;
      expect(deserialized.matchPointsA, 1.0);
      expect(deserialized.statusDetail, 'Checkmate');
      expect(deserialized.clockAFormatted, '05:40');
    });

    test('MatchBasedScore JSON round-trip serialization', () {
      const score = MatchBasedScore(
        subCategory: 'TUG_OF_WAR',
        roundsWonA: 2,
        roundsWonB: 1,
        overallWinner: 'Civil Department',
        tugOfWarRounds: [
          TugOfWarRound(roundNumber: 1, winner: 'TEAM_A', durationSeconds: 45),
          TugOfWarRound(roundNumber: 2, winner: 'TEAM_B', durationSeconds: 52),
          TugOfWarRound(roundNumber: 3, winner: 'TEAM_A', durationSeconds: 38),
        ],
      );

      final json = score.toJson();
      expect(json['type'], 'MATCH_BASED');

      final deserialized = SportScore.fromJson(json) as MatchBasedScore;
      expect(deserialized.roundsWonA, 2);
      expect(deserialized.tugOfWarRounds.length, 3);
      expect(deserialized.displaySummary, 'Tug of War: 2 - 1 (Best of 3)');
    });

    test('Factory initial state creation', () {
      final runInitial = SportScore.createInitial(ScoringModel.runBased);
      expect(runInitial, isA<RunBasedScore>());

      final timeInitial = SportScore.createInitial(ScoringModel.timeBased);
      expect(timeInitial, isA<TimeBasedScore>());

      final setInitial = SportScore.createInitial(ScoringModel.setBased);
      expect(setInitial, isA<SetBasedScore>());

      final boardInitial = SportScore.createInitial(ScoringModel.boardBased);
      expect(boardInitial, isA<BoardBasedScore>());

      final matchInitial = SportScore.createInitial(ScoringModel.matchBased);
      expect(matchInitial, isA<MatchBasedScore>());

      final customRunInitial = SportScore.createInitial(
        ScoringModel.runBased,
        teamA: 'Batch 22',
        teamB: 'Batch 23',
      ) as RunBasedScore;
      expect(customRunInitial.battingTeam, 'Batch 22');
      expect(customRunInitial.bowlingTeam, 'Batch 23');
    });

    test('RunBasedScore toss and scorecard serialization', () {
      const score = RunBasedScore(
        runs: 85,
        wickets: 2,
        overs: 9.4,
        balls: 4,
        tossWinner: 'Batch 22',
        tossDecision: 'BAT',
        tossSummary: 'Batch 22 won toss & opted to Bat first',
        battingScorecard: [
          BattingEntry(name: 'Rohit', runs: 45, balls: 24, fours: 5, sixes: 2, isOut: true, dismissal: 'caught'),
          BattingEntry(name: 'Virat', runs: 30, balls: 20, fours: 3, sixes: 1, isOut: false, dismissal: 'not out'),
        ],
        bowlingScorecard: [
          BowlingEntry(name: 'Bumrah', overs: 3.0, maidens: 0, runs: 18, wickets: 1),
        ],
      );

      final json = score.toJson();
      expect(json['tossWinner'], 'Batch 22');
      expect(json['tossDecision'], 'BAT');
      expect(json['tossSummary'], 'Batch 22 won toss & opted to Bat first');

      final deserialized = SportScore.fromJson(json) as RunBasedScore;
      expect(deserialized.tossWinner, 'Batch 22');
      expect(deserialized.battingScorecard.length, 2);
      expect(deserialized.battingScorecard.first.name, 'Rohit');
      expect(deserialized.battingScorecard.first.isOut, isTrue);
      expect(deserialized.bowlingScorecard.length, 1);
      expect(deserialized.bowlingScorecard.first.name, 'Bumrah');
    });

    test('RunBasedScore squad roster and retired hurt status serialization', () {
      const score = RunBasedScore(
        runs: 54,
        wickets: 1,
        overs: 6.0,
        balls: 0,
        teamASquad: ['Rohit', 'Shubman', 'Virat', 'KL Rahul', 'Hardik'],
        teamBSquad: ['Bumrah', 'Shami', 'Siraj', 'Kuldeep', 'Jadeja'],
        battingScorecard: [
          BattingEntry(name: 'Rohit', runs: 28, balls: 18, isOut: true, dismissal: 'bowled'),
          BattingEntry(name: 'Shubman', runs: 22, balls: 14, isOut: false, dismissal: 'retired hurt'),
          BattingEntry(name: 'Virat', runs: 4, balls: 4, isOut: false, dismissal: 'not out'),
        ],
      );

      final json = score.toJson();
      expect(json['teamASquad'], ['Rohit', 'Shubman', 'Virat', 'KL Rahul', 'Hardik']);
      expect(json['teamBSquad'], ['Bumrah', 'Shami', 'Siraj', 'Kuldeep', 'Jadeja']);

      final deserialized = SportScore.fromJson(json) as RunBasedScore;
      expect(deserialized.teamASquad.length, 5);
      expect(deserialized.teamBSquad.length, 5);
      expect(deserialized.battingScorecard[1].dismissal, 'retired hurt');
      expect(deserialized.battingScorecard[1].isOut, isFalse);
    });
  });
}

