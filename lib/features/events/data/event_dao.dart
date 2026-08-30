import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/event_model.dart';
import '../../sports/models/sport_model.dart';
import '../../sports/models/sport_category.dart';
import '../../sports/models/scoring_model.dart';
import '../../matches/models/match_model.dart';
import '../../matches/models/match_status.dart';
import '../../matches/models/sport_score.dart';

class EventDao {
  static const String defaultPlexusId = '00000000-0000-0000-0000-000000000001';
  static const String defaultCricketId = '00000000-0000-0000-0000-000000000011';
  static const String defaultVolleyballId = '00000000-0000-0000-0000-000000000012';
  static const String defaultCricketMatchId = '00000000-0000-0000-0000-000000000021';
  static const String defaultVolleyballMatchId = '00000000-0000-0000-0000-000000000022';

  // In-memory dataset for offline/in-app fallback
  static final List<EventModel> _mockEvents = [
    EventModel(
      id: defaultPlexusId,
      name: 'PLEXUS 2026 Sports Fest',
      shareSlug: 'plexus-2026',
      venue: 'Main University Stadium & Indoor Complex',
      description: 'Annual Inter-Department Sports Championship & Fest',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 4)),
      createdAt: DateTime.now(),
    ),
  ];

  static bool _hasAttemptedAutoSeed = false;

  Future<void> _seedDefaultPlexusIfEmpty(SupabaseClient client) async {
    if (_hasAttemptedAutoSeed) return;
    _hasAttemptedAutoSeed = true;
    try {
      final existing = await client.from('events').select('id').limit(1);
      if ((existing as List).isEmpty) {
        final event = _mockEvents.first;
        await client.from('events').insert(event.toJson());

        final cricket = SportModel(
          id: defaultCricketId,
          eventId: defaultPlexusId,
          name: 'Cricket',
          category: SportCategory.outdoor,
          scoringModel: ScoringModel.runBased,
          iconName: 'trophy',
          createdAt: DateTime.now(),
        );
        final volleyball = SportModel(
          id: defaultVolleyballId,
          eventId: defaultPlexusId,
          name: 'Volleyball',
          category: SportCategory.outdoor,
          scoringModel: ScoringModel.setBased,
          iconName: 'shield',
          createdAt: DateTime.now(),
        );
        await client.from('sports').insert([cricket.toJson(), volleyball.toJson()]);

        final match1 = MatchModel(
          id: defaultCricketMatchId,
          sportId: defaultCricketId,
          title: 'Dept of CS vs Dept of ME',
          teamA: 'Dept of CS',
          teamB: 'Dept of ME',
          status: MatchStatus.scheduled,
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          venue: 'Main Ground Pitch 1',
          stage: 'League Match',
          createdAt: DateTime.now(),
        );
        final match2 = MatchModel(
          id: defaultVolleyballMatchId,
          sportId: defaultVolleyballId,
          title: 'Batch 2023 vs Batch 2024',
          teamA: 'Batch 2023',
          teamB: 'Batch 2024',
          status: MatchStatus.scheduled,
          scheduledTime: DateTime.now().add(const Duration(hours: 3)),
          venue: 'Volleyball Court A',
          stage: 'Semi-Final',
          createdAt: DateTime.now(),
        );
        await client.from('matches').insert([match1.toJson(), match2.toJson()]);

        await client.from('match_state').insert([
          {
            'id': const Uuid().v4(),
            'match_id': defaultCricketMatchId,
            'current_score': SportScore.createInitial(ScoringModel.runBased, sportName: 'Cricket').toJson(),
          },
          {
            'id': const Uuid().v4(),
            'match_id': defaultVolleyballMatchId,
            'current_score': SportScore.createInitial(ScoringModel.setBased, sportName: 'Volleyball').toJson(),
          }
        ]);
        debugPrint('Successfully seeded initial PLEXUS 2026 fest into Supabase');
      }
    } catch (e) {
      debugPrint('Auto-seed error: $e');
    }
  }

  Future<List<EventModel>> getEvents() async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await _seedDefaultPlexusIfEmpty(client);
        final response = await client
            .from('events')
            .select()
            .order('created_at', ascending: false);
        final list = (response as List<dynamic>)
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          return list;
        }
      } catch (e) {
        debugPrint('Supabase getEvents error, falling back to mock: $e');
      }
    }
    return List.unmodifiable(_mockEvents);
  }

  Future<EventModel?> getEventBySlug(String shareSlug) async {
    final cleanSlug = shareSlug.trim().toLowerCase();
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await _seedDefaultPlexusIfEmpty(client);
        final response = await client
            .from('events')
            .select()
            .ilike('share_slug', cleanSlug)
            .maybeSingle();
        if (response != null) {
          return EventModel.fromJson(response);
        }
      } catch (e) {
        debugPrint('Supabase getEventBySlug error: $e');
      }
    }
    return _mockEvents
        .where((e) => e.shareSlug.toLowerCase() == cleanSlug)
        .firstOrNull;
  }

  Future<EventModel?> getEventById(String eventId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('events')
            .select()
            .eq('id', eventId)
            .maybeSingle();
        if (response != null) {
          return EventModel.fromJson(response);
        }
      } catch (e) {
        debugPrint('Supabase getEventById error: $e');
      }
    }
    return _mockEvents.where((e) => e.id == eventId).firstOrNull;
  }

  Future<EventModel> createEvent(EventModel event) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('events')
            .insert(event.toJson())
            .select()
            .single();
        final created = EventModel.fromJson(response);
        _mockEvents.removeWhere((e) => e.id == created.id);
        _mockEvents.insert(0, created);
        return created;
      } catch (e) {
        debugPrint('Supabase createEvent error: $e');
      }
    }
    _mockEvents.removeWhere((e) => e.id == event.id);
    _mockEvents.insert(0, event);
    return event;
  }

  Future<void> deleteEvent(String eventId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client.from('events').delete().eq('id', eventId);
      } catch (e) {
        debugPrint('Supabase deleteEvent error: $e');
      }
    }
    _mockEvents.removeWhere((e) => e.id == eventId);
  }
}
