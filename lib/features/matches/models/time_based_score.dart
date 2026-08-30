part of 'sport_score.dart';

class MatchEventLog {
  final String id;
  final int timestampSeconds;
  final String eventType; // GOAL, POINT, FOUL, YELLOW_CARD, RED_CARD, RAID_POINT, TACKLE
  final String team; // TEAM_A, TEAM_B
  final String? playerName;
  final String? notes;

  const MatchEventLog({
    required this.id,
    required this.timestampSeconds,
    required this.eventType,
    required this.team,
    this.playerName,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestampSeconds': timestampSeconds,
        'eventType': eventType,
        'team': team,
        'playerName': playerName,
        'notes': notes,
      };

  factory MatchEventLog.fromJson(Map<String, dynamic> json) => MatchEventLog(
        id: json['id'] as String? ?? '',
        timestampSeconds: (json['timestampSeconds'] as num?)?.toInt() ?? 0,
        eventType: json['eventType'] as String? ?? 'EVENT',
        team: json['team'] as String? ?? 'TEAM_A',
        playerName: json['playerName'] as String?,
        notes: json['notes'] as String?,
      );
}

/// Comprehensive Time-based score model for Football, Basketball, Kabaddi, Hockey
class TimeBasedScore extends SportScore {
  final int teamAScore;
  final int teamBScore;
  final int elapsedSeconds;
  final bool isClockRunning;
  final String period; // 1st Half, 2nd Half, Q1, Q2, Q3, Q4, Extra Time
  final int teamAFouls;
  final int teamBFouls;
  final int teamAYellowCards;
  final int teamBYellowCards;
  final int teamARedCards;
  final int teamBRedCards;
  final List<MatchEventLog> timeline;

  const TimeBasedScore({
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.elapsedSeconds = 0,
    this.isClockRunning = false,
    this.period = '1st Half',
    this.teamAFouls = 0,
    this.teamBFouls = 0,
    this.teamAYellowCards = 0,
    this.teamBYellowCards = 0,
    this.teamARedCards = 0,
    this.teamBRedCards = 0,
    this.timeline = const [],
  });

  @override
  String get type => 'TIME_BASED';

  @override
  String get displaySummary => '$teamAScore - $teamBScore ($formattedClock - $period)';

  String get formattedClock {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  TimeBasedScore copyWith({
    int? teamAScore,
    int? teamBScore,
    int? elapsedSeconds,
    bool? isClockRunning,
    String? period,
    int? teamAFouls,
    int? teamBFouls,
    int? teamAYellowCards,
    int? teamBYellowCards,
    int? teamARedCards,
    int? teamBRedCards,
    List<MatchEventLog>? timeline,
  }) {
    return TimeBasedScore(
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isClockRunning: isClockRunning ?? this.isClockRunning,
      period: period ?? this.period,
      teamAFouls: teamAFouls ?? this.teamAFouls,
      teamBFouls: teamBFouls ?? this.teamBFouls,
      teamAYellowCards: teamAYellowCards ?? this.teamAYellowCards,
      teamBYellowCards: teamBYellowCards ?? this.teamBYellowCards,
      teamARedCards: teamARedCards ?? this.teamARedCards,
      teamBRedCards: teamBRedCards ?? this.teamBRedCards,
      timeline: timeline ?? this.timeline,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'elapsedSeconds': elapsedSeconds,
      'isClockRunning': isClockRunning,
      'period': period,
      'teamAFouls': teamAFouls,
      'teamBFouls': teamBFouls,
      'teamAYellowCards': teamAYellowCards,
      'teamBYellowCards': teamBYellowCards,
      'teamARedCards': teamARedCards,
      'teamBRedCards': teamBRedCards,
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }

  factory TimeBasedScore.fromJson(Map<String, dynamic> json) {
    return TimeBasedScore(
      teamAScore: (json['teamAScore'] as num?)?.toInt() ?? 0,
      teamBScore: (json['teamBScore'] as num?)?.toInt() ?? 0,
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      isClockRunning: json['isClockRunning'] as bool? ?? false,
      period: json['period'] as String? ?? '1st Half',
      teamAFouls: (json['teamAFouls'] as num?)?.toInt() ?? 0,
      teamBFouls: (json['teamBFouls'] as num?)?.toInt() ?? 0,
      teamAYellowCards: (json['teamAYellowCards'] as num?)?.toInt() ?? 0,
      teamBYellowCards: (json['teamBYellowCards'] as num?)?.toInt() ?? 0,
      teamARedCards: (json['teamARedCards'] as num?)?.toInt() ?? 0,
      teamBRedCards: (json['teamBRedCards'] as num?)?.toInt() ?? 0,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => MatchEventLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
