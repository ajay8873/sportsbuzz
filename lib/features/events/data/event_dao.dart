import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/event_model.dart';

class EventDao {
  // In-memory dataset for offline/in-app created events
  static final List<EventModel> _mockEvents = [
    EventModel(
      id: 'e_plexus_2026',
      name: 'PLEXUS 2026 Sports Fest',
      shareSlug: 'plexus-2026',
      venue: 'Main University Stadium & Indoor Complex',
      description: 'Annual Inter-Department Sports Championship & Fest',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 4)),
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<EventModel>> getEvents() async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('events')
            .select()
            .order('created_at', ascending: false);
        return (response as List<dynamic>)
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Supabase getEvents error, falling back to mock: $e');
      }
    }
    return List.unmodifiable(_mockEvents);
  }

  Future<EventModel?> getEventBySlug(String shareSlug) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('events')
            .select()
            .eq('share_slug', shareSlug)
            .maybeSingle();
        if (response != null) {
          return EventModel.fromJson(response);
        }
      } catch (e) {
        debugPrint('Supabase getEventBySlug error: $e');
      }
    }
    return _mockEvents
        .where((e) => e.shareSlug.toLowerCase() == shareSlug.toLowerCase())
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
        return EventModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase createEvent error: $e');
      }
    }
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
