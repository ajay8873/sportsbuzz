class EventModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String shareSlug;
  final String? description;
  final String? venue;
  final String? adminPin;
  final DateTime? createdAt;

  const EventModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.shareSlug,
    this.description,
    this.venue,
    this.adminPin,
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
    String? adminPin,
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
      adminPin: adminPin ?? this.adminPin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    String? combinedDesc = description;
    if (adminPin != null && adminPin!.isNotEmpty) {
      combinedDesc = (description != null && description!.isNotEmpty)
          ? '$description [pin:$adminPin]'
          : '[pin:$adminPin]';
    }
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'share_slug': shareSlug,
      if (combinedDesc != null) 'description': combinedDesc,
      if (venue != null) 'venue': venue,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawDesc = json['description'] as String?;
    String? pin = json['admin_pin'] as String?;
    String? cleanDesc = rawDesc;

    if (rawDesc != null && rawDesc.contains('[pin:')) {
      final match = RegExp(r'\[pin:([^\]]+)\]').firstMatch(rawDesc);
      if (match != null) {
        pin = match.group(1);
        cleanDesc = rawDesc.replaceAll(RegExp(r'\s*\[pin:[^\]]+\]'), '').trim();
        if (cleanDesc.isEmpty) cleanDesc = null;
      }
    }

    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      shareSlug: json['share_slug'] as String,
      description: cleanDesc,
      venue: json['venue'] as String?,
      adminPin: pin,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
