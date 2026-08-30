part of 'sport_score.dart';

/// Represents an individual batsman's figures in a cricket match
class BattingEntry {
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final bool isOut;
  final String dismissal;

  const BattingEntry({
    required this.name,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.isOut = false,
    this.dismissal = 'not out',
  });

  double get strikeRate => balls > 0 ? (runs / balls) * 100 : 0.0;

  BattingEntry copyWith({
    String? name,
    int? runs,
    int? balls,
    int? fours,
    int? sixes,
    bool? isOut,
    String? dismissal,
  }) {
    return BattingEntry(
      name: name ?? this.name,
      runs: runs ?? this.runs,
      balls: balls ?? this.balls,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      isOut: isOut ?? this.isOut,
      dismissal: dismissal ?? this.dismissal,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'runs': runs,
        'balls': balls,
        'fours': fours,
        'sixes': sixes,
        'isOut': isOut,
        'dismissal': dismissal,
      };

  factory BattingEntry.fromJson(Map<String, dynamic> json) => BattingEntry(
        name: json['name'] as String? ?? 'Player',
        runs: (json['runs'] as num?)?.toInt() ?? 0,
        balls: (json['balls'] as num?)?.toInt() ?? 0,
        fours: (json['fours'] as num?)?.toInt() ?? 0,
        sixes: (json['sixes'] as num?)?.toInt() ?? 0,
        isOut: json['isOut'] as bool? ?? false,
        dismissal: json['dismissal'] as String? ?? 'not out',
      );
}

/// Represents an individual bowler's figures in a cricket match
class BowlingEntry {
  final String name;
  final double overs;
  final int maidens;
  final int runs;
  final int wickets;

  const BowlingEntry({
    required this.name,
    this.overs = 0.0,
    this.maidens = 0,
    this.runs = 0,
    this.wickets = 0,
  });

  double get economy => overs > 0 ? (runs / overs) : 0.0;

  BowlingEntry copyWith({
    String? name,
    double? overs,
    int? maidens,
    int? runs,
    int? wickets,
  }) {
    return BowlingEntry(
      name: name ?? this.name,
      overs: overs ?? this.overs,
      maidens: maidens ?? this.maidens,
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'overs': overs,
        'maidens': maidens,
        'runs': runs,
        'wickets': wickets,
      };

  factory BowlingEntry.fromJson(Map<String, dynamic> json) => BowlingEntry(
        name: json['name'] as String? ?? 'Bowler',
        overs: (json['overs'] as num?)?.toDouble() ?? 0.0,
        maidens: (json['maidens'] as num?)?.toInt() ?? 0,
        runs: (json['runs'] as num?)?.toInt() ?? 0,
        wickets: (json['wickets'] as num?)?.toInt() ?? 0,
      );
}

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
  final String? tossWinner;
  final String? tossDecision;
  final String? tossSummary;
  final List<BattingEntry> battingScorecard;
  final List<BowlingEntry> bowlingScorecard;

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
    this.tossWinner,
    this.tossDecision,
    this.tossSummary,
    this.battingScorecard = const [],
    this.bowlingScorecard = const [],
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
    String? tossWinner,
    String? tossDecision,
    String? tossSummary,
    List<BattingEntry>? battingScorecard,
    List<BowlingEntry>? bowlingScorecard,
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
      tossWinner: tossWinner ?? this.tossWinner,
      tossDecision: tossDecision ?? this.tossDecision,
      tossSummary: tossSummary ?? this.tossSummary,
      battingScorecard: battingScorecard ?? this.battingScorecard,
      bowlingScorecard: bowlingScorecard ?? this.bowlingScorecard,
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
      'tossWinner': tossWinner,
      'tossDecision': tossDecision,
      'tossSummary': tossSummary,
      'battingScorecard': battingScorecard.map((e) => e.toJson()).toList(),
      'bowlingScorecard': bowlingScorecard.map((e) => e.toJson()).toList(),
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
      tossWinner: json['tossWinner'] as String?,
      tossDecision: json['tossDecision'] as String?,
      tossSummary: json['tossSummary'] as String?,
      battingScorecard: (json['battingScorecard'] as List<dynamic>?)
              ?.map((e) => BattingEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bowlingScorecard: (json['bowlingScorecard'] as List<dynamic>?)
              ?.map((e) => BowlingEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
