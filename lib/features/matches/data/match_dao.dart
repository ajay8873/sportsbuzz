import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../events/data/event_dao.dart';
import '../models/match_model.dart';
import '../models/match_status.dart';

class MatchDao {
  static final List<MatchModel> _mockMatches = [
    MatchModel(
      id: EventDao.defaultCricketMatchId,
      sportId: EventDao.defaultCricketId,
      title: 'Dept of CS vs Dept of ME',
      teamA: 'Dept of CS',
      teamB: 'Dept of ME',
      status: MatchStatus.scheduled,
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      venue: 'Main Ground Pitch 1',
      stage: 'League Match',
      createdAt: DateTime.now(),
    ),
    MatchModel(
      id: EventDao.defaultVolleyballMatchId,
      sportId: EventDao.defaultVolleyballId,
      title: 'Batch 2023 vs Batch 2024',
      teamA: 'Batch 2023',
      teamB: 'Batch 2024',
      status: MatchStatus.scheduled,
      scheduledTime: DateTime.now().add(const Duration(hours: 3)),
      venue: 'Volleyball Court A',
      stage: 'Semi-Final',
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<MatchModel>> getMatchesBySport(String sportId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('matches')
            .select()
            .eq('sport_id', sportId)
            .order('scheduled_time', ascending: true);
        final list = (response as List<dynamic>)
            .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      } catch (e) {
        debugPrint('Supabase getMatchesBySport error: $e');
      }
    }
    return _mockMatches.where((m) => m.sportId == sportId).toList();
  }

  Future<MatchModel?> getMatchById(String matchId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('matches')
            .select()
            .eq('id', matchId)
            .maybeSingle();
        if (response != null) {
          return MatchModel.fromJson(response);
        }
      } catch (e) {
        debugPrint('Supabase getMatchById error: $e');
      }
    }
    return _mockMatches.where((m) => m.id == matchId).firstOrNull;
  }

  Future<MatchModel> createMatch(MatchModel match) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        final response = await client
            .from('matches')
            .insert(match.toJson())
            .select()
            .single();
        final created = MatchModel.fromJson(response);
        _mockMatches.removeWhere((m) => m.id == created.id);
        _mockMatches.add(created);
        return created;
      } catch (e) {
        debugPrint('Supabase createMatch error: $e');
      }
    }
    _mockMatches.removeWhere((m) => m.id == match.id);
    _mockMatches.add(match);
    return match;
  }

  Future<void> updateMatchStatus(String matchId, MatchStatus newStatus) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client
            .from('matches')
            .update({'status': newStatus.dbValue})
            .eq('id', matchId);
      } catch (e) {
        debugPrint('Supabase updateMatchStatus error: $e');
      }
    }
    final index = _mockMatches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      _mockMatches[index] = _mockMatches[index].copyWith(status: newStatus);
    }
  }

  Future<void> updateStreamUrl(String matchId, String? streamUrl) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client
            .from('matches')
            .update({'stream_url': streamUrl})
            .eq('id', matchId);
      } catch (e) {
        debugPrint('Supabase updateStreamUrl error: $e');
      }
    }
    final index = _mockMatches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      _mockMatches[index] = _mockMatches[index].copyWith(streamUrl: streamUrl);
    }
  }

  Future<void> updateMatch(MatchModel match) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client
            .from('matches')
            .update(match.toJson())
            .eq('id', match.id);
      } catch (e) {
        debugPrint('Supabase updateMatch error: $e');
      }
    }
    final index = _mockMatches.indexWhere((m) => m.id == match.id);
    if (index != -1) {
      _mockMatches[index] = match;
    }
  }

  Future<void> deleteMatch(String matchId) async {
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isInitialized) {
      try {
        await client
            .from('matches')
            .delete()
            .eq('id', matchId);
      } catch (e) {
        debugPrint('Supabase deleteMatch error: $e');
      }
    }
    _mockMatches.removeWhere((m) => m.id == matchId);
  }
}

