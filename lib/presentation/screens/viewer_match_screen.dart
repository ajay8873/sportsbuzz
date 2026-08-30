import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/matches/models/match_status.dart';
import '../../features/matches/models/sport_score.dart';
import '../../features/matches/providers/match_providers.dart';
import '../../features/sports/providers/sport_providers.dart';
import '../common/empty_state_view.dart';
import '../common/status_badge.dart';
import '../widgets/video_player_embed.dart';
import '../widgets/scoreboards/run_based_scoreboard.dart';
import '../widgets/scoreboards/time_based_scoreboard.dart';
import '../widgets/scoreboards/set_based_scoreboard.dart';
import '../widgets/scoreboards/board_based_scoreboard.dart';
import '../widgets/scoreboards/match_based_scoreboard.dart';

import '../../../core/utils/share_util.dart';

class ViewerMatchScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ViewerMatchScreen({super.key, required this.matchId});

  @override
  ConsumerState<ViewerMatchScreen> createState() => _ViewerMatchScreenState();
}

class _ViewerMatchScreenState extends ConsumerState<ViewerMatchScreen> {
  bool _enableVideoSyncDelay = false;

  void _copyMatchLink() {
    final link = ShareUtil.getMatchShareUrl(widget.matchId);
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Match link copied: $link')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
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
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(
          matchAsync.valueOrNull?.title ?? 'Live Match Arena',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2),
            tooltip: 'Share Match',
            onPressed: _copyMatchLink,
          ),
          IconButton(
            icon: const Icon(LucideIcons.shieldCheck),
            tooltip: 'Scorer Controller',
            onPressed: () =>
                context.push('/admin/matches/${widget.matchId}/score'),
          ),
        ],
      ),
      body: matchAsync.when(
        data: (match) {
          if (match == null) {
            return const EmptyStateView(
              title: 'Match Not Found',
              message: 'This match fixture is not available.',
            );
          }

          final sportAsync = ref.watch(sportByIdProvider(match.sportId));
          final sport = sportAsync.valueOrNull;

          final streamParams = MatchStreamParams(
            matchId: widget.matchId,
            status: match.status,
            isScorer: false,
            enableVideoSyncDelay: _enableVideoSyncDelay,
          );
          final matchStateAsync =
              ref.watch(liveMatchStateStreamProvider(streamParams));

          final defaultScore = sport != null
              ? SportScore.createInitial(
                  sport.scoringModel,
                  sportName: sport.name,
                )
              : const TimeBasedScore();

          final score =
              matchStateAsync.valueOrNull?.currentScore ?? defaultScore;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TOP HALF: Live Video Player Embed
                    VideoPlayerEmbed(
                      streamUrl: match.streamUrl,
                      isLive: match.status == MatchStatus.live,
                    ),
                    const SizedBox(height: 16),

                    // Video Sync Delay & High Scale Status Bar
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                StatusBadge(status: match.status, compact: true),
                                if (match.venue != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.mapPin,
                                          size: 13,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        match.venue!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // Video Sync Delay Toggle
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Tooltip(
                                  message:
                                      'Buffers score text by 6 seconds so text matches YouTube Live video delay.',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.hourglass,
                                          size: 14, color: AppColors.textMuted),
                                      SizedBox(width: 4),
                                      Text(
                                        'Sync Video Lag (6s)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: _enableVideoSyncDelay,
                                  onChanged: (val) {
                                    setState(() => _enableVideoSyncDelay = val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // BOTTOM HALF: Reactive Live Scoreboard
                    if (score is RunBasedScore)
                      RunBasedScoreboard(
                        score: score,
                        teamA: match.teamA,
                        teamB: match.teamB,
                      )
                    else if (score is TimeBasedScore)
                      TimeBasedScoreboard(
                        score: score,
                        teamA: match.teamA,
                        teamB: match.teamB,
                      )
                    else if (score is SetBasedScore)
                      SetBasedScoreboard(
                        score: score,
                        teamA: match.teamA,
                        teamB: match.teamB,
                      )
                    else if (score is BoardBasedScore)
                      BoardBasedScoreboard(
                        score: score,
                        teamA: match.teamA,
                        teamB: match.teamB,
                      )
                    else if (score is MatchBasedScore)
                      MatchBasedScoreboard(
                        score: score,
                        teamA: match.teamA,
                        teamB: match.teamB,
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
