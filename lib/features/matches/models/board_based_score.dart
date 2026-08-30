part of 'sport_score.dart';

/// Comprehensive Board-based score model for Chess, Carrom
class BoardBasedScore extends SportScore {
  final double matchPointsA; // 1.0, 0.5, 0.0
  final double matchPointsB;
  final int boardNumber;
  final int timeRemainingSecondsA; // Chess clock remaining
  final int timeRemainingSecondsB;
  final bool isClockRunning;
  final String activeTurn; // PLAYER_A, PLAYER_B
  final String statusDetail; // In Progress, Check, Checkmate, Stalemate, Resignation, Time Out, Queen Cover
  final int movesCount;
  final List<String> notationHistory; // PGN or move annotations
  final int carromCoinsA; // For carrom games (White/Black coins remaining or scored)
  final int carromCoinsB;
  final bool queenCovered;

  const BoardBasedScore({
    this.matchPointsA = 0.0,
    this.matchPointsB = 0.0,
    this.boardNumber = 1,
    this.timeRemainingSecondsA = 600, // 10 mins default
    this.timeRemainingSecondsB = 600,
    this.isClockRunning = false,
    this.activeTurn = 'PLAYER_A',
    this.statusDetail = 'In Progress',
    this.movesCount = 0,
    this.notationHistory = const [],
    this.carromCoinsA = 0,
    this.carromCoinsB = 0,
    this.queenCovered = false,
  });

  @override
  String get type => 'BOARD_BASED';

  @override
  String get displaySummary =>
      'Board $boardNumber: $matchPointsA - $matchPointsB ($statusDetail)';

  String formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get clockAFormatted => formatTime(timeRemainingSecondsA);
  String get clockBFormatted => formatTime(timeRemainingSecondsB);

  BoardBasedScore copyWith({
    double? matchPointsA,
    double? matchPointsB,
    int? boardNumber,
    int? timeRemainingSecondsA,
    int? timeRemainingSecondsB,
    bool? isClockRunning,
    String? activeTurn,
    String? statusDetail,
    int? movesCount,
    List<String>? notationHistory,
    int? carromCoinsA,
    int? carromCoinsB,
    bool? queenCovered,
  }) {
    return BoardBasedScore(
      matchPointsA: matchPointsA ?? this.matchPointsA,
      matchPointsB: matchPointsB ?? this.matchPointsB,
      boardNumber: boardNumber ?? this.boardNumber,
      timeRemainingSecondsA:
          timeRemainingSecondsA ?? this.timeRemainingSecondsA,
      timeRemainingSecondsB:
          timeRemainingSecondsB ?? this.timeRemainingSecondsB,
      isClockRunning: isClockRunning ?? this.isClockRunning,
      activeTurn: activeTurn ?? this.activeTurn,
      statusDetail: statusDetail ?? this.statusDetail,
      movesCount: movesCount ?? this.movesCount,
      notationHistory: notationHistory ?? this.notationHistory,
      carromCoinsA: carromCoinsA ?? this.carromCoinsA,
      carromCoinsB: carromCoinsB ?? this.carromCoinsB,
      queenCovered: queenCovered ?? this.queenCovered,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'matchPointsA': matchPointsA,
      'matchPointsB': matchPointsB,
      'boardNumber': boardNumber,
      'timeRemainingSecondsA': timeRemainingSecondsA,
      'timeRemainingSecondsB': timeRemainingSecondsB,
      'isClockRunning': isClockRunning,
      'activeTurn': activeTurn,
      'statusDetail': statusDetail,
      'movesCount': movesCount,
      'notationHistory': notationHistory,
      'carromCoinsA': carromCoinsA,
      'carromCoinsB': carromCoinsB,
      'queenCovered': queenCovered,
    };
  }

  factory BoardBasedScore.fromJson(Map<String, dynamic> json) {
    return BoardBasedScore(
      matchPointsA: (json['matchPointsA'] as num?)?.toDouble() ?? 0.0,
      matchPointsB: (json['matchPointsB'] as num?)?.toDouble() ?? 0.0,
      boardNumber: (json['boardNumber'] as num?)?.toInt() ?? 1,
      timeRemainingSecondsA:
          (json['timeRemainingSecondsA'] as num?)?.toInt() ?? 600,
      timeRemainingSecondsB:
          (json['timeRemainingSecondsB'] as num?)?.toInt() ?? 600,
      isClockRunning: json['isClockRunning'] as bool? ?? false,
      activeTurn: json['activeTurn'] as String? ?? 'PLAYER_A',
      statusDetail: json['statusDetail'] as String? ?? 'In Progress',
      movesCount: (json['movesCount'] as num?)?.toInt() ?? 0,
      notationHistory: (json['notationHistory'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      carromCoinsA: (json['carromCoinsA'] as num?)?.toInt() ?? 0,
      carromCoinsB: (json['carromCoinsB'] as num?)?.toInt() ?? 0,
      queenCovered: json['queenCovered'] as bool? ?? false,
    );
  }
}
