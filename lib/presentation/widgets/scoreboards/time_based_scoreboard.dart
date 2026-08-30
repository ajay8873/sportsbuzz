import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/matches/models/sport_score.dart';

class TimeBasedScoreboard extends StatelessWidget {
  final TimeBasedScore score;
  final String teamA;
  final String teamB;

  const TimeBasedScoreboard({
    super.key,
    required this.score,
    required this.teamA,
    required this.teamB,
  });

  @override
  Widget build(BuildContext context) {
    final teamABonus = score.teamAFouls >= 5;
    final teamBBonus = score.teamBFouls >= 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    score.period.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      score.isClockRunning
                          ? LucideIcons.timer
                          : LucideIcons.timerOff,
                      size: 16,
                      color: score.isClockRunning
                          ? AppColors.completedGreen
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      score.formattedClock,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Big Goals / Points Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        teamA,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${score.teamAScore}',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (score.teamAYellowCards > 0)
                            _ViewerCardBadge(
                              count: score.teamAYellowCards,
                              color: Colors.amber.shade600,
                              label: 'YC',
                            ),
                          if (score.teamARedCards > 0)
                            _ViewerCardBadge(
                              count: score.teamARedCards,
                              color: AppColors.liveRed,
                              label: 'RC',
                            ),
                          Text(
                            'Fouls: ${score.teamAFouls}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (teamABonus)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade800,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BONUS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        teamB,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${score.teamBScore}',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (score.teamBYellowCards > 0)
                            _ViewerCardBadge(
                              count: score.teamBYellowCards,
                              color: Colors.amber.shade600,
                              label: 'YC',
                            ),
                          if (score.teamBRedCards > 0)
                            _ViewerCardBadge(
                              count: score.teamBRedCards,
                              color: AppColors.liveRed,
                              label: 'RC',
                            ),
                          Text(
                            'Fouls: ${score.teamBFouls}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (teamBBonus)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade800,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BONUS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (score.timeline.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'MATCH TIMELINE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: score.timeline.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final evt = score.timeline[index];
                  final minutes = evt.timestampSeconds ~/ 60;
                  final isYellow = evt.eventType == 'YELLOW_CARD';
                  final isRed = evt.eventType == 'RED_CARD';
                  final isGoal = evt.eventType.contains('GOAL') ||
                      evt.eventType.contains('POINT');

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            "$minutes'",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isYellow)
                          Container(
                            width: 12,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade600,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.shade600.withValues(alpha: 0.3),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          )
                        else if (isRed)
                          Container(
                            width: 12,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.liveRed,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.liveRed.withValues(alpha: 0.3),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          )
                        else if (isGoal)
                          const Icon(LucideIcons.goal,
                              size: 16, color: AppColors.completedGreen)
                        else
                          const Icon(LucideIcons.activity,
                              size: 15, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isYellow
                                ? 'Yellow Card: ${evt.playerName ?? (evt.team == "TEAM_A" ? teamA : teamB)}'
                                : isRed
                                    ? 'Red Card: ${evt.playerName ?? (evt.team == "TEAM_A" ? teamA : teamB)}'
                                    : '${evt.eventType} - ${evt.playerName ?? (evt.team == "TEAM_A" ? teamA : teamB)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isRed
                                  ? AppColors.liveRed
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ViewerCardBadge extends StatelessWidget {
  final int count;
  final Color color;
  final String label;

  const _ViewerCardBadge({
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
