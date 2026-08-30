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

    List<String> squadA = List<String>.from(
      score.teamASquad.isNotEmpty
          ? score.teamASquad
          : (score.striker.isNotEmpty && score.battingTeam == teamAName
              ? [score.striker, if (score.nonStriker.isNotEmpty) score.nonStriker]
              : []),
    );
    List<String> squadB = List<String>.from(
      score.teamBSquad.isNotEmpty
          ? score.teamBSquad
          : (score.currentBowler.isNotEmpty && score.bowlingTeam == teamBName
              ? [score.currentBowler]
              : []),
    );

    final playerAInputCtrl = TextEditingController();
    final playerBInputCtrl = TextEditingController();
    final strikerController = TextEditingController(
        text: score.striker == 'Striker 1' ? '' : score.striker);
    final nonStrikerController = TextEditingController(
        text: score.nonStriker == 'Striker 2' ? '' : score.nonStriker);
    final bowlerController = TextEditingController(
        text: score.currentBowler == 'Bowler 1' ? '' : score.currentBowler);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final battingTeamName = tossDecision == 'BAT'
              ? tossWinner
              : (tossWinner == teamAName ? teamBName : teamAName);
          final bowlingTeamName =
              battingTeamName == teamAName ? teamBName : teamAName;

          final battingSquad =
              battingTeamName == teamAName ? squadA : squadB;
          final bowlingSquad =
              bowlingTeamName == teamAName ? squadA : squadB;

          return AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(LucideIcons.coins, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Match Setup, Toss & Playing 11'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toss Winner
                    const Text(
                      'WHO WON THE TOSS?',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(teamAName,
                                overflow: TextOverflow.ellipsis),
                            selected: tossWinner == teamAName,
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tossWinner = teamAName);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(teamBName,
                                overflow: TextOverflow.ellipsis),
                            selected: tossWinner == teamBName,
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tossWinner = teamBName);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Toss Decision
                    const Text(
                      'TOSS DECISION (OPTED TO)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
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
                              if (val) {
                                setModalState(() => tossDecision = 'BAT');
                              }
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
                              if (val) {
                                setModalState(() => tossDecision = 'BOWL');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🏏 Batting: $battingTeamName   •   🛡️ Bowling: $bowlingTeamName',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.primary),
                      ),
                    ),
                    const Divider(height: 24),

                    // Squad Manager: Team A
                    Text(
                      '$teamAName SQUAD / PLAYING 11 (${squadA.length} players)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: playerAInputCtrl,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Add player to $teamAName',
                              prefixIcon: const Icon(LucideIcons.userPlus,
                                  size: 14),
                            ),
                            onSubmitted: (val) {
                              final name = val.trim();
                              if (name.isNotEmpty && !squadA.contains(name)) {
                                setModalState(() {
                                  squadA.add(name);
                                  playerAInputCtrl.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            final name = playerAInputCtrl.text.trim();
                            if (name.isNotEmpty && !squadA.contains(name)) {
                              setModalState(() {
                                squadA.add(name);
                                playerAInputCtrl.clear();
                              });
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    if (squadA.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: squadA.map((p) {
                          return Chip(
                            label: Text(p, style: const TextStyle(fontSize: 11)),
                            deleteIcon:
                                const Icon(LucideIcons.x, size: 12),
                            onDeleted: () {
                              setModalState(() => squadA.remove(p));
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Squad Manager: Team B
                    Text(
                      '$teamBName SQUAD / PLAYING 11 (${squadB.length} players)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: playerBInputCtrl,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Add player to $teamBName',
                              prefixIcon: const Icon(LucideIcons.userPlus,
                                  size: 14),
                            ),
                            onSubmitted: (val) {
                              final name = val.trim();
                              if (name.isNotEmpty && !squadB.contains(name)) {
                                setModalState(() {
                                  squadB.add(name);
                                  playerBInputCtrl.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            final name = playerBInputCtrl.text.trim();
                            if (name.isNotEmpty && !squadB.contains(name)) {
                              setModalState(() {
                                squadB.add(name);
                                playerBInputCtrl.clear();
                              });
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    if (squadB.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: squadB.map((p) {
                          return Chip(
                            label: Text(p, style: const TextStyle(fontSize: 11)),
                            deleteIcon:
                                const Icon(LucideIcons.x, size: 12),
                            onDeleted: () {
                              setModalState(() => squadB.remove(p));
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const Divider(height: 24),

                    // Opening Batters
                    Text(
                      'OPENING BATTERS ($battingTeamName)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),

                    // Striker Selector
                    if (battingSquad.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Striker from Squad *',
                          prefixIcon:
                              Icon(LucideIcons.sparkles, size: 16),
                        ),
                        value: battingSquad.contains(strikerController.text)
                            ? strikerController.text
                            : null,
                        hint: const Text('Choose opening striker'),
                        items: battingSquad.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => strikerController.text = val);
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                    TextField(
                      controller: strikerController,
                      decoration: InputDecoration(
                        labelText: battingSquad.isNotEmpty
                            ? 'Or Type Striker Name *'
                            : 'Opening Striker Name *',
                        hintText: 'e.g. Ajay / Rohit',
                        prefixIcon:
                            const Icon(LucideIcons.userCheck, size: 16),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Non-Striker Selector
                    if (battingSquad.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Non-Striker from Squad *',
                          prefixIcon: Icon(LucideIcons.user, size: 16),
                        ),
                        value: battingSquad.contains(nonStrikerController.text)
                            ? nonStrikerController.text
                            : null,
                        hint: const Text('Choose opening non-striker'),
                        items: battingSquad.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(
                                () => nonStrikerController.text = val);
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                    TextField(
                      controller: nonStrikerController,
                      decoration: InputDecoration(
                        labelText: battingSquad.isNotEmpty
                            ? 'Or Type Non-Striker Name *'
                            : 'Opening Non-Striker Name *',
                        hintText: 'e.g. Devendra / Virat',
                        prefixIcon: const Icon(LucideIcons.user, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Opening Bowler
                    Text(
                      'OPENING BOWLER ($bowlingTeamName)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    if (bowlingSquad.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Bowler from Squad *',
                          prefixIcon:
                              Icon(LucideIcons.crosshair, size: 16),
                        ),
                        value: bowlingSquad.contains(bowlerController.text)
                            ? bowlerController.text
                            : null,
                        hint: const Text('Choose opening bowler'),
                        items: bowlingSquad.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => bowlerController.text = val);
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                    TextField(
                      controller: bowlerController,
                      decoration: InputDecoration(
                        labelText: bowlingSquad.isNotEmpty
                            ? 'Or Type Bowler Name *'
                            : 'Bowler Name *',
                        hintText: 'e.g. Amit / Bumrah',
                        prefixIcon:
                            const Icon(LucideIcons.crosshair, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final str = strikerController.text.trim().isEmpty
                      ? 'Striker 1'
                      : strikerController.text.trim();
                  final nonStr = nonStrikerController.text.trim().isEmpty
                      ? 'Striker 2'
                      : nonStrikerController.text.trim();
                  final bowl = bowlerController.text.trim().isEmpty
                      ? 'Bowler 1'
                      : bowlerController.text.trim();

                  final summary =
                      '$tossWinner won toss & opted to ${tossDecision == 'BAT' ? 'Bat' : 'Bowl'} first';

                  // Build clean batting scorecard without duplicate dummy placeholders
                  final cleanBatting = <BattingEntry>[];
                  for (final b in score.battingScorecard) {
                    if (b.name == 'Striker 1' || b.name == 'Striker 2') continue;
                    cleanBatting.add(b);
                  }
                  if (!cleanBatting.any((b) => b.name == str)) {
                    cleanBatting.insert(
                      0,
                      BattingEntry(
                        name: str,
                        runs: (score.striker == str) ? score.strikerRuns : 0,
                        balls: (score.striker == str) ? score.strikerBalls : 0,
                        dismissal: 'not out',
                      ),
                    );
                  }
                  if (!cleanBatting.any((b) => b.name == nonStr)) {
                    cleanBatting.insert(
                      cleanBatting.length > 1 ? 1 : cleanBatting.length,
                      BattingEntry(
                        name: nonStr,
                        runs: (score.nonStriker == nonStr)
                            ? score.nonStrikerRuns
                            : 0,
                        balls: (score.nonStriker == nonStr)
                            ? score.nonStrikerBalls
                            : 0,
                        dismissal: 'not out',
                      ),
                    );
                  }

                  // Build clean bowling scorecard
                  final cleanBowling = <BowlingEntry>[];
                  for (final bw in score.bowlingScorecard) {
                    if (bw.name == 'Bowler 1') continue;
                    cleanBowling.add(bw);
                  }
                  if (!cleanBowling.any((bw) => bw.name == bowl)) {
                    cleanBowling.add(
                      BowlingEntry(
                        name: bowl,
                        overs: (score.currentBowler == bowl)
                            ? score.bowlerOvers
                            : 0.0,
                        runs: (score.currentBowler == bowl)
                            ? score.bowlerRunsConceded
                            : 0,
                        wickets: (score.currentBowler == bowl)
                            ? score.bowlerWickets
                            : 0,
                      ),
                    );
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
                      teamASquad: squadA,
                      teamBSquad: squadB,
                      battingScorecard: cleanBatting,
                      bowlingScorecard: cleanBowling,
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

  void _openPlayerManagement(
    BuildContext context, {
    required String role,
    required String currentName,
  }) {
    final activeSquad = role == 'Bowler'
        ? (score.bowlingTeam == teamAName ? score.teamASquad : score.teamBSquad)
        : (score.battingTeam == teamAName ? score.teamASquad : score.teamBSquad);

    final editController = TextEditingController(text: currentName);
    String selectedFromSquad = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  role == 'Bowler' ? LucideIcons.crosshair : LucideIcons.user,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('$role: $currentName'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RENAME OR EDIT NAME:',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: editController,
                    decoration: InputDecoration(
                      labelText: '$role Name',
                      hintText: 'Enter name',
                      prefixIcon: const Icon(LucideIcons.pencil, size: 16),
                    ),
                  ),
                  if (activeSquad.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'OR SELECT FROM SQUAD:',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: activeSquad.contains(selectedFromSquad)
                          ? selectedFromSquad
                          : null,
                      hint: const Text('Pick player from squad'),
                      items: activeSquad.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedFromSquad = val;
                            editController.text = val;
                          });
                        }
                      },
                    ),
                  ],
                  if (role != 'Bowler') ...[
                    const Divider(height: 24),
                    const Text(
                      'INJURY / RETIRED HURT:',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      icon: const Icon(LucideIcons.cross, size: 16),
                      label: Text('Mark $currentName Retired Hurt / Injured'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _openRetiredHurtDialog(context,
                            retiringBatterRole: role,
                            retiringBatterName: currentName);
                      },
                    ),
                  ],
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
                  final newName = editController.text.trim();
                  if (newName.isNotEmpty) {
                    if (role == 'Striker') {
                      final batting =
                          List<BattingEntry>.from(score.battingScorecard);
                      final idx = batting.indexWhere((b) => b.name == currentName);
                      if (idx != -1) {
                        batting[idx] = batting[idx].copyWith(name: newName);
                      } else {
                        batting.add(BattingEntry(
                            name: newName,
                            runs: score.strikerRuns,
                            balls: score.strikerBalls));
                      }
                      onScoreChanged(score.copyWith(
                          striker: newName, battingScorecard: batting));
                    } else if (role == 'Non-Striker') {
                      final batting =
                          List<BattingEntry>.from(score.battingScorecard);
                      final idx = batting.indexWhere((b) => b.name == currentName);
                      if (idx != -1) {
                        batting[idx] = batting[idx].copyWith(name: newName);
                      } else {
                        batting.add(BattingEntry(
                            name: newName,
                            runs: score.nonStrikerRuns,
                            balls: score.nonStrikerBalls));
                      }
                      onScoreChanged(score.copyWith(
                          nonStriker: newName, battingScorecard: batting));
                    } else if (role == 'Bowler') {
                      final bowling =
                          List<BowlingEntry>.from(score.bowlingScorecard);
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
                child: const Text('Save & Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openRetiredHurtDialog(
    BuildContext context, {
    String? retiringBatterRole,
    String? retiringBatterName,
  }) {
    String retiring = retiringBatterRole ?? 'Striker';
    String outgoingName = retiring == 'Striker' ? score.striker : score.nonStriker;
    String reason = 'retired hurt';
    final incomingController = TextEditingController();

    final battingSquad = score.battingTeam == teamAName
        ? score.teamASquad
        : score.teamBSquad;

    final alreadyBatted = score.battingScorecard.map((e) => e.name).toSet();
    final availableSquad = battingSquad
        .where((p) =>
            !alreadyBatted.contains(p) &&
            p != score.striker &&
            p != score.nonStriker)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(LucideIcons.ambulance, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('Retired Hurt / Batter Substitute'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WHICH BATTER IS RETIRING / INJURED?',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text('${score.striker} (Striker)',
                              overflow: TextOverflow.ellipsis),
                          selected: retiring == 'Striker',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                retiring = 'Striker';
                                outgoingName = score.striker;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          label: Text('${score.nonStriker} (Non-Str)',
                              overflow: TextOverflow.ellipsis),
                          selected: retiring == 'Non-Striker',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                retiring = 'Non-Striker';
                                outgoingName = score.nonStriker;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('REASON / STATUS:',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: reason,
                    items: const [
                      DropdownMenuItem(
                          value: 'retired hurt',
                          child: Text('Retired Hurt (Injured - Can Bat Later)')),
                      DropdownMenuItem(
                          value: 'retired out',
                          child: Text('Retired Out (Treated as Wicket)')),
                      DropdownMenuItem(
                          value: 'substitute',
                          child: Text('Substitute / Runner')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => reason = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('NEW INCOMING BATTER:',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  if (availableSquad.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select from Squad',
                        prefixIcon: Icon(LucideIcons.userPlus, size: 16),
                      ),
                      hint: const Text('Pick next batter from Playing 11'),
                      items: availableSquad.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => incomingController.text = val);
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: incomingController,
                    decoration: InputDecoration(
                      labelText: availableSquad.isNotEmpty
                          ? 'Or Type New Batter Name'
                          : 'New Batter Name *',
                      hintText: 'e.g. Next Player Name',
                      prefixIcon: const Icon(LucideIcons.user, size: 16),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final incomingName = incomingController.text.trim().isEmpty
                      ? 'Batter ${score.battingScorecard.length + 1}'
                      : incomingController.text.trim();

                  final batting =
                      List<BattingEntry>.from(score.battingScorecard);
                  final outIdx =
                      batting.indexWhere((b) => b.name == outgoingName);
                  if (outIdx != -1) {
                    batting[outIdx] = batting[outIdx].copyWith(
                      isOut: (reason == 'retired out'),
                      dismissal: reason,
                    );
                  } else {
                    batting.add(
                      BattingEntry(
                        name: outgoingName,
                        runs: retiring == 'Striker'
                            ? score.strikerRuns
                            : score.nonStrikerRuns,
                        balls: retiring == 'Striker'
                            ? score.strikerBalls
                            : score.nonStrikerBalls,
                        isOut: (reason == 'retired out'),
                        dismissal: reason,
                      ),
                    );
                  }

                  // Add incoming batter to scorecard
                  batting.add(BattingEntry(
                    name: incomingName,
                    runs: 0,
                    balls: 0,
                    dismissal: 'not out',
                  ));

                  if (retiring == 'Striker') {
                    onScoreChanged(
                      score.copyWith(
                        striker: incomingName,
                        strikerRuns: 0,
                        strikerBalls: 0,
                        wickets: (reason == 'retired out')
                            ? score.wickets + 1
                            : score.wickets,
                        battingScorecard: batting,
                      ),
                    );
                  } else {
                    onScoreChanged(
                      score.copyWith(
                        nonStriker: incomingName,
                        nonStrikerRuns: 0,
                        nonStrikerBalls: 0,
                        wickets: (reason == 'retired out')
                            ? score.wickets + 1
                            : score.wickets,
                        battingScorecard: batting,
                      ),
                    );
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('Confirm Replacement'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _switchInnings(BuildContext context) {
    final nextBatting = score.bowlingTeam;
    final nextBowling = score.battingTeam;
    final targetRuns = score.runs + 1;

    final nextBattingSquad =
        nextBatting == teamAName ? score.teamASquad : score.teamBSquad;
    final nextBowlingSquad =
        nextBowling == teamAName ? score.teamASquad : score.teamBSquad;

    final strikerCtrl = TextEditingController(
        text: nextBattingSquad.isNotEmpty ? nextBattingSquad[0] : 'Batter 1');
    final nonStrikerCtrl = TextEditingController(
        text: nextBattingSquad.length > 1 ? nextBattingSquad[1] : 'Batter 2');
    final bowlerCtrl = TextEditingController(
        text: nextBowlingSquad.isNotEmpty ? nextBowlingSquad[0] : 'Bowler 1');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Switch to 2nd Innings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1st Innings: ${score.runs}/${score.wickets} (${score.overs} ov)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target for $nextBatting: $targetRuns runs',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const Divider(height: 20),
                  Text('2nd Innings Opening Batters ($nextBatting):',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 6),
                  if (nextBattingSquad.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Striker from Squad',
                        prefixIcon: Icon(LucideIcons.sparkles, size: 16),
                      ),
                      value: nextBattingSquad.contains(strikerCtrl.text)
                          ? strikerCtrl.text
                          : null,
                      items: nextBattingSquad.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => strikerCtrl.text = val);
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: strikerCtrl,
                    decoration: const InputDecoration(labelText: 'Striker Name'),
                  ),
                  const SizedBox(height: 10),
                  if (nextBattingSquad.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Non-Striker from Squad',
                        prefixIcon: Icon(LucideIcons.user, size: 16),
                      ),
                      value: nextBattingSquad.contains(nonStrikerCtrl.text)
                          ? nonStrikerCtrl.text
                          : null,
                      items: nextBattingSquad.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => nonStrikerCtrl.text = val);
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: nonStrikerCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Non-Striker Name'),
                  ),
                  const SizedBox(height: 14),
                  Text('Opening Bowler ($nextBowling):',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 6),
                  if (nextBowlingSquad.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Bowler from Squad',
                        prefixIcon: Icon(LucideIcons.crosshair, size: 16),
                      ),
                      value: nextBowlingSquad.contains(bowlerCtrl.text)
                          ? bowlerCtrl.text
                          : null,
                      items: nextBowlingSquad.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => bowlerCtrl.text = val);
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: bowlerCtrl,
                    decoration: const InputDecoration(labelText: 'Bowler Name'),
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
                  final str = strikerCtrl.text.trim().isEmpty
                      ? 'Batter 1'
                      : strikerCtrl.text.trim();
                  final nonStr = nonStrikerCtrl.text.trim().isEmpty
                      ? 'Batter 2'
                      : nonStrikerCtrl.text.trim();
                  final bowl = bowlerCtrl.text.trim().isEmpty
                      ? 'Bowler 1'
                      : bowlerCtrl.text.trim();

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
                      battingScorecard: [
                        BattingEntry(name: str, dismissal: 'not out'),
                        BattingEntry(name: nonStr, dismissal: 'not out'),
                      ],
                      bowlingScorecard: [
                        BowlingEntry(name: bowl),
                      ],
                    ),
                  );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Start 2nd Innings'),
              ),
            ],
          );
        },
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

    bool isOddRuns = runsCount % 2 != 0;
    bool shouldSwap =
        (isOddRuns && !swapForOverEnd) || (!isOddRuns && swapForOverEnd);

    String newStriker = shouldSwap ? score.nonStriker : score.striker;
    int newStrikerRuns = shouldSwap
        ? score.nonStrikerRuns
        : (score.strikerRuns + runsCount);
    int newStrikerBalls =
        shouldSwap ? score.nonStrikerBalls : (score.strikerBalls + 1);

    String newNonStriker = shouldSwap ? score.striker : score.nonStriker;
    int newNonStrikerRuns = shouldSwap
        ? (score.strikerRuns + runsCount)
        : score.nonStrikerRuns;
    int newNonStrikerBalls =
        shouldSwap ? (score.strikerBalls + 1) : score.nonStrikerBalls;

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
        isFreeHit: false,
        battingScorecard: batting,
        bowlingScorecard: bowling,
      ),
    );
  }

  void _addWicket(BuildContext context) {
    if (score.isFreeHit) {
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
    final batterCtrl = TextEditingController();

    final battingSquad = score.battingTeam == teamAName
        ? score.teamASquad
        : score.teamBSquad;

    final alreadyBatted = score.battingScorecard.map((e) => e.name).toSet();
    final availableSquad = battingSquad
        .where((p) =>
            !alreadyBatted.contains(p) &&
            p != score.striker &&
            p != score.nonStriker)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(LucideIcons.skull, color: AppColors.liveRed, size: 20),
                SizedBox(width: 8),
                Text('Wicket / Dismissal'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dismissed Batter: ${score.striker} (${score.strikerRuns} runs, ${score.strikerBalls} balls)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Text('Dismissal Type:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: dismissalType,
                    items: const [
                      DropdownMenuItem(value: 'bowled', child: Text('Bowled')),
                      DropdownMenuItem(value: 'caught', child: Text('Caught')),
                      DropdownMenuItem(value: 'lbw', child: Text('LBW')),
                      DropdownMenuItem(value: 'run out', child: Text('Run Out')),
                      DropdownMenuItem(value: 'stumped', child: Text('Stumped')),
                      DropdownMenuItem(
                          value: 'hit wicket', child: Text('Hit Wicket')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => dismissalType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Next Incoming Batter:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  if (availableSquad.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select from Squad',
                        prefixIcon: Icon(LucideIcons.userPlus, size: 16),
                      ),
                      hint: const Text('Pick next batter from Playing 11'),
                      items: availableSquad.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => batterCtrl.text = val);
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: batterCtrl,
                    decoration: InputDecoration(
                      labelText: availableSquad.isNotEmpty
                          ? 'Or Type Next Batter Name'
                          : 'Next Batter Name *',
                      hintText: 'e.g. Batter ${score.wickets + 3}',
                      prefixIcon: const Icon(LucideIcons.user, size: 16),
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.liveRed,
                    foregroundColor: Colors.white),
                onPressed: () {
                  final newBatterName = batterCtrl.text.trim().isEmpty
                      ? 'Batter ${score.wickets + 3}'
                      : batterCtrl.text.trim();
                  _processWicket(
                      isRunOut: isRunOut,
                      dismissal: dismissalType,
                      newBatterName: newBatterName);
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
        bowlerWickets:
            isRunOut ? score.bowlerWickets : (score.bowlerWickets + 1),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(LucideIcons.settings2, size: 13),
                label: const Text('Setup Toss & XI',
                    style: TextStyle(fontSize: 11)),
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
                        onTap: () => _openPlayerManagement(context,
                            role: 'Striker', currentName: score.striker),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primarySurface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.sparkles,
                                      size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${score.striker} *',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(LucideIcons.pencil,
                                      size: 10, color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${score.strikerRuns} (${score.strikerBalls}b)',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 11),
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
                        onTap: () => _openPlayerManagement(context,
                            role: 'Non-Striker', currentName: score.nonStriker),
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
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(LucideIcons.pencil,
                                      size: 10, color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${score.nonStrikerRuns} (${score.nonStrikerBalls}b)',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 11),
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
                        onTap: () => _openPlayerManagement(context,
                            role: 'Bowler', currentName: score.currentBowler),
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
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(LucideIcons.pencil,
                                      size: 10, color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${score.bowlerWickets}/${score.bowlerRunsConceded} (${score.bowlerOvers.toStringAsFixed(1)})',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 11),
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
        const SizedBox(height: 8),

        // Retired Hurt / Substitute Action
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade300),
                ),
                icon: const Icon(LucideIcons.ambulance, size: 15),
                label: const Text('Retired Hurt / Substitute Batter'),
                onPressed: () => _openRetiredHurtDialog(context),
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
