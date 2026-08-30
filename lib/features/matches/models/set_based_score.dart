part of 'sport_score.dart';

class SetScoreDetail {
  final int setNumber;
  final int scoreA;
  final int scoreB;
  final String? winner; // TEAM_A, TEAM_B

  const SetScoreDetail({
    required this.setNumber,
    required this.scoreA,
    required this.scoreB,
    this.winner,
  });

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'scoreA': scoreA,
        'scoreB': scoreB,
        'winner': winner,
      };

  factory SetScoreDetail.fromJson(Map<String, dynamic> json) => SetScoreDetail(
        setNumber: (json['setNumber'] as num?)?.toInt() ?? 1,
        scoreA: (json['scoreA'] as num?)?.toInt() ?? 0,
        scoreB: (json['scoreB'] as num?)?.toInt() ?? 0,
        winner: json['winner'] as String?,
      );
}

/// Comprehensive Set-based score model for Volleyball, Badminton, Table Tennis, Tennis
class SetBasedScore extends SportScore {
  final int currentSetPointsA;
  final int currentSetPointsB;
  final int currentSetNumber;
  final int setsWonA;
  final int setsWonB;
  final int maxSets;
  final List<SetScoreDetail> completedSets;
  final String? servingTeam; // TEAM_A, TEAM_B
  final bool isDeuce;
  final String? advantageTeam; // TEAM_A, TEAM_B

  const SetBasedScore({
    this.currentSetPointsA = 0,
    this.currentSetPointsB = 0,
    this.currentSetNumber = 1,
    this.setsWonA = 0,
    this.setsWonB = 0,
    this.maxSets = 3,
    this.completedSets = const [],
    this.servingTeam,
    this.isDeuce = false,
    this.advantageTeam,
  });

  @override
  String get type => 'SET_BASED';

  @override
  String get displaySummary =>
      'Sets: $setsWonA-$setsWonB | Set $currentSetNumber: $currentSetPointsA-$currentSetPointsB';

  SetBasedScore copyWith({
    int? currentSetPointsA,
    int? currentSetPointsB,
    int? currentSetNumber,
    int? setsWonA,
    int? setsWonB,
    int? maxSets,
    List<SetScoreDetail>? completedSets,
    String? servingTeam,
    bool? isDeuce,
    String? advantageTeam,
  }) {
    return SetBasedScore(
      currentSetPointsA: currentSetPointsA ?? this.currentSetPointsA,
      currentSetPointsB: currentSetPointsB ?? this.currentSetPointsB,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      setsWonA: setsWonA ?? this.setsWonA,
      setsWonB: setsWonB ?? this.setsWonB,
      maxSets: maxSets ?? this.maxSets,
      completedSets: completedSets ?? this.completedSets,
      servingTeam: servingTeam ?? this.servingTeam,
      isDeuce: isDeuce ?? this.isDeuce,
      advantageTeam: advantageTeam ?? this.advantageTeam,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'currentSetPointsA': currentSetPointsA,
      'currentSetPointsB': currentSetPointsB,
      'currentSetNumber': currentSetNumber,
      'setsWonA': setsWonA,
      'setsWonB': setsWonB,
      'maxSets': maxSets,
      'completedSets': completedSets.map((e) => e.toJson()).toList(),
      'servingTeam': servingTeam,
      'isDeuce': isDeuce,
      'advantageTeam': advantageTeam,
    };
  }

  factory SetBasedScore.fromJson(Map<String, dynamic> json) {
    return SetBasedScore(
      currentSetPointsA: (json['currentSetPointsA'] as num?)?.toInt() ?? 0,
      currentSetPointsB: (json['currentSetPointsB'] as num?)?.toInt() ?? 0,
      currentSetNumber: (json['currentSetNumber'] as num?)?.toInt() ?? 1,
      setsWonA: (json['setsWonA'] as num?)?.toInt() ?? 0,
      setsWonB: (json['setsWonB'] as num?)?.toInt() ?? 0,
      maxSets: (json['maxSets'] as num?)?.toInt() ?? 3,
      completedSets: (json['completedSets'] as List<dynamic>?)
              ?.map((e) => SetScoreDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      servingTeam: json['servingTeam'] as String?,
      isDeuce: json['isDeuce'] as bool? ?? false,
      advantageTeam: json['advantageTeam'] as String?,
    );
  }
}
