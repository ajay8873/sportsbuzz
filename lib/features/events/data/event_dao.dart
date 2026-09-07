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

  Future<bool> isSlugTaken(String slug, {String? excludeEventId}) async {
    final clean = slug.trim().toLowerCase();
    if (clean.isEmpty) return false;
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        var query = client.from('events').select('id').ilike('share_slug', clean);
        if (excludeEventId != null) {
          query = query.neq('id', excludeEventId);
        }
        final list = await query;
        if ((list as List).isNotEmpty) return true;
      } catch (e) {
        debugPrint('isSlugTaken error: $e');
      }
    }
    return _mockEvents.any((e) =>
        e.shareSlug.toLowerCase() == clean &&
        (excludeEventId == null || e.id != excludeEventId));
  }

  /// Automatically ensures uniqueness of a tournament slug.
  /// If `fest-2026` is taken, checks `fest-2026-2`, `fest-2026-3`, etc.
  Future<String> resolveUniqueSlug(String desiredSlug, {String? excludeEventId}) async {
    var base = desiredSlug
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (base.isEmpty) base = 'fest';

    var candidate = base;
    int counter = 1;

    while (await isSlugTaken(candidate, excludeEventId: excludeEventId)) {
      counter++;
      candidate = '$base-$counter';
      if (counter > 100) {
        final hash = DateTime.now().millisecondsSinceEpoch.toRadixString(36).substring(4);
        candidate = '$base-$hash';
        break;
      }
    }
    return candidate;
  }

  Future<EventModel?> getEventBySlug(String shareSlug) async {
    final cleanSlug = shareSlug.trim().toLowerCase();
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        // 1. First try matching share_slug (ordered by newest to resolve duplicate conflicts cleanly)
        final response = await client
            .from('events')
            .select()
            .ilike('share_slug', cleanSlug)
            .order('created_at', ascending: false)
            .limit(1);
        if ((response as List).isNotEmpty) {
          return EventModel.fromJson(response.first);
        }

        // 2. Also try matching id directly in case UUID was provided
        final idResp = await client
            .from('events')
            .select()
            .eq('id', cleanSlug)
            .limit(1);
        if ((idResp as List).isNotEmpty) {
          return EventModel.fromJson(idResp.first);
        }
      } catch (e) {
        debugPrint('Supabase getEventBySlug error: $e');
      }
    }
    return _mockEvents.where((e) =>
        e.shareSlug.toLowerCase() == cleanSlug || e.id.toLowerCase() == cleanSlug
    ).firstOrNull;
  }

  /// Search events matching a slug, name, or code to disambiguate identical/similar tournament names
  Future<List<EventModel>> findEvents(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('events')
            .select()
            .or('share_slug.ilike.%$q%,name.ilike.%$q%')
            .order('created_at', ascending: false)
            .limit(10);
        return (response as List<dynamic>)
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Supabase findEvents error: $e');
      }
    }

    return _mockEvents.where((e) {
      return e.shareSlug.toLowerCase().contains(q) ||
          e.name.toLowerCase().contains(q) ||
          e.id.toLowerCase() == q;
    }).toList();
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

  Future<EventModel> updateEvent(EventModel updatedEvent) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('events')
            .update(updatedEvent.toJson())
            .eq('id', updatedEvent.id)
            .select()
            .single();
        final saved = EventModel.fromJson(response);
        final index = _mockEvents.indexWhere((e) => e.id == saved.id);
        if (index != -1) {
          _mockEvents[index] = saved;
        } else {
          _mockEvents.insert(0, saved);
        }
        return saved;
      } catch (e) {
        debugPrint('Supabase updateEvent error: $e');
      }
    }
    final index = _mockEvents.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _mockEvents[index] = updatedEvent;
    } else {
      _mockEvents.insert(0, updatedEvent);
    }
    return updatedEvent;
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
