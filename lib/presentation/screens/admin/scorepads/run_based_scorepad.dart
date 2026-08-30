import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/models/sport_score.dart';

class RunBasedScorepad extends StatelessWidget {
  final RunBasedScore score;
  final ValueChanged<RunBasedScore> onScoreChanged;

  const RunBasedScorepad({
    super.key,
    required this.score,
    required this.onScoreChanged,
  });

  void _addRuns(BuildContext context, int runsCount) {
    final newRecent = List<String>.from(score.recentBalls);
    newRecent.add(runsCount.toString());
    if (newRecent.length > 8) newRecent.removeAt(0);

    int nextBalls = score.balls + 1;
    double nextOvers = score.overs;
    bool swapForOverEnd = false;

    if (nextBalls >= 6) {
      nextOvers = (nextOvers.toInt() + 1).toDouble();
      nextBalls = 0;
      swapForOverEnd = true;
    } else {
      nextOvers = (nextOvers.toInt()) + (nextBalls / 10.0);
    }

    // Determine striker rotation (odd runs swap strikers, plus over end swaps strikers)
    bool isOddRuns = runsCount % 2 != 0;
    bool shouldSwap = (isOddRuns && !swapForOverEnd) || (!isOddRuns && swapForOverEnd);

    String newStriker = shouldSwap ? score.nonStriker : score.striker;
    int newStrikerRuns = shouldSwap
        ? score.nonStrikerRuns
        : (score.strikerRuns + runsCount);
    int newStrikerBalls = shouldSwap
        ? score.nonStrikerBalls
        : (score.strikerBalls + 1);

    String newNonStriker = shouldSwap ? score.striker : score.nonStriker;
    int newNonStrikerRuns = shouldSwap
        ? (score.strikerRuns + runsCount)
        : score.nonStrikerRuns;
    int newNonStrikerBalls = shouldSwap
        ? (score.strikerBalls + 1)
        : score.nonStrikerBalls;

    onScoreChanged(
      score.copyWith(
        runs: score.runs + runsCount,
        striker: newStriker,
        strikerRuns: newStrikerRuns,
        strikerBalls: newStrikerBalls,
        nonStriker: newNonStriker,
        nonStrikerRuns: newNonStrikerRuns,
        nonStrikerBalls: newNonStrikerBalls,
        bowlerRunsConceded: score.bowlerRunsConceded + runsCount,
        bowlerOvers: nextOvers,
        overs: nextOvers,
        balls: nextBalls,
        recentBalls: newRecent,
        isFreeHit: false, // Free hit is consumed on legal delivery
      ),
    );
  }

