part of 'sport_score.dart';

/// Comprehensive Run-based scoring model designed for Cricket
class RunBasedScore extends SportScore {
  final int runs;
  final int wickets;
  final double overs;
  final int balls; // current ball in over (0-5)
  final String battingTeam;
  final String bowlingTeam;
  final String striker;
  final int strikerRuns;
  final int strikerBalls;
  final String nonStriker;
  final int nonStrikerRuns;
  final int nonStrikerBalls;
  final String currentBowler;
  final double bowlerOvers;
  final int bowlerRunsConceded;
  final int bowlerWickets;
  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;
  final int extras;
  final int? target;
  final String innings;
  final List<String> recentBalls;
  final bool isFreeHit;

  const RunBasedScore({
    this.runs = 0,
    this.wickets = 0,
    this.overs = 0.0,
    this.balls = 0,
    this.battingTeam = 'Team A',
    this.bowlingTeam = 'Team B',
    this.striker = 'Striker 1',
    this.strikerRuns = 0,
    this.strikerBalls = 0,
    this.nonStriker = 'Striker 2',
    this.nonStrikerRuns = 0,
    this.nonStrikerBalls = 0,
    this.currentBowler = 'Bowler 1',
    this.bowlerOvers = 0.0,
    this.bowlerRunsConceded = 0,
    this.bowlerWickets = 0,
    this.wides = 0,
    this.noBalls = 0,
    this.byes = 0,
    this.legByes = 0,
    this.extras = 0,
    this.target,
    this.innings = '1st Innings',
    this.recentBalls = const [],
    this.isFreeHit = false,
  });

  @override
  String get type => 'RUN_BASED';

  @override
  String get displaySummary =>
      '$runs/$wickets ($overs ov)${isFreeHit ? ' [FREE HIT]' : ''}';

  RunBasedScore copyWith({
    int? runs,
    int? wickets,
    double? overs,
    int? balls,
    String? battingTeam,
    String? bowlingTeam,
    String? striker,
    int? strikerRuns,
    int? strikerBalls,
    String? nonStriker,
    int? nonStrikerRuns,
    int? nonStrikerBalls,
    String? currentBowler,
    double? bowlerOvers,
    int? bowlerRunsConceded,
    int? bowlerWickets,
    int? wides,
    int? noBalls,
    int? byes,
    int? legByes,
    int? extras,
    int? target,
    String? innings,
    List<String>? recentBalls,
    bool? isFreeHit,
  }) {
    return RunBasedScore(
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      overs: overs ?? this.overs,
      balls: balls ?? this.balls,
      battingTeam: battingTeam ?? this.battingTeam,
      bowlingTeam: bowlingTeam ?? this.bowlingTeam,
      striker: striker ?? this.striker,
      strikerRuns: strikerRuns ?? this.strikerRuns,
      strikerBalls: strikerBalls ?? this.strikerBalls,
      nonStriker: nonStriker ?? this.nonStriker,
      nonStrikerRuns: nonStrikerRuns ?? this.nonStrikerRuns,
      nonStrikerBalls: nonStrikerBalls ?? this.nonStrikerBalls,
      currentBowler: currentBowler ?? this.currentBowler,
      bowlerOvers: bowlerOvers ?? this.bowlerOvers,
      bowlerRunsConceded: bowlerRunsConceded ?? this.bowlerRunsConceded,
      bowlerWickets: bowlerWickets ?? this.bowlerWickets,
      wides: wides ?? this.wides,
      noBalls: noBalls ?? this.noBalls,
      byes: byes ?? this.byes,
      legByes: legByes ?? this.legByes,
      extras: extras ?? this.extras,
      target: target ?? this.target,
      innings: innings ?? this.innings,
      recentBalls: recentBalls ?? this.recentBalls,
      isFreeHit: isFreeHit ?? this.isFreeHit,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'runs': runs,
      'wickets': wickets,
      'overs': overs,
      'balls': balls,
      'battingTeam': battingTeam,
      'bowlingTeam': bowlingTeam,
      'striker': striker,
      'strikerRuns': strikerRuns,
      'strikerBalls': strikerBalls,
      'nonStriker': nonStriker,
      'nonStrikerRuns': nonStrikerRuns,
      'nonStrikerBalls': nonStrikerBalls,
      'currentBowler': currentBowler,
      'bowlerOvers': bowlerOvers,
      'bowlerRunsConceded': bowlerRunsConceded,
      'bowlerWickets': bowlerWickets,
      'wides': wides,
      'noBalls': noBalls,
      'byes': byes,
      'legByes': legByes,
      'extras': extras,
      'target': target,
      'innings': innings,
      'recentBalls': recentBalls,
      'isFreeHit': isFreeHit,
    };
  }

  factory RunBasedScore.fromJson(Map<String, dynamic> json) {
    return RunBasedScore(
      runs: (json['runs'] as num?)?.toInt() ?? 0,
      wickets: (json['wickets'] as num?)?.toInt() ?? 0,
      overs: (json['overs'] as num?)?.toDouble() ?? 0.0,
      balls: (json['balls'] as num?)?.toInt() ?? 0,
      battingTeam: json['battingTeam'] as String? ?? 'Team A',
      bowlingTeam: json['bowlingTeam'] as String? ?? 'Team B',
      striker: json['striker'] as String? ?? 'Striker 1',
      strikerRuns: (json['strikerRuns'] as num?)?.toInt() ?? 0,
      strikerBalls: (json['strikerBalls'] as num?)?.toInt() ?? 0,
      nonStriker: json['nonStriker'] as String? ?? 'Striker 2',
      nonStrikerRuns: (json['nonStrikerRuns'] as num?)?.toInt() ?? 0,
      nonStrikerBalls: (json['nonStrikerBalls'] as num?)?.toInt() ?? 0,
      currentBowler: json['currentBowler'] as String? ?? 'Bowler 1',
      bowlerOvers: (json['bowlerOvers'] as num?)?.toDouble() ?? 0.0,
      bowlerRunsConceded: (json['bowlerRunsConceded'] as num?)?.toInt() ?? 0,
      bowlerWickets: (json['bowlerWickets'] as num?)?.toInt() ?? 0,
      wides: (json['wides'] as num?)?.toInt() ?? 0,
      noBalls: (json['noBalls'] as num?)?.toInt() ?? 0,
      byes: (json['byes'] as num?)?.toInt() ?? 0,
      legByes: (json['legByes'] as num?)?.toInt() ?? 0,
      extras: (json['extras'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt(),
      innings: json['innings'] as String? ?? '1st Innings',
      recentBalls: (json['recentBalls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isFreeHit: json['isFreeHit'] as bool? ?? false,
    );
  }
}
