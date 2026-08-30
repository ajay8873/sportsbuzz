import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/models/sport_score.dart';

class RunBasedScorepad extends StatelessWidget {
  final RunBasedScore score;
  final String teamAName;
  final String teamBName;
  final ValueChanged<RunBasedScore> onScoreChanged;

  const RunBasedScorepad({
    super.key,
    required this.score,
    required this.teamAName,
    required this.teamBName,
    required this.onScoreChanged,
  });

  void _openTossAndMatchSetup(BuildContext context) {
    String tossWinner = score.tossWinner ?? teamAName;
    String tossDecision = score.tossDecision ?? 'BAT';
    final strikerController = TextEditingController(text: score.striker);
    final nonStrikerController = TextEditingController(text: score.nonStriker);
    final bowlerController = TextEditingController(text: score.currentBowler);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final battingTeamName =
              tossDecision == 'BAT' ? tossWinner : (tossWinner == teamAName ? teamBName : teamAName);
          final bowlingTeamName =
              battingTeamName == teamAName ? teamBName : teamAName;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(LucideIcons.coins, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Match Setup & Toss'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WHO WON THE TOSS?',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(teamAName, overflow: TextOverflow.ellipsis),
                          selected: tossWinner == teamAName,
                          onSelected: (val) {
                            if (val) setModalState(() => tossWinner = teamAName);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(teamBName, overflow: TextOverflow.ellipsis),
                          selected: tossWinner == teamBName,
                          onSelected: (val) {
                            if (val) setModalState(() => tossWinner = teamBName);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'TOSS DECISION (OPTED TO)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(LucideIcons.sparkles, size: 14),
                          label: const Text('Bat First'),
                          selected: tossDecision == 'BAT',
                          onSelected: (val) {
                            if (val) setModalState(() => tossDecision = 'BAT');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(LucideIcons.shield, size: 14),
                          label: const Text('Bowl First'),
                          selected: tossDecision == 'BOWL',
                          onSelected: (val) {
                            if (val) setModalState(() => tossDecision = 'BOWL');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Batting: $battingTeamName  •  Bowling: $bowlingTeamName',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                  const Divider(height: 24),

                  const Text(
                    'OPENING BATTERS (BATTING SQUAD)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: strikerController,
                    decoration: const InputDecoration(
                      labelText: 'Opening Striker *',
                      hintText: 'e.g. Ajay / Rohit',
                      prefixIcon: Icon(LucideIcons.userCheck, size: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nonStrikerController,
                    decoration: const InputDecoration(
                      labelText: 'Non-Striker *',
                      hintText: 'e.g. Rahul / Virat',
                      prefixIcon: Icon(LucideIcons.user, size: 16),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'OPENING BOWLER',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bowlerController,
                    decoration: const InputDecoration(
                      labelText: 'Bowler Name *',
                      hintText: 'e.g. Amit / Bumrah',
                      prefixIcon: Icon(LucideIcons.crosshair, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final str = strikerController.text.trim().isEmpty ? 'Striker 1' : strikerController.text.trim();
                  final nonStr =
                      nonStrikerController.text.trim().isEmpty ? 'Striker 2' : nonStrikerController.text.trim();
                  final bowl =
                      bowlerController.text.trim().isEmpty ? 'Bowler 1' : bowlerController.text.trim();

                  final summary =
                      '$tossWinner won toss & opted to ${tossDecision == 'BAT' ? 'Bat' : 'Bowl'} first';

                  final existingBatting = List<BattingEntry>.from(score.battingScorecard);
                  if (!existingBatting.any((b) => b.name == str)) {
                    existingBatting.insert(0, BattingEntry(name: str));
                  }
                  if (!existingBatting.any((b) => b.name == nonStr)) {
                    existingBatting.insert(1, BattingEntry(name: nonStr));
                  }

                  final existingBowling = List<BowlingEntry>.from(score.bowlingScorecard);
                  if (!existingBowling.any((b) => b.name == bowl)) {
                    existingBowling.add(BowlingEntry(name: bowl));
                  }

                  onScoreChanged(
                    score.copyWith(
                      tossWinner: tossWinner,
                      tossDecision: tossDecision,
                      tossSummary: summary,
                      battingTeam: battingTeamName,
                      bowlingTeam: bowlingTeamName,
                      striker: str,
                      nonStriker: nonStr,
                      currentBowler: bowl,
                      battingScorecard: existingBatting,
                      bowlingScorecard: existingBowling,
                    ),
                  );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Apply Match Setup'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editPlayerName(BuildContext context, {required String role, required String currentName}) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $role Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: '$role Name',
            hintText: 'Enter player name',
            prefixIcon: const Icon(LucideIcons.user, size: 18),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                if (role == 'Striker') {
                  onScoreChanged(score.copyWith(striker: newName));
                } else if (role == 'Non-Striker') {
                  onScoreChanged(score.copyWith(nonStriker: newName));
                } else if (role == 'Bowler') {
                  final bowling = List<BowlingEntry>.from(score.bowlingScorecard);
                  if (!bowling.any((b) => b.name == newName)) {
                    bowling.add(BowlingEntry(name: newName));
                  }
                  onScoreChanged(
                    score.copyWith(
                      currentBowler: newName,
                      bowlingScorecard: bowling,
                    ),
                  );
                }
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _switchInnings(BuildContext context) {
    final nextBatting = score.bowlingTeam;
    final nextBowling = score.battingTeam;
    final targetRuns = score.runs + 1;

    final strikerCtrl = TextEditingController(text: 'Batter 1');
    final nonStrikerCtrl = TextEditingController(text: 'Batter 2');
    final bowlerCtrl = TextEditingController(text: 'Bowler 1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch to 2nd Innings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1st Innings Score: ${score.runs}/${score.wickets} (${score.overs} ov)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Target for $nextBatting: $targetRuns runs',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const Divider(height: 20),
              const Text('2nd Innings Opening Batters:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: strikerCtrl,
                decoration: const InputDecoration(labelText: 'Striker'),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nonStrikerCtrl,
                decoration: const InputDecoration(labelText: 'Non-Striker'),
              ),
              const SizedBox(height: 10),
              const Text('Opening Bowler:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: bowlerCtrl,
                decoration: const InputDecoration(labelText: 'Bowler'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final str = strikerCtrl.text.trim().isEmpty ? 'Batter 1' : strikerCtrl.text.trim();
              final nonStr = nonStrikerCtrl.text.trim().isEmpty ? 'Batter 2' : nonStrikerCtrl.text.trim();
              final bowl = bowlerCtrl.text.trim().isEmpty ? 'Bowler 1' : bowlerCtrl.text.trim();

              onScoreChanged(
                score.copyWith(
                  innings: '2nd Innings',
                  target: targetRuns,
                  battingTeam: nextBatting,
                  bowlingTeam: nextBowling,
                  runs: 0,
                  wickets: 0,
                  overs: 0.0,
                  balls: 0,
                  striker: str,
                  strikerRuns: 0,
                  strikerBalls: 0,
                  nonStriker: nonStr,
                  nonStrikerRuns: 0,
                  nonStrikerBalls: 0,
                  currentBowler: bowl,
                  bowlerOvers: 0.0,
                  bowlerRunsConceded: 0,
                  bowlerWickets: 0,
                  extras: 0,
                  wides: 0,
                  noBalls: 0,
                  byes: 0,
                  legByes: 0,
                  recentBalls: [],
                  isFreeHit: false,
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Start 2nd Innings'),
          ),
        ],
      ),
    );
  }

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

    // Update batting scorecard
    final batting = List<BattingEntry>.from(score.battingScorecard);
    final strIndex = batting.indexWhere((b) => b.name == score.striker);
    if (strIndex != -1) {
      final old = batting[strIndex];
      batting[strIndex] = old.copyWith(
        runs: old.runs + runsCount,
        balls: old.balls + 1,
        fours: runsCount == 4 ? old.fours + 1 : old.fours,
        sixes: runsCount == 6 ? old.sixes + 1 : old.sixes,
      );
    } else {
      batting.add(BattingEntry(
        name: score.striker,
        runs: score.strikerRuns + runsCount,
        balls: score.strikerBalls + 1,
        fours: runsCount == 4 ? 1 : 0,
        sixes: runsCount == 6 ? 1 : 0,
      ));
    }

    // Update bowling scorecard
    final bowling = List<BowlingEntry>.from(score.bowlingScorecard);
    final bowlIndex = bowling.indexWhere((b) => b.name == score.currentBowler);
    if (bowlIndex != -1) {
      final old = bowling[bowlIndex];
      bowling[bowlIndex] = old.copyWith(
        runs: old.runs + runsCount,
        overs: nextOvers,
      );
    } else {
      bowling.add(BowlingEntry(
        name: score.currentBowler,
        runs: score.bowlerRunsConceded + runsCount,
        overs: nextOvers,
      ));
    }

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
        battingScorecard: batting,
        bowlingScorecard: bowling,
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
                _promptNewBatter(context, isRunOut: true);
              },
              child: const Text('Confirm Run Out'),
            ),
          ],
        ),
      );
      return;
    }

    _promptNewBatter(context, isRunOut: false);
  }

  void _promptNewBatter(BuildContext context, {required bool isRunOut}) {
    String dismissalType = isRunOut ? 'run out' : 'bowled';
    final batterCtrl = TextEditingController(text: 'Batter ${score.wickets + 3}');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(LucideIcons.skull, color: AppColors.liveRed, size: 20),
                SizedBox(width: 8),
                Text('Wicket / Dismissal'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dismissed Batter: ${score.striker} (${score.strikerRuns} runs)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text('Dismissal Type:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: dismissalType,
                  items: const [
                    DropdownMenuItem(value: 'bowled', child: Text('Bowled')),
                    DropdownMenuItem(value: 'caught', child: Text('Caught')),
                    DropdownMenuItem(value: 'lbw', child: Text('LBW')),
                    DropdownMenuItem(value: 'run out', child: Text('Run Out')),
                    DropdownMenuItem(value: 'stumped', child: Text('Stumped')),
                    DropdownMenuItem(value: 'hit wicket', child: Text('Hit Wicket')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => dismissalType = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text('New Incoming Batter:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: batterCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Next Batter Name',
                    prefixIcon: Icon(LucideIcons.userPlus, size: 16),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.liveRed, foregroundColor: Colors.white),
                onPressed: () {
                  final newBatterName =
                      batterCtrl.text.trim().isEmpty ? 'Batter ${score.wickets + 3}' : batterCtrl.text.trim();
                  _processWicket(isRunOut: isRunOut, dismissal: dismissalType, newBatterName: newBatterName);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Confirm Wicket'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _processWicket({
    required bool isRunOut,
    String dismissal = 'bowled',
    String newBatterName = 'Batter',
  }) {
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

    // Update batting scorecard
    final batting = List<BattingEntry>.from(score.battingScorecard);
    final strIndex = batting.indexWhere((b) => b.name == score.striker);
    if (strIndex != -1) {
      batting[strIndex] = batting[strIndex].copyWith(
        isOut: true,
        dismissal: dismissal,
      );
    } else {
      batting.add(BattingEntry(
        name: score.striker,
        runs: score.strikerRuns,
        balls: score.strikerBalls,
        isOut: true,
        dismissal: dismissal,
      ));
    }
    batting.add(BattingEntry(name: newBatterName, dismissal: 'not out'));

    // Update bowling scorecard
    final bowling = List<BowlingEntry>.from(score.bowlingScorecard);
    final bowlIndex = bowling.indexWhere((b) => b.name == score.currentBowler);
    if (bowlIndex != -1) {
      final old = bowling[bowlIndex];
      bowling[bowlIndex] = old.copyWith(
        wickets: isRunOut ? old.wickets : old.wickets + 1,
        overs: nextOvers,
      );
    }

    onScoreChanged(
      score.copyWith(
        wickets: score.wickets + 1,
        bowlerWickets: isRunOut ? score.bowlerWickets : (score.bowlerWickets + 1),
        bowlerOvers: nextOvers,
        overs: nextOvers,
        balls: nextBalls,
        striker: newBatterName,
        strikerRuns: 0,
        strikerBalls: 0,
        recentBalls: newRecent,
        isFreeHit: false,
        battingScorecard: batting,
        bowlingScorecard: bowling,
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
        break;
      case 'NB':
        noBalls++;
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
        // Match Setup & Toss Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.coins, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  score.tossSummary ?? 'Toss & Squad Setup Pending',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(LucideIcons.settings2, size: 13),
                label: const Text('Setup Toss & XI', style: TextStyle(fontSize: 11)),
                onPressed: () => _openTossAndMatchSetup(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

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
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${score.innings.toUpperCase()} • BATTING: ${score.battingTeam.toUpperCase()}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
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
                const Divider(height: 20),

                // Interactive Batters & Bowler row
                Row(
                  children: [
                    // Striker
                    Expanded(
                      child: InkWell(
                        onTap: () => _editPlayerName(context, role: 'Striker', currentName: score.striker),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.sparkles, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${score.striker} *',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(LucideIcons.pencil, size: 10, color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${score.strikerRuns} (${score.strikerBalls}b)',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Non-Striker
                    Expanded(
                      child: InkWell(
                        onTap: () => _editPlayerName(context, role: 'Non-Striker', currentName: score.nonStriker),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      score.nonStriker,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(LucideIcons.pencil, size: 10, color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${score.nonStrikerRuns} (${score.nonStrikerBalls}b)',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Bowler
                    Expanded(
                      child: InkWell(
                        onTap: () => _editPlayerName(context, role: 'Bowler', currentName: score.currentBowler),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      score.currentBowler,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(LucideIcons.pencil, size: 10, color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${score.bowlerWickets}/${score.bowlerRunsConceded} (${score.bowlerOvers.toStringAsFixed(1)})',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
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
        const SizedBox(height: 14),

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
        const SizedBox(height: 12),

        // Innings Switch Button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(LucideIcons.arrowRightLeft, size: 16),
          label: Text(
            score.innings == '1st Innings'
                ? 'End 1st Innings & Switch to 2nd Innings'
                : 'Switch / Reset Innings',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          onPressed: () => _switchInnings(context),
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
