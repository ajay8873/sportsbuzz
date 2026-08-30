class EventModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String shareSlug;
  final String? description;
  final String? venue;
  final DateTime? createdAt;

  const EventModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.shareSlug,
    this.description,
    this.venue,
    this.createdAt,
  });

  EventModel copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? shareSlug,
    String? description,
    String? venue,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      shareSlug: shareSlug ?? this.shareSlug,
      description: description ?? this.description,
      venue: venue ?? this.venue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'share_slug': shareSlug,
      if (description != null) 'description': description,
      if (venue != null) 'venue': venue,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      shareSlug: json['share_slug'] as String,
      description: json['description'] as String?,
      venue: json['venue'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
