import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/matches/models/match_status.dart';
import '../../../features/matches/models/sport_score.dart';
import '../../../features/matches/providers/match_providers.dart';
import '../../../features/sports/providers/sport_providers.dart';
import '../../common/empty_state_view.dart';
import '../../common/status_badge.dart';
import 'dialogs/stream_config_dialog.dart';
import 'scorepads/run_based_scorepad.dart';
import 'scorepads/time_based_scorepad.dart';
import 'scorepads/set_based_scorepad.dart';
import 'scorepads/board_based_scorepad.dart';
import 'scorepads/match_based_scorepad.dart';
import '../../../features/events/providers/event_providers.dart';
import '../../../core/services/admin_auth_service.dart';

class AdminScoringScreen extends ConsumerStatefulWidget {
  final String matchId;

  const AdminScoringScreen({super.key, required this.matchId});

  @override
  ConsumerState<AdminScoringScreen> createState() => _AdminScoringScreenState();
}

class _AdminScoringScreenState extends ConsumerState<AdminScoringScreen> {
  SportScore? _localScore;

  Future<void> _updateStatus(MatchStatus newStatus) async {
    final matchDao = ref.read(matchDaoProvider);
    await matchDao.updateMatchStatus(widget.matchId, newStatus);
    ref.invalidate(matchByIdProvider(widget.matchId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match status updated to ${newStatus.label}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _pushScoreChange(SportScore newScore) async {
    setState(() => _localScore = newScore);
    final stateDao = ref.read(matchStateDaoProvider);
    await stateDao.updateScore(
      matchId: widget.matchId,
      newScore: newScore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin'),
        ),
        title: const Row(
          children: [
            Icon(LucideIcons.gamepad2, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Live Scorer Controller'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.video),
            tooltip: 'Configure Live Stream URL',
            onPressed: () {
              final match = matchAsync.valueOrNull;
              showDialog(
                context: context,
                builder: (_) => StreamConfigDialog(
                  matchId: widget.matchId,
                  initialStreamUrl: match?.streamUrl,
                ),
              );
            },
          ),
        ],
      ),
      body: matchAsync.when(
        data: (match) {
          if (match == null) {
            return const EmptyStateView(
              title: 'Match Not Found',
              message: 'The requested fixture could not be located.',
            );
          }

          final sportAsync = ref.watch(sportByIdProvider(match.sportId));
          final sport = sportAsync.valueOrNull;

          if (sport != null && !ref.watch(unlockedEventsProvider).contains(sport.eventId)) {
            final eventAsync = ref.watch(eventByIdProvider(sport.eventId));
            final event = eventAsync.valueOrNull;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.lock,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scorer Passcode Required',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 4-digit PIN for this tournament to unlock live scoring controls for "${match.title}".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(LucideIcons.keyRound, size: 18),
                      label: const Text('Enter Organizer / Scorer PIN'),
                      onPressed: () {
                        if (event != null) {
                          AdminAuthService.promptPin(
                            context: context,
                            ref: ref,
                            event: event,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          final streamParams = MatchStreamParams(
            matchId: widget.matchId,
            status: match.status,
            isScorer: true,
            enableVideoSyncDelay: false,
          );
          final stateStreamAsync =
              ref.watch(liveMatchStateStreamProvider(streamParams));

          final defaultScore = sport != null
              ? SportScore.createInitial(
                  sport.scoringModel,
                  sportName: sport.name,
                )
              : const TimeBasedScore();

          final currentScore = _localScore ??
              stateStreamAsync.valueOrNull?.currentScore ??
              defaultScore;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status & Transition Control Banner
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StatusBadge(status: match.status),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        match.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      if (match.stage != null)
                                        Text(
                                          match.stage!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (match.status == MatchStatus.scheduled)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.liveRed,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(LucideIcons.radio,
                                        size: 16),
                                    label:
                                        const Text('Start Match (Go Live)'),
                                    onPressed: () =>
                                        _updateStatus(MatchStatus.live),
                                  ),
                                if (match.status == MatchStatus.live)
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          AppColors.completedGreen,
                                      side: const BorderSide(
                                          color: AppColors.completedGreen),
                                    ),
                                    icon: const Icon(LucideIcons.checkCircle2,
                                        size: 16),
                                    label:
                                        const Text('End Match / Complete'),
                                    onPressed: () =>
                                        _updateStatus(MatchStatus.completed),
                                  ),
                                if (match.status == MatchStatus.completed)
                                  OutlinedButton.icon(
                                    icon: const Icon(LucideIcons.rotateCcw,
                                        size: 14),
                                    label: const Text('Reopen (Live)'),
                                    onPressed: () =>
                                        _updateStatus(MatchStatus.live),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Scorepad based on score type
                    if (currentScore is RunBasedScore)
                      RunBasedScorepad(
                        score: currentScore,
                        onScoreChanged: _pushScoreChange,
                      )
                    else if (currentScore is TimeBasedScore)
                      TimeBasedScorepad(
                        score: currentScore,
                        teamAName: match.teamA,
                        teamBName: match.teamB,
                        onScoreChanged: _pushScoreChange,
                      )
                    else if (currentScore is SetBasedScore)
                      SetBasedScorepad(
                        score: currentScore,
                        teamAName: match.teamA,
                        teamBName: match.teamB,
                        onScoreChanged: _pushScoreChange,
                      )
                    else if (currentScore is BoardBasedScore)
                      BoardBasedScorepad(
                        score: currentScore,
                        playerAName: match.teamA,
                        playerBName: match.teamB,
                        onScoreChanged: _pushScoreChange,
                      )
                    else if (currentScore is MatchBasedScore)
                      MatchBasedScorepad(
                        score: currentScore,
                        teamAName: match.teamA,
                        teamBName: match.teamB,
                        onScoreChanged: _pushScoreChange,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading match: $err')),
      ),
    );
  }
}
