import '../../sports/models/scoring_model.dart';

part 'run_based_score.dart';
part 'time_based_score.dart';
part 'set_based_score.dart';
part 'board_based_score.dart';
part 'match_based_score.dart';

/// Sealed abstract class representing polymorphic sport scoring states
sealed class SportScore {
  const SportScore();

  String get type;
  String get displaySummary;

  Map<String, dynamic> toJson();

  /// Default factory constructor for initial blank states based on ScoringModel
  static SportScore createInitial(ScoringModel model,
      {String? sportName, int? maxSets, String? teamA, String? teamB}) {
    switch (model) {
      case ScoringModel.runBased:
        return RunBasedScore(
          battingTeam: teamA ?? 'Team A',
          bowlingTeam: teamB ?? 'Team B',
          striker: 'Striker 1',
          nonStriker: 'Striker 2',
          currentBowler: 'Bowler 1',
          battingScorecard: [
            const BattingEntry(name: 'Striker 1', dismissal: 'not out'),
            const BattingEntry(name: 'Striker 2', dismissal: 'not out'),
          ],
          bowlingScorecard: [
            const BowlingEntry(name: 'Bowler 1'),
          ],
        );
      case ScoringModel.timeBased:
        return const TimeBasedScore();
      case ScoringModel.setBased:
        return SetBasedScore(maxSets: maxSets ?? 3);
      case ScoringModel.boardBased:
        return const BoardBasedScore();
      case ScoringModel.matchBased:
        return MatchBasedScore(
          subCategory: (sportName?.toLowerCase().contains('athletics') ?? false)
              ? 'ATHLETICS_100M'
              : 'TUG_OF_WAR',
        );
    }
  }

  /// Polymorphic deserializer converting JSONB payload to appropriate sealed class subtype
  factory SportScore.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'TIME_BASED';

    switch (type.toUpperCase()) {
      case 'RUN_BASED':
        return RunBasedScore.fromJson(json);
      case 'TIME_BASED':
        return TimeBasedScore.fromJson(json);
      case 'SET_BASED':
        return SetBasedScore.fromJson(json);
      case 'BOARD_BASED':
        return BoardBasedScore.fromJson(json);
      case 'MATCH_BASED':
        return MatchBasedScore.fromJson(json);
      default:
        return TimeBasedScore.fromJson(json);
    }
  }
}
