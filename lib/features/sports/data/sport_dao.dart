import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/sport_model.dart';
import '../models/sport_category.dart';
import '../models/scoring_model.dart';

class SportDao {
  static final List<SportModel> _mockSports = [];

  Future<List<SportModel>> getSportsByEvent(String eventId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('sports')
            .select()
            .eq('event_id', eventId)
            .order('created_at', ascending: true);
        return (response as List<dynamic>)
            .map((json) => SportModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Supabase getSportsByEvent error: $e');
      }
    }
    return _mockSports.where((s) => s.eventId == eventId).toList();
  }

  Future<SportModel?> getSportById(String sportId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('sports')
            .select()
            .eq('id', sportId)
            .maybeSingle();
        if (response != null) {
          return SportModel.fromJson(response);
        }
      } catch (e) {
        debugPrint('Supabase getSportById error: $e');
      }
    }
    return _mockSports.where((s) => s.id == sportId).firstOrNull;
  }

  Future<SportModel> createSport(SportModel sport) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('sports')
            .insert(sport.toJson())
            .select()
            .single();
        final created = SportModel.fromJson(response);
        _mockSports.removeWhere((s) => s.id == created.id);
        _mockSports.add(created);
        return created;
      } catch (e) {
        debugPrint('Supabase createSport error: $e');
      }
    }
    _mockSports.removeWhere((s) => s.id == sport.id);
    _mockSports.add(sport);
    return sport;
  }

  Future<void> deleteSport(String sportId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client.from('sports').delete().eq('id', sportId);
      } catch (e) {
        debugPrint('Supabase deleteSport error: $e');
      }
    }
    _mockSports.removeWhere((s) => s.id == sportId);
  }
}
