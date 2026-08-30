import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/models/sport_score.dart';

class MatchBasedScorepad extends StatelessWidget {
  final MatchBasedScore score;
  final String teamAName;
  final String teamBName;
  final ValueChanged<MatchBasedScore> onScoreChanged;

  const MatchBasedScorepad({
    super.key,
    required this.score,
    required this.teamAName,
    required this.teamBName,
    required this.onScoreChanged,
  });

  void _recordTugRound(String winner) {
    final newRounds = List<TugOfWarRound>.from(score.tugOfWarRounds);
    final nextRoundNum = newRounds.length + 1;
    newRounds.add(
      TugOfWarRound(
        roundNumber: nextRoundNum,
        winner: winner,
        durationSeconds: 45,
      ),
    );

    int wonA = winner == 'TEAM_A' ? score.roundsWonA + 1 : score.roundsWonA;
    int wonB = winner == 'TEAM_B' ? score.roundsWonB + 1 : score.roundsWonB;
    String? overallWinner;

    if (wonA >= 2) overallWinner = teamAName;
    if (wonB >= 2) overallWinner = teamBName;

    onScoreChanged(
      score.copyWith(
        roundsWonA: wonA,
        roundsWonB: wonB,
        tugOfWarRounds: newRounds,
        overallWinner: overallWinner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tug / Athletics Summary Card
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        score.subCategory.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (score.overallWinner != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.completedGreenSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.completedGreen
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'WINNER: ${score.overallWinner}',
                          style: const TextStyle(
                            color: AppColors.completedGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            teamAName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${score.roundsWonA}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'Pulls Won',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            teamBName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${score.roundsWonB}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'Pulls Won',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (score.tugOfWarRounds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: score.tugOfWarRounds.map((r) {
                      final winTeam =
                          r.winner == 'TEAM_A' ? teamAName : teamBName;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Round ${r.roundNumber}: Won by $winTeam',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Round Victory Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _recordTugRound('TEAM_A'),
                child: Text('Round Won by $teamAName'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _recordTugRound('TEAM_B'),
                child: Text('Round Won by $teamBName'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
