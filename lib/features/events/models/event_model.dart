import 'dart:convert';
import 'fest_points_model.dart';

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
  final List<FestPointsEntry> standings;

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
    this.standings = const [],
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
    List<FestPointsEntry>? standings,
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
      standings: standings ?? this.standings,
    );
  }

  Map<String, dynamic> toJson() {
    String? combinedDesc = description;
    final tags = <String>[];

    if (adminPin != null && adminPin!.isNotEmpty) {
      tags.add('[pin:$adminPin]');
    }

    if (standings.isNotEmpty) {
      final jsonStr = jsonEncode(standings.map((e) => e.toJson()).toList());
      final b64 = base64Encode(utf8.encode(jsonStr));
      tags.add('[standings:$b64]');
    }

    if (tags.isNotEmpty) {
      final tagsStr = tags.join(' ');
      combinedDesc = (description != null && description!.isNotEmpty)
          ? '$description $tagsStr'
          : tagsStr;
    }

    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'share_slug': shareSlug,
      'description': combinedDesc,
      'venue': venue,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawDesc = json['description'] as String?;
    String? pin = json['admin_pin'] as String?;
    String? cleanDesc = rawDesc;
    List<FestPointsEntry> parsedStandings = [];

    if (rawDesc != null) {
      if (rawDesc.contains('[pin:')) {
        final match = RegExp(r'\[pin:([^\]]+)\]').firstMatch(rawDesc);
        if (match != null) {
          pin = match.group(1);
          cleanDesc = cleanDesc?.replaceAll(RegExp(r'\s*\[pin:[^\]]+\]'), '').trim();
        }
      }

      if (rawDesc.contains('[standings:')) {
        final match = RegExp(r'\[standings:([^\]]+)\]').firstMatch(rawDesc);
        if (match != null) {
          final payload = match.group(1);
          if (payload != null) {
            try {
              String jsonStr;
              try {
                jsonStr = utf8.decode(base64Decode(payload));
              } catch (_) {
                jsonStr = payload;
              }
              final decoded = jsonDecode(jsonStr) as List<dynamic>;
              parsedStandings = decoded
                  .map((e) => FestPointsEntry.fromJson(e as Map<String, dynamic>))
                  .toList();
            } catch (_) {}
          }
          cleanDesc = cleanDesc?.replaceAll(RegExp(r'\s*\[standings:[^\]]+\]'), '').trim();
        }
      }

      if (cleanDesc != null && cleanDesc.isEmpty) {
        cleanDesc = null;
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
      standings: parsedStandings,
    );
  }
}
