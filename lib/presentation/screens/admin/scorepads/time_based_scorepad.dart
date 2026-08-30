import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/models/sport_score.dart';

class TimeBasedScorepad extends StatefulWidget {
  final TimeBasedScore score;
  final String teamAName;
  final String teamBName;
  final ValueChanged<TimeBasedScore> onScoreChanged;

  const TimeBasedScorepad({
    super.key,
    required this.score,
    required this.teamAName,
    required this.teamBName,
    required this.onScoreChanged,
  });

  @override
  State<TimeBasedScorepad> createState() => _TimeBasedScorepadState();
}

class _TimeBasedScorepadState extends State<TimeBasedScorepad> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    if (widget.score.isClockRunning) {
      _startClock();
    }
  }

  @override
  void didUpdateWidget(covariant TimeBasedScorepad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score.isClockRunning != oldWidget.score.isClockRunning) {
      if (widget.score.isClockRunning) {
        _startClock();
      } else {
        _stopClock();
      }
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        widget.onScoreChanged(
          widget.score.copyWith(
            elapsedSeconds: widget.score.elapsedSeconds + 1,
          ),
        );
      }
    });
  }

  void _stopClock() {
    _clockTimer?.cancel();
  }

  void _toggleClock() {
    final nextState = !widget.score.isClockRunning;
    widget.onScoreChanged(
      widget.score.copyWith(isClockRunning: nextState),
    );
  }

  void _updateScore(String team, int delta, {String? actionLabel}) {
    if (team == 'TEAM_A') {
      final newScore = (widget.score.teamAScore + delta).clamp(0, 999);
      final newTimeline = List<MatchEventLog>.from(widget.score.timeline);
      if (delta > 0) {
        newTimeline.add(MatchEventLog(
          id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
          timestampSeconds: widget.score.elapsedSeconds,
          eventType: actionLabel ?? 'POINT/GOAL',
          team: 'TEAM_A',
          playerName: widget.teamAName,
        ));
      }
      widget.onScoreChanged(
        widget.score.copyWith(
          teamAScore: newScore,
          timeline: newTimeline,
        ),
      );
    } else {
      final newScore = (widget.score.teamBScore + delta).clamp(0, 999);
      final newTimeline = List<MatchEventLog>.from(widget.score.timeline);
      if (delta > 0) {
        newTimeline.add(MatchEventLog(
          id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
          timestampSeconds: widget.score.elapsedSeconds,
          eventType: actionLabel ?? 'POINT/GOAL',
          team: 'TEAM_B',
          playerName: widget.teamBName,
        ));
      }
      widget.onScoreChanged(
        widget.score.copyWith(
          teamBScore: newScore,
          timeline: newTimeline,
        ),
      );
    }
  }

  void _addCard(String team, String cardType) {
    if (team == 'TEAM_A') {
      if (cardType == 'YELLOW') {
        final currentYellow = widget.score.teamAYellowCards;
        if (currentYellow >= 1) {
          // 2nd Yellow = Automatic Red Card!
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rule: 2nd Yellow Card for ${widget.teamAName} results in an automatic RED CARD!',
              ),
              backgroundColor: AppColors.liveRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onScoreChanged(
            widget.score.copyWith(
              teamAYellowCards: currentYellow + 1,
              teamARedCards: widget.score.teamARedCards + 1,
            ),
          );
        } else {
          widget.onScoreChanged(
            widget.score.copyWith(teamAYellowCards: currentYellow + 1),
          );
        }
      } else {
        widget.onScoreChanged(
          widget.score.copyWith(teamARedCards: widget.score.teamARedCards + 1),
        );
      }
    } else {
      if (cardType == 'YELLOW') {
        final currentYellow = widget.score.teamBYellowCards;
        if (currentYellow >= 1) {
          // 2nd Yellow = Automatic Red Card!
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rule: 2nd Yellow Card for ${widget.teamBName} results in an automatic RED CARD!',
              ),
              backgroundColor: AppColors.liveRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onScoreChanged(
            widget.score.copyWith(
              teamBYellowCards: currentYellow + 1,
              teamBRedCards: widget.score.teamBRedCards + 1,
            ),
          );
        } else {
          widget.onScoreChanged(
            widget.score.copyWith(teamBYellowCards: currentYellow + 1),
          );
        }
      } else {
        widget.onScoreChanged(
          widget.score.copyWith(teamBRedCards: widget.score.teamBRedCards + 1),
        );
      }
    }
  }

  void _addFoul(String team) {
    if (team == 'TEAM_A') {
      final newFouls = widget.score.teamAFouls + 1;
      if (newFouls == 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.teamAName} has reached 5 fouls! Opponent enters BONUS (Free Throw) penalty status.',
            ),
            backgroundColor: Colors.amber.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      widget.onScoreChanged(
        widget.score.copyWith(teamAFouls: newFouls),
      );
    } else {
      final newFouls = widget.score.teamBFouls + 1;
      if (newFouls == 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.teamBName} has reached 5 fouls! Opponent enters BONUS (Free Throw) penalty status.',
            ),
            backgroundColor: Colors.amber.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      widget.onScoreChanged(
        widget.score.copyWith(teamBFouls: newFouls),
      );
    }
  }

  void _setPeriod(String period) {
    widget.onScoreChanged(widget.score.copyWith(period: period));
  }

  @override
  Widget build(BuildContext context) {
    final teamABonus = widget.score.teamAFouls >= 5;
    final teamBBonus = widget.score.teamBFouls >= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Clock & Match Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        widget.score.period.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          widget.score.isClockRunning
                              ? LucideIcons.timer
                              : LucideIcons.timerOff,
                          size: 18,
                          color: widget.score.isClockRunning
                              ? AppColors.completedGreen
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.score.formattedClock,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.score.isClockRunning
                            ? AppColors.liveRed
                            : AppColors.completedGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      icon: Icon(
                        widget.score.isClockRunning
                            ? LucideIcons.pause
                            : LucideIcons.play,
                        size: 16,
                      ),
                      label: Text(widget.score.isClockRunning ? 'Pause' : 'Start'),
                      onPressed: _toggleClock,
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Teams and Big Scoreboard
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.teamAName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.score.teamAScore}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              if (widget.score.teamAYellowCards > 0)
                                _CardIndicator(
                                  count: widget.score.teamAYellowCards,
                                  color: Colors.amber.shade600,
                                ),
                              if (widget.score.teamARedCards > 0)
                                _CardIndicator(
                                  count: widget.score.teamARedCards,
                                  color: AppColors.liveRed,
                                ),
                              Text(
                                'Fouls: ${widget.score.teamAFouls}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (teamABonus)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
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
                            widget.teamBName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.score.teamBScore}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              if (widget.score.teamBYellowCards > 0)
                                _CardIndicator(
                                  count: widget.score.teamBYellowCards,
                                  color: Colors.amber.shade600,
                                ),
                              if (widget.score.teamBRedCards > 0)
                                _CardIndicator(
                                  count: widget.score.teamBRedCards,
                                  color: AppColors.liveRed,
                                ),
                              Text(
                                'Fouls: ${widget.score.teamBFouls}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (teamBBonus)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Scoring Controls for Team A
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.teamAName} Controls',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('+1 Pt / Goal'),
                      onPressed: () => _updateScore('TEAM_A', 1, actionLabel: '1 PT'),
                    ),
                    FilledButton.tonal(
                      child: const Text('+2 Pts'),
                      onPressed: () => _updateScore('TEAM_A', 2, actionLabel: '2 PTS'),
                    ),
                    FilledButton.tonal(
                      child: const Text('+3 Pts (3-Pointer)'),
                      onPressed: () => _updateScore('TEAM_A', 3, actionLabel: '3-POINTER'),
                    ),
                    OutlinedButton(
                      onPressed: () => _updateScore('TEAM_A', -1),
                      child: const Text('-1 Pt'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(LucideIcons.shieldAlert, size: 14),
                      label: const Text('+ Foul'),
                      onPressed: () => _addFoul('TEAM_A'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber.shade800,
                      ),
                      onPressed: () => _addCard('TEAM_A', 'YELLOW'),
                      child: const Text('Yellow Card'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.liveRed,
                      ),
                      onPressed: () => _addCard('TEAM_A', 'RED'),
                      child: const Text('Red Card'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Scoring Controls for Team B
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.teamBName} Controls',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('+1 Pt / Goal'),
                      onPressed: () => _updateScore('TEAM_B', 1, actionLabel: '1 PT'),
                    ),
                    FilledButton.tonal(
                      child: const Text('+2 Pts'),
                      onPressed: () => _updateScore('TEAM_B', 2, actionLabel: '2 PTS'),
                    ),
                    FilledButton.tonal(
                      child: const Text('+3 Pts (3-Pointer)'),
                      onPressed: () => _updateScore('TEAM_B', 3, actionLabel: '3-POINTER'),
                    ),
                    OutlinedButton(
                      onPressed: () => _updateScore('TEAM_B', -1),
                      child: const Text('-1 Pt'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(LucideIcons.shieldAlert, size: 14),
                      label: const Text('+ Foul'),
                      onPressed: () => _addFoul('TEAM_B'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber.shade800,
                      ),
                      onPressed: () => _addCard('TEAM_B', 'YELLOW'),
                      child: const Text('Yellow Card'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.liveRed,
                      ),
                      onPressed: () => _addCard('TEAM_B', 'RED'),
                      child: const Text('Red Card'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Period Selection Chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            '1st Half',
            '2nd Half',
            'Q1',
            'Q2',
            'Q3',
            'Q4',
            'Extra Time',
            'Penalties',
          ].map((period) {
            final isSelected = widget.score.period == period;
            return ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (_) => _setPeriod(period),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CardIndicator extends StatelessWidget {
  final int count;
  final Color color;

  const _CardIndicator({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
