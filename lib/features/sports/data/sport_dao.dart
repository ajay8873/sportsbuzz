import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/sport_model.dart';
import '../models/sport_category.dart';
import '../models/scoring_model.dart';

class SportDao {
  static final List<SportModel> _mockSports = [
    SportModel(
      id: 's_cricket_001',
      eventId: 'e_plexus_2026',
      name: 'Cricket',
      category: SportCategory.outdoor,
      scoringModel: ScoringModel.runBased,
      iconName: 'trophy',
      createdAt: DateTime.now(),
    ),
    SportModel(
      id: 's_volleyball_001',
      eventId: 'e_plexus_2026',
      name: 'Volleyball',
      category: SportCategory.outdoor,
      scoringModel: ScoringModel.setBased,
      iconName: 'shield',
      createdAt: DateTime.now(),
    ),
    SportModel(
      id: 's_football_001',
      eventId: 'e_plexus_2026',
      name: 'Football',
      category: SportCategory.outdoor,
      scoringModel: ScoringModel.timeBased,
      iconName: 'activity',
      createdAt: DateTime.now(),
    ),
    SportModel(
      id: 's_badminton_001',
      eventId: 'e_plexus_2026',
      name: 'Badminton',
      category: SportCategory.indoor,
      scoringModel: ScoringModel.setBased,
      iconName: 'activity',
      createdAt: DateTime.now(),
    ),
    SportModel(
      id: 's_chess_001',
      eventId: 'e_plexus_2026',
      name: 'Chess',
      category: SportCategory.indoor,
      scoringModel: ScoringModel.boardBased,
      iconName: 'crown',
      createdAt: DateTime.now(),
    ),
  ];

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
        return SportModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase createSport error: $e');
      }
    }
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
