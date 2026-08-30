import 'sport_score.dart';

class MatchStateModel {
  final String id;
  final String matchId;
  final SportScore currentScore;
  final DateTime? updatedAt;

  const MatchStateModel({
    required this.id,
    required this.matchId,
    required this.currentScore,
    this.updatedAt,
  });

  MatchStateModel copyWith({
    String? id,
    String? matchId,
    SportScore? currentScore,
    DateTime? updatedAt,
  }) {
    return MatchStateModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      currentScore: currentScore ?? this.currentScore,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'current_score': currentScore.toJson(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory MatchStateModel.fromJson(Map<String, dynamic> json) {
    return MatchStateModel(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      currentScore: SportScore.fromJson(
          json['current_score'] as Map<String, dynamic>? ?? {}),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
