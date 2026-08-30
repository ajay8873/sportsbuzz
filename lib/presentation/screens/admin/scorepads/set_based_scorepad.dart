import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/models/sport_score.dart';

class SetBasedScorepad extends StatelessWidget {
  final SetBasedScore score;
  final String teamAName;
  final String teamBName;
  final ValueChanged<SetBasedScore> onScoreChanged;

  const SetBasedScorepad({
    super.key,
    required this.score,
    required this.teamAName,
    required this.teamBName,
    required this.onScoreChanged,
  });

  void _addPoint(String team, int delta) {
    int nextA = score.currentSetPointsA;
    int nextB = score.currentSetPointsB;

    if (team == 'TEAM_A') {
      nextA = (nextA + delta).clamp(0, 99);
    } else {
      nextB = (nextB + delta).clamp(0, 99);
    }

    // Deuce threshold (20 for Badminton/Table Tennis, 24 for Volleyball)
    bool isDeuce = false;
    String? advantageTeam;

    if (nextA >= 20 && nextB >= 20) {
      if (nextA == nextB) {
        isDeuce = true;
        advantageTeam = null;
      } else if (nextA == nextB + 1) {
        isDeuce = false;
        advantageTeam = 'TEAM_A';
      } else if (nextB == nextA + 1) {
        isDeuce = false;
        advantageTeam = 'TEAM_B';
      }
    }

    onScoreChanged(
      score.copyWith(
        currentSetPointsA: nextA,
        currentSetPointsB: nextB,
        isDeuce: isDeuce,
        advantageTeam: advantageTeam,
        // When a team scores, serve stays or can shift
        servingTeam: team,
      ),
    );
  }

  void _winSet(BuildContext context, String winningTeam) {
    final diff = (score.currentSetPointsA - score.currentSetPointsB).abs();
    if ((score.currentSetPointsA >= 20 || score.currentSetPointsB >= 20) &&
        diff < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rule Check: In Deuce/Advantage, a team must lead by at least 2 clear points to win the set.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.liveRed,
        ),
      );
      return;
    }

    final completedSets = List<SetScoreDetail>.from(score.completedSets);
    completedSets.add(
      SetScoreDetail(
        setNumber: score.currentSetNumber,
        scoreA: score.currentSetPointsA,
        scoreB: score.currentSetPointsB,
        winner: winningTeam,
      ),
    );

    final setsWonA =
        winningTeam == 'TEAM_A' ? score.setsWonA + 1 : score.setsWonA;
    final setsWonB =
        winningTeam == 'TEAM_B' ? score.setsWonB + 1 : score.setsWonB;

    onScoreChanged(
      score.copyWith(
        setsWonA: setsWonA,
        setsWonB: setsWonB,
        currentSetNumber: score.currentSetNumber + 1,
        currentSetPointsA: 0,
        currentSetPointsB: 0,
        completedSets: completedSets,
        isDeuce: false,
        advantageTeam: null,
      ),
    );
  }

  void _toggleServing() {
    final nextServe = score.servingTeam == 'TEAM_A' ? 'TEAM_B' : 'TEAM_A';
    onScoreChanged(score.copyWith(servingTeam: nextServe));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Deuce / Advantage Banner
        if (score.isDeuce) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.scale, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'DEUCE (TIEBREAK) — 2 CLEAR POINTS TO WIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ] else if (score.advantageTeam != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.zap, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'ADVANTAGE: ${score.advantageTeam == 'TEAM_A' ? teamAName : teamBName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Set Header Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Change Match Sets Format'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [1, 3, 5, 7, 9].map((sets) {
                                return ListTile(
                                  title: Text(
                                    sets == 1
                                        ? '1 Single Set (Sudden Death)'
                                        : 'Best of $sets Sets (First to ${(sets / 2).ceil()} wins)',
                                  ),
                                  trailing: score.maxSets == sets
                                      ? const Icon(LucideIcons.check,
                                          color: AppColors.primary)
                                      : null,
                                  onTap: () {
                                    onScoreChanged(
                                        score.copyWith(maxSets: sets));
                                    Navigator.of(ctx).pop();
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SET ${score.currentSetNumber} OF ${score.maxSets}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(LucideIcons.chevronDown,
                                size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sets Won: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${score.setsWonA} - ${score.setsWonB}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Serve Indicator
                OutlinedButton.icon(
                  onPressed: _toggleServing,
                  icon: const Icon(LucideIcons.repeat, size: 14),
                  label: Text(
                    score.servingTeam == 'TEAM_A'
                        ? '$teamAName Serves'
                        : '$teamBName Serves',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),

                // Main Point Scoreboard
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            teamAName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${score.currentSetPointsA}',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            teamBName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${score.currentSetPointsB}',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (score.completedSets.isNotEmpty) ...[
                  const Divider(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: score.completedSets.map((s) {
                      return Chip(
                        label: Text(
                          'Set ${s.setNumber}: ${s.scoreA}-${s.scoreB}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: AppColors.surfaceAlt,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons Row (Stacked for responsive mobile use)
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _addPoint('TEAM_A', 1),
                child: Text(
                  '+1 Pt $teamAName',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _addPoint('TEAM_B', 1),
                child: Text(
                  '+1 Pt $teamBName',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addPoint('TEAM_A', -1),
                child: const Text('-1 Pt'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addPoint('TEAM_B', -1),
                child: const Text('-1 Pt'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.completedGreen.withAlpha(40),
                  foregroundColor: AppColors.completedGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _winSet(context, 'TEAM_A'),
                child: const Text(
                  'Win Set A',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.completedGreen.withAlpha(40),
                  foregroundColor: AppColors.completedGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _winSet(context, 'TEAM_B'),
                child: const Text(
                  'Win Set B',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
