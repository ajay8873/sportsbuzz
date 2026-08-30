import 'match_status.dart';

class MatchModel {
  final String id;
  final String sportId;
  final String title;
  final String teamA;
  final String teamB;
  final MatchStatus status;
  final DateTime scheduledTime;
  final String? streamUrl;
  final String? venue;
  final String? stage; // Final, Semi-Final, League Match, Round 1
  final DateTime? createdAt;

  const MatchModel({
    required this.id,
    required this.sportId,
    required this.title,
    required this.teamA,
    required this.teamB,
    required this.status,
    required this.scheduledTime,
    this.streamUrl,
    this.venue,
    this.stage,
    this.createdAt,
  });

  MatchModel copyWith({
    String? id,
    String? sportId,
    String? title,
    String? teamA,
    String? teamB,
    MatchStatus? status,
    DateTime? scheduledTime,
    String? streamUrl,
    String? venue,
    String? stage,
    DateTime? createdAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      title: title ?? this.title,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      streamUrl: streamUrl ?? this.streamUrl,
      venue: venue ?? this.venue,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sport_id': sportId,
      'title': title,
      'team_a': teamA,
      'team_b': teamB,
      'status': status.dbValue,
      'scheduled_time': scheduledTime.toIso8601String(),
      if (streamUrl != null) 'stream_url': streamUrl,
      if (venue != null) 'venue': venue,
      if (stage != null) 'stage': stage,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      sportId: json['sport_id'] as String,
      title: json['title'] as String,
      teamA: json['team_a'] as String? ?? (json['title'] as String).split(' vs ').first,
      teamB: json['team_b'] as String? ?? ((json['title'] as String).contains(' vs ') ? (json['title'] as String).split(' vs ').last : 'Opponent'),
      status: MatchStatus.fromString(json['status'] as String),
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      streamUrl: json['stream_url'] as String?,
      venue: json['venue'] as String?,
      stage: json['stage'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
