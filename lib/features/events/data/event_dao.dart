import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/event_model.dart';

class EventDao {
  // In-memory dataset for offline/in-app fallback
  static final List<EventModel> _mockEvents = [];

  static bool _hasCleanedLegacy = false;

  Future<void> _cleanupLegacyPlexus(dynamic client) async {
    if (_hasCleanedLegacy) return;
    _hasCleanedLegacy = true;
    try {
      await client.from('events').delete().eq('share_slug', 'plexus-2026');
      _mockEvents.removeWhere((e) => e.shareSlug == 'plexus-2026');
    } catch (_) {}
  }

  Future<List<EventModel>> getEvents() async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await _cleanupLegacyPlexus(client);
        final response = await client
            .from('events')
            .select()
            .order('created_at', ascending: false);
        return (response as List<dynamic>)
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Supabase getEvents error, falling back to local: $e');
      }
    }
    return List.unmodifiable(_mockEvents);
  }

  Future<EventModel?> getEventBySlug(String shareSlug) async {
    final cleanSlug = shareSlug.trim().toLowerCase();
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
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
