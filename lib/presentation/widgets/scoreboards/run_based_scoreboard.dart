import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/matches/models/sport_score.dart';

class RunBasedScoreboard extends StatefulWidget {
  final RunBasedScore score;
  final String teamA;
  final String teamB;

  const RunBasedScoreboard({
    super.key,
    required this.score,
    required this.teamA,
    required this.teamB,
  });

  @override
  State<RunBasedScoreboard> createState() => _RunBasedScoreboardState();
}

class _RunBasedScoreboardState extends State<RunBasedScoreboard> {
  bool _showFullScorecard = false;

  @override
  Widget build(BuildContext context) {
    final score = widget.score;
    final displayBattingTeam =
        score.battingTeam.isNotEmpty ? score.battingTeam : widget.teamA;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toss Banner
        if (score.tossSummary != null && score.tossSummary!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.coins, size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    score.tossSummary!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Main Live Cricket Scoreboard Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (score.isFreeHit) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.flame, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          '🔥 FREE HIT NEXT BALL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${score.innings.toUpperCase()} • BATTING: ${displayBattingTeam.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (score.target != null)
                      Text(
                        'Target: ${score.target}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Big Runs & Overs
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${score.runs}',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      '/${score.wickets}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '(${score.overs.toStringAsFixed(1)} ov)',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Batters & Bowler stats breakdown
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.sparkles,
                                  size: 13, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${score.striker} *',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${score.strikerRuns} runs (${score.strikerBalls}b)',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
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
                                fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${score.nonStrikerRuns} (${score.nonStrikerBalls}b)',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
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
                                fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${score.bowlerWickets}/${score.bowlerRunsConceded} (${score.bowlerOvers.toStringAsFixed(1)} ov)',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (score.recentBalls.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text(
                        'Recent Deliveries: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: score.recentBalls.map((ball) {
                              final isW = ball == 'W' || ball == 'RO';
                              final isNB = ball == 'NB';
                              final isBoundary = ball == '4' || ball == '6';
                              return Container(
                                width: 26,
                                height: 26,
                                margin: const EdgeInsets.only(right: 6),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Detailed Scorecard Toggle Card
        Card(
          child: ExpansionTile(
            initiallyExpanded: _showFullScorecard,
            onExpansionChanged: (val) => setState(() => _showFullScorecard = val),
            leading: const Icon(LucideIcons.fileText,
                size: 18, color: AppColors.primary),
            title: Text(
              'Detailed Match Scorecard (${displayBattingTeam})',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Batting Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('Batter',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('R',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('B',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('4s',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('6s',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              flex: 2,
                              child: Text('SR',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Batting List
                    if (score.battingScorecard.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('${score.striker} *',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ),
                            Expanded(
                                child: Text('${score.strikerRuns}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12))),
                            Expanded(
                                child: Text('${score.strikerBalls}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12))),
                            const Expanded(
                                child: Text('-', textAlign: TextAlign.center)),
                            const Expanded(
                                child: Text('-', textAlign: TextAlign.center)),
                            Expanded(
                              flex: 2,
                              child: Text(
                                score.strikerBalls > 0
                                    ? ((score.strikerRuns / score.strikerBalls) *
                                            100)
                                        .toStringAsFixed(1)
                                    : '0.0',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...score.battingScorecard.map((b) {
                        final isCurrentlyAtCrease =
                            b.name == score.striker || b.name == score.nonStriker;
                        final isStriker = b.name == score.striker;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${b.name} ${isStriker ? '*' : ''}',
                                      style: TextStyle(
                                        fontWeight: isCurrentlyAtCrease
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 12,
                                        color: isCurrentlyAtCrease
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      b.isOut ? b.dismissal : 'not out',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Text('${b.runs}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12))),
                              Expanded(
                                  child: Text('${b.balls}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12))),
                              Expanded(
                                  child: Text('${b.fours}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12))),
                              Expanded(
                                  child: Text('${b.sixes}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12))),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  b.strikeRate.toStringAsFixed(1),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const Divider(height: 18),

                    // Bowling Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('Bowler',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('O',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('M',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('R',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              child: Text('W',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                          Expanded(
                              flex: 2,
                              child: Text('Econ',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Bowling List
                    if (score.bowlingScorecard.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(score.currentBowler,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ),
                            Expanded(
                                child: Text(score.bowlerOvers.toStringAsFixed(1),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12))),
                            const Expanded(
                                child: Text('0', textAlign: TextAlign.center)),
                            Expanded(
                                child: Text('${score.bowlerRunsConceded}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12))),
                            Expanded(
                                child: Text('${score.bowlerWickets}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                            Expanded(
                              flex: 2,
                              child: Text(
                                score.bowlerOvers > 0
                                    ? (score.bowlerRunsConceded /
                                            score.bowlerOvers)
                                        .toStringAsFixed(1)
                                    : '0.0',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...score.bowlingScorecard.map((bw) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  bw.name,
                                  style: TextStyle(
                                    fontWeight: bw.name == score.currentBowler
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 12,
                                    color: bw.name == score.currentBowler
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Text(bw.overs.toStringAsFixed(1),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12))),
                              Expanded(
                                  child: Text('${bw.maidens}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12))),
                              Expanded(
                                  child: Text('${bw.runs}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12))),
                              Expanded(
                                  child: Text('${bw.wickets}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12))),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  bw.economy.toStringAsFixed(1),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const Divider(height: 18),
                    // Extras summary
                    Text(
                      'Extras: ${score.extras} (wd: ${score.wides}, nb: ${score.noBalls}, b: ${score.byes}, lb: ${score.legByes})',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
