part of 'sport_score.dart';

class TugOfWarRound {
  final int roundNumber;
  final String winner; // TEAM_A, TEAM_B
  final int durationSeconds;

  const TugOfWarRound({
    required this.roundNumber,
    required this.winner,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
        'roundNumber': roundNumber,
        'winner': winner,
        'durationSeconds': durationSeconds,
      };

  factory TugOfWarRound.fromJson(Map<String, dynamic> json) => TugOfWarRound(
        roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 1,
        winner: json['winner'] as String? ?? 'TEAM_A',
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      );
}

class AthleticsParticipantEntry {
  final int lane;
  final String athleteName;
  final String teamOrDept;
  final String formattedResult; // e.g. "10.45s", "6.72m"
  final int? rank;
  final bool isDisqualified;

  const AthleticsParticipantEntry({
    required this.lane,
    required this.athleteName,
    required this.teamOrDept,
    this.formattedResult = '--',
    this.rank,
    this.isDisqualified = false,
  });

  Map<String, dynamic> toJson() => {
        'lane': lane,
        'athleteName': athleteName,
        'teamOrDept': teamOrDept,
        'formattedResult': formattedResult,
        'rank': rank,
        'isDisqualified': isDisqualified,
      };

  factory AthleticsParticipantEntry.fromJson(Map<String, dynamic> json) =>
      AthleticsParticipantEntry(
        lane: (json['lane'] as num?)?.toInt() ?? 1,
        athleteName: json['athleteName'] as String? ?? '',
        teamOrDept: json['teamOrDept'] as String? ?? '',
        formattedResult: json['formattedResult'] as String? ?? '--',
        rank: (json['rank'] as num?)?.toInt(),
        isDisqualified: json['isDisqualified'] as bool? ?? false,
      );
}

/// Comprehensive Match/Track-based scoring model for Tug of War, Athletics, Sprints
class MatchBasedScore extends SportScore {
  final String? overallWinner;
  final int roundsWonA;
  final int roundsWonB;
  final int totalRounds;
  final List<TugOfWarRound> tugOfWarRounds;
  final List<AthleticsParticipantEntry> athleticsEntries;
  final String subCategory; // TUG_OF_WAR, ATHLETICS_100M, RELAY, LONG_JUMP, etc.
  final String eventStage; // Final, Semi-Final, Heat 1, Heat 2

  const MatchBasedScore({
    this.overallWinner,
    this.roundsWonA = 0,
    this.roundsWonB = 0,
    this.totalRounds = 3,
    this.tugOfWarRounds = const [],
    this.athleticsEntries = const [],
    this.subCategory = 'TUG_OF_WAR',
    this.eventStage = 'Final',
  });

  @override
  String get type => 'MATCH_BASED';

  @override
  String get displaySummary {
    if (subCategory == 'TUG_OF_WAR') {
      return 'Tug of War: $roundsWonA - $roundsWonB (Best of $totalRounds)';
    }
    if (overallWinner != null && overallWinner!.isNotEmpty) {
      return 'Winner: $overallWinner ($eventStage)';
    }
    return '$subCategory ($eventStage)';
  }

  MatchBasedScore copyWith({
    String? overallWinner,
    int? roundsWonA,
    int? roundsWonB,
    int? totalRounds,
    List<TugOfWarRound>? tugOfWarRounds,
    List<AthleticsParticipantEntry>? athleticsEntries,
    String? subCategory,
    String? eventStage,
  }) {
    return MatchBasedScore(
      overallWinner: overallWinner ?? this.overallWinner,
      roundsWonA: roundsWonA ?? this.roundsWonA,
      roundsWonB: roundsWonB ?? this.roundsWonB,
      totalRounds: totalRounds ?? this.totalRounds,
      tugOfWarRounds: tugOfWarRounds ?? this.tugOfWarRounds,
      athleticsEntries: athleticsEntries ?? this.athleticsEntries,
      subCategory: subCategory ?? this.subCategory,
      eventStage: eventStage ?? this.eventStage,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'overallWinner': overallWinner,
      'roundsWonA': roundsWonA,
      'roundsWonB': roundsWonB,
      'totalRounds': totalRounds,
      'tugOfWarRounds': tugOfWarRounds.map((e) => e.toJson()).toList(),
      'athleticsEntries': athleticsEntries.map((e) => e.toJson()).toList(),
      'subCategory': subCategory,
      'eventStage': eventStage,
    };
  }

  factory MatchBasedScore.fromJson(Map<String, dynamic> json) {
    return MatchBasedScore(
      overallWinner: json['overallWinner'] as String?,
      roundsWonA: (json['roundsWonA'] as num?)?.toInt() ?? 0,
      roundsWonB: (json['roundsWonB'] as num?)?.toInt() ?? 0,
      totalRounds: (json['totalRounds'] as num?)?.toInt() ?? 3,
      tugOfWarRounds: (json['tugOfWarRounds'] as List<dynamic>?)
              ?.map((e) => TugOfWarRound.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      athleticsEntries: (json['athleticsEntries'] as List<dynamic>?)
              ?.map((e) =>
                  AthleticsParticipantEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subCategory: json['subCategory'] as String? ?? 'TUG_OF_WAR',
      eventStage: json['eventStage'] as String? ?? 'Final',
    );
  }
}
