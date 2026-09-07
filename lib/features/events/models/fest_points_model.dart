class FestPointsEntry {
  final String id;
  final String eventId;
  final String? sportId; // null or 'all' for overall, or sport ID
  final String? sportName; // e.g. "Volleyball", "Cricket", or "All Sports"
  final String contenderType; // 'team', 'batch', 'individual', 'house'
  final String name;
  final String? category; // e.g. "Group A", "Finals Pool"
  final int played; // P
  final int won; // W
  final int lost; // L / Defeat
  final int drawn; // D / Tie
  final int points; // PTS
  final int gold; // legacy fallback
  final int silver; // legacy fallback
  final int bronze; // legacy fallback
  final DateTime? updatedAt;

  const FestPointsEntry({
    required this.id,
    required this.eventId,
    this.sportId,
    this.sportName,
    required this.contenderType,
    required this.name,
    this.category,
    this.played = 0,
    this.won = 0,
    this.lost = 0,
    this.drawn = 0,
    this.points = 0,
    this.gold = 0,
    this.silver = 0,
    this.bronze = 0,
    this.updatedAt,
  });

  FestPointsEntry copyWith({
    String? id,
    String? eventId,
    String? sportId,
    String? sportName,
    String? contenderType,
    String? name,
    String? category,
    int? played,
    int? won,
    int? lost,
    int? drawn,
    int? points,
    int? gold,
    int? silver,
    int? bronze,
    DateTime? updatedAt,
  }) {
    return FestPointsEntry(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      sportId: sportId ?? this.sportId,
      sportName: sportName ?? this.sportName,
      contenderType: contenderType ?? this.contenderType,
      name: name ?? this.name,
      category: category ?? this.category,
      played: played ?? this.played,
      won: won ?? this.won,
      lost: lost ?? this.lost,
      drawn: drawn ?? this.drawn,
      points: points ?? this.points,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      bronze: bronze ?? this.bronze,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      if (sportId != null) 'sport_id': sportId,
      if (sportName != null) 'sport_name': sportName,
      'contender_type': contenderType,
      'name': name,
      if (category != null) 'category': category,
      'played': played,
      'won': won,
      'lost': lost,
      'drawn': drawn,
      'points': points,
      'gold': gold,
      'silver': silver,
      'bronze': bronze,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory FestPointsEntry.fromJson(Map<String, dynamic> json) {
    return FestPointsEntry(
      id: json['id'] as String? ?? '',
      eventId: json['event_id'] as String? ?? '',
      sportId: json['sport_id'] as String?,
      sportName: json['sport_name'] as String?,
      contenderType:
          (json['contender_type'] as String?)?.toLowerCase() ?? 'batch',
      name: json['name'] as String? ?? 'Unnamed Contender',
      category: json['category'] as String?,
      played: (json['played'] as num?)?.toInt() ?? 0,
      won: (json['won'] as num?)?.toInt() ?? 0,
      lost: (json['lost'] as num?)?.toInt() ?? 0,
      drawn: (json['drawn'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      gold: (json['gold'] as num?)?.toInt() ?? 0,
      silver: (json['silver'] as num?)?.toInt() ?? 0,
      bronze: (json['bronze'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
