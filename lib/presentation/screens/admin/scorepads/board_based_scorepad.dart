import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/models/sport_score.dart';

class BoardBasedScorepad extends StatefulWidget {
  final BoardBasedScore score;
  final String playerAName;
  final String playerBName;
  final ValueChanged<BoardBasedScore> onScoreChanged;

  const BoardBasedScorepad({
    super.key,
    required this.score,
    required this.playerAName,
    required this.playerBName,
    required this.onScoreChanged,
  });

  @override
  State<BoardBasedScorepad> createState() => _BoardBasedScorepadState();
}

class _BoardBasedScorepadState extends State<BoardBasedScorepad> {
  Timer? _chessTimer;

  @override
  void initState() {
    super.initState();
    if (widget.score.isClockRunning) {
      _startClock();
    }
  }

  @override
  void didUpdateWidget(covariant BoardBasedScorepad oldWidget) {
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
    _chessTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _chessTimer?.cancel();
    _chessTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (widget.score.activeTurn == 'PLAYER_A') {
        if (widget.score.timeRemainingSecondsA > 0) {
          widget.onScoreChanged(
            widget.score.copyWith(
              timeRemainingSecondsA: widget.score.timeRemainingSecondsA - 1,
            ),
          );
        }
      } else {
        if (widget.score.timeRemainingSecondsB > 0) {
          widget.onScoreChanged(
            widget.score.copyWith(
              timeRemainingSecondsB: widget.score.timeRemainingSecondsB - 1,
            ),
          );
        }
      }
    });
  }

  void _stopClock() {
    _chessTimer?.cancel();
  }

  void _toggleTimer() {
    widget.onScoreChanged(
      widget.score.copyWith(isClockRunning: !widget.score.isClockRunning),
    );
  }

  void _switchTurn() {
    final nextTurn =
        widget.score.activeTurn == 'PLAYER_A' ? 'PLAYER_B' : 'PLAYER_A';
    widget.onScoreChanged(
      widget.score.copyWith(
        activeTurn: nextTurn,
        movesCount: widget.score.movesCount + 1,
      ),
    );
  }

  void _setMatchPoints(double a, double b, String status) {
    widget.onScoreChanged(
      widget.score.copyWith(
        matchPointsA: a,
        matchPointsB: b,
        statusDetail: status,
        isClockRunning: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Board & Chess Clocks Card
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
                        'BOARD ${widget.score.boardNumber} • ${widget.score.statusDetail.toUpperCase()}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.score.isClockRunning
                            ? AppColors.liveRed
                            : AppColors.completedGreen,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(
                        widget.score.isClockRunning
                            ? LucideIcons.pause
                            : LucideIcons.play,
                        size: 16,
                      ),
                      label: Text(
                          widget.score.isClockRunning ? 'Pause Clock' : 'Start Clock'),
                      onPressed: _toggleTimer,
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Dual Chess Timers
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.score.activeTurn == 'PLAYER_A'
                              ? AppColors.primarySurface
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.score.activeTurn == 'PLAYER_A'
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.playerAName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.score.clockAFormatted,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'Score: ${widget.score.matchPointsA}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(LucideIcons.arrowRightLeft),
                        onPressed: _switchTurn,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.score.activeTurn == 'PLAYER_B'
                              ? AppColors.primarySurface
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.score.activeTurn == 'PLAYER_B'
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.playerBName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.score.clockBFormatted,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'Score: ${widget.score.matchPointsB}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Quick Decision Actions
        Text(
          'DECISION / END GAME',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.completedGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _setMatchPoints(1.0, 0.0, 'Win (White/A)'),
                child: Text('1-0 (${widget.playerAName})'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _setMatchPoints(0.5, 0.5, 'Draw / Stalemate'),
                child: const Text('0.5 - 0.5 (Draw)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.completedGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _setMatchPoints(0.0, 1.0, 'Win (Black/B)'),
                child: Text('0-1 (${widget.playerBName})'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
