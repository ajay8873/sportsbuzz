import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/matches/models/match_model.dart';
import '../../features/matches/models/match_status.dart';
import '../../features/matches/providers/match_providers.dart';
import '../common/status_badge.dart';

class MatchCard extends ConsumerWidget {
  final MatchModel match;
  final String? sportName;

  const MatchCard({
    super.key,
    required this.match,
    this.sportName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamParams = MatchStreamParams(
      matchId: match.id,
      status: match.status,
      enableVideoSyncDelay: false,
    );
    final matchStateAsync =
        ref.watch(liveMatchStateStreamProvider(streamParams));

    final timeFormat = DateFormat('h:mm a, EEE');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/match/${match.id}'),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Sport Name Badge, Stage & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (sportName != null && sportName!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.activity,
                                    size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  sportName!.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.trophy,
                                  size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  match.stage ?? 'Fixture',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: match.status, compact: true),
                ],
              ),
              const Divider(height: 20),

              // Teams & Live Score Display
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.teamA,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'vs',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          match.teamB,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dynamic live summary pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: match.status == MatchStatus.live
                          ? AppColors.primarySurface
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: match.status == MatchStatus.live
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (match.status == MatchStatus.live) ...[
                          Text(
                            matchStateAsync.valueOrNull?.currentScore
                                    .displaySummary ??
                                'Live Scoring',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ] else if (match.status == MatchStatus.scheduled) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.clock,
                                  size: 12, color: AppColors.scheduledAmber),
                              const SizedBox(width: 4),
                              Text(
                                timeFormat.format(match.scheduledTime),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            matchStateAsync.valueOrNull?.currentScore
                                    .displaySummary ??
                                'Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.completedGreen,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Footer: Venue & Watch Live Action
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            match.venue ?? 'Campus Arena',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (match.streamUrl != null &&
                          match.streamUrl!.isNotEmpty) ...[
                        const Icon(LucideIcons.video,
                            size: 13, color: AppColors.liveRed),
                        const SizedBox(width: 4),
                        const Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.liveRed,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Text(
                        'View Arena',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.arrowRight,
                          size: 14, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
