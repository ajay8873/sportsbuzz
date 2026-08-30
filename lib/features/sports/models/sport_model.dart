import 'sport_category.dart';
import 'scoring_model.dart';

class SportModel {
  final String id;
  final String eventId;
  final String name;
  final SportCategory category;
  final ScoringModel scoringModel;
  final String? iconName;
  final DateTime? createdAt;

  const SportModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.category,
    required this.scoringModel,
    this.iconName,
    this.createdAt,
  });

  SportModel copyWith({
    String? id,
    String? eventId,
    String? name,
    SportCategory? category,
    ScoringModel? scoringModel,
    String? iconName,
    DateTime? createdAt,
  }) {
    return SportModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      category: category ?? this.category,
      scoringModel: scoringModel ?? this.scoringModel,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'category': category.dbValue,
      'scoring_model': scoringModel.dbValue,
      if (iconName != null) 'icon_name': iconName,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      category: SportCategory.fromString(json['category'] as String),
      scoringModel: ScoringModel.fromString(json['scoring_model'] as String),
      iconName: json['icon_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