  void _addWicket(BuildContext context) {
    if (score.isFreeHit) {
      // Free hit rule: Only Run Out is valid dismissal
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: Colors.amber),
              SizedBox(width: 8),
              Text('Free Hit Active'),
            ],
          ),
          content: const Text(
            'Under MCC Cricket Rules, a batter CANNOT be dismissed Bowled, Caught, LBW, or Stumped off a Free Hit.\n\nOnly a RUN OUT is a valid dismissal on a Free Hit ball.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel (Not Out)'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.liveRed),
              onPressed: () {
                Navigator.of(ctx).pop();
                _processWicket(isRunOut: true);
              },
              child: const Text('Confirm Run Out'),
            ),
          ],
        ),
      );
      return;
    }

    _processWicket(isRunOut: false);
  }

  void _processWicket({required bool isRunOut}) {
    final newRecent = List<String>.from(score.recentBalls);
    newRecent.add(isRunOut ? 'RO' : 'W');
    if (newRecent.length > 8) newRecent.removeAt(0);

    int nextBalls = score.balls + 1;
    double nextOvers = score.overs;

    if (nextBalls >= 6) {
      nextOvers = (nextOvers.toInt() + 1).toDouble();
      nextBalls = 0;
    } else {
      nextOvers = (nextOvers.toInt()) + (nextBalls / 10.0);
    }

    onScoreChanged(
      score.copyWith(
        wickets: score.wickets + 1,
        bowlerWickets: isRunOut ? score.bowlerWickets : (score.bowlerWickets + 1),
        bowlerOvers: nextOvers,
        overs: nextOvers,
        balls: nextBalls,
        striker: 'Batter ${score.wickets + 2}',
        strikerRuns: 0,
        strikerBalls: 0,
        recentBalls: newRecent,
        isFreeHit: false,
      ),
    );
  }

  void _addExtra(String extraType) {
    final newRecent = List<String>.from(score.recentBalls);
    newRecent.add(extraType);
    if (newRecent.length > 8) newRecent.removeAt(0);

    int addRuns = 1;
    int wides = score.wides;
    int noBalls = score.noBalls;
    int byes = score.byes;
    int legByes = score.legByes;
    bool willBeFreeHit = score.isFreeHit;

    switch (extraType) {
      case 'WD':
        wides++;
        // Wide ball: does not count as legal ball, does not consume Free Hit
        break;
      case 'NB':
        noBalls++;
        // No ball rule: next ball is Free Hit, does not count as legal ball
        willBeFreeHit = true;
        break;
      case 'B':
        byes++;
        break;
      case 'LB':
        legByes++;
        break;
    }

    onScoreChanged(
      score.copyWith(
        runs: score.runs + addRuns,
        extras: score.extras + addRuns,
        wides: wides,
        noBalls: noBalls,
        byes: byes,
        legByes: legByes,
        bowlerRunsConceded: (extraType == 'WD' || extraType == 'NB')
            ? score.bowlerRunsConceded + addRuns
            : score.bowlerRunsConceded,
        recentBalls: newRecent,
        isFreeHit: willBeFreeHit,
      ),
    );
  }

  void _swapStrikers() {
    onScoreChanged(
      score.copyWith(
        striker: score.nonStriker,
        strikerRuns: score.nonStrikerRuns,
        strikerBalls: score.nonStrikerBalls,
        nonStriker: score.striker,
        nonStrikerRuns: score.strikerRuns,
        nonStrikerBalls: score.strikerBalls,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Free Hit Alert Banner
        if (score.isFreeHit) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFFF9800)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withAlpha(80),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.flame, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'FREE HIT ON NEXT BALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () =>
                      onScoreChanged(score.copyWith(isFreeHit: false)),
                  child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Score Header Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BATTING: ${score.battingTeam.toUpperCase()}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${score.runs}/${score.wickets}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 40,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '(${score.overs.toStringAsFixed(1)} Overs)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (score.target != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Target: ${score.target}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24),
                // Batters & Bowler stats row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.sparkles,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${score.striker} *',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${score.strikerRuns} (${score.strikerBalls}b)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            score.nonStriker,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${score.nonStrikerRuns} (${score.nonStrikerBalls}b)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            score.currentBowler,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${score.bowlerWickets}/${score.bowlerRunsConceded} (${score.bowlerOvers.toStringAsFixed(1)} ov)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (score.recentBalls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Recent: ',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 6),
                      Wrap(
                        spacing: 6,
                        children: score.recentBalls.map((ball) {
                          final isW = ball == 'W' || ball == 'RO';
                          final isNB = ball == 'NB';
                          final isBoundary = ball == '4' || ball == '6';
                          return Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isW
                                  ? AppColors.liveRed
                                  : isNB
                                      ? Colors.orange.shade800
                                      : isBoundary
                                          ? AppColors.primary
                                          : AppColors.surfaceAlt,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isW
                                    ? AppColors.liveRed
                                    : isNB
                                        ? Colors.orange
                                        : isBoundary
                                            ? AppColors.primary
                                            : AppColors.border,
                              ),
                            ),
                            child: Text(
                              ball,
                              style: TextStyle(
                                color: (isW || isNB || isBoundary)
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Run Controls Grid
        Text(
          'RECORD RUNS (LEGAL BALLS)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _ScorePadKey(label: '0', onTap: () => _addRuns(context, 0)),
            _ScorePadKey(label: '1', onTap: () => _addRuns(context, 1)),
            _ScorePadKey(label: '2', onTap: () => _addRuns(context, 2)),
            _ScorePadKey(label: '3', onTap: () => _addRuns(context, 3)),
            _ScorePadKey(
              label: '4',
              highlightColor: AppColors.primaryLight,
              onTap: () => _addRuns(context, 4),
            ),
            _ScorePadKey(
              label: '6',
              highlightColor: AppColors.primary,
              onTap: () => _addRuns(context, 6),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Extras & Dismissal Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.liveRed,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(LucideIcons.skull, size: 16),
                label: const Text('OUT / WICKET'),
                onPressed: () => _addWicket(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addExtra('WD'),
                child: const Text('Wide (+1)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade900,
                ),
                onPressed: () => _addExtra('NB'),
                child: const Text('No Ball (+1)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addExtra('B'),
                child: const Text('Byes (+1)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addExtra('LB'),
                child: const Text('Leg Byes (+1)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(LucideIcons.repeat, size: 14),
                label: const Text('Swap Strike'),
                onPressed: _swapStrikers,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScorePadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? highlightColor;

  const _ScorePadKey({
    required this.label,
    required this.onTap,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = highlightColor != null;
    return Material(
      color: isCustom ? highlightColor : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCustom ? Colors.transparent : AppColors.border,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isCustom ? Colors.white : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
