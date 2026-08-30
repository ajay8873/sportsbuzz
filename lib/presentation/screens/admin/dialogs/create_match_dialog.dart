import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../features/matches/models/match_model.dart';
import '../../../../features/matches/models/match_status.dart';
import '../../../../features/matches/models/sport_score.dart';
import '../../../../features/matches/providers/match_providers.dart';
import '../../../../features/sports/models/scoring_model.dart';

class CreateMatchDialog extends ConsumerStatefulWidget {
  final String sportId;
  final String sportName;
  final ScoringModel scoringModel;

  const CreateMatchDialog({
    super.key,
    required this.sportId,
    required this.sportName,
    required this.scoringModel,
  });

  @override
  ConsumerState<CreateMatchDialog> createState() => _CreateMatchDialogState();
}

class _CreateMatchDialogState extends ConsumerState<CreateMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _stageController = TextEditingController(text: 'League Match');
  final _venueController = TextEditingController();
  final _streamUrlController = TextEditingController();

  DateTime _scheduledTime = DateTime.now().add(const Duration(hours: 1));

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledTime),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _scheduledTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _stageController.dispose();
    _venueController.dispose();
    _streamUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final teamA = _teamAController.text.trim();
    final teamB = _teamBController.text.trim();

    final newMatch = MatchModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      sportId: widget.sportId,
      title: '$teamA vs $teamB',
      teamA: teamA,
      teamB: teamB,
      status: MatchStatus.scheduled,
      scheduledTime: _scheduledTime,
      venue: _venueController.text.trim().isEmpty
          ? null
          : _venueController.text.trim(),
      stage: _stageController.text.trim().isEmpty
          ? null
          : _stageController.text.trim(),
      streamUrl: _streamUrlController.text.trim().isEmpty
          ? null
          : _streamUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    final matchDao = ref.read(matchDaoProvider);
    await matchDao.createMatch(newMatch);

    // Initialize initial match state with the exact sport scoring model
    final initialScore = SportScore.createInitial(
      widget.scoringModel,
      sportName: widget.sportName,
    );
    final stateDao = ref.read(matchStateDaoProvider);
    await stateDao.updateScore(
      matchId: newMatch.id,
      newScore: initialScore,
    );

    ref.invalidate(matchesForSportProvider(widget.sportId));

    if (mounted) {
      Navigator.of(context).pop(newMatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Schedule ${widget.sportName} Fixture',
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 1: Team A
                  TextFormField(
                    controller: _teamAController,
                    decoration: const InputDecoration(
                      labelText: 'Team / Dept A Name *',
                      hintText: 'e.g. Batch 2022',
                      prefixIcon: Icon(LucideIcons.users, size: 18),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter Team A' : null,
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Team B
                  TextFormField(
                    controller: _teamBController,
                    decoration: const InputDecoration(
                      labelText: 'Team / Dept B Name *',
                      hintText: 'e.g. Batch 2023',
                      prefixIcon: Icon(LucideIcons.users, size: 18),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter Team B' : null,
                  ),
                  const SizedBox(height: 12),

                  // Row 3: Stage / Round
                  TextFormField(
                    controller: _stageController,
                    decoration: const InputDecoration(
                      labelText: 'Stage / Round Name',
                      hintText: 'e.g. League Match, Finals, Semi-Final',
                      prefixIcon: Icon(LucideIcons.trophy, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 4: Court / Venue
                  TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(
                      labelText: 'Court / Pitch / Ground Venue',
                      hintText: 'e.g. Volleyball Court 1, Main Ground',
                      prefixIcon: Icon(LucideIcons.mapPin, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 5: YouTube Live / Stream URL
                  TextFormField(
                    controller: _streamUrlController,
                    decoration: const InputDecoration(
                      labelText: 'YouTube Live / Stream URL (Optional)',
                      hintText: 'https://youtube.com/watch?v=...',
                      prefixIcon: Icon(LucideIcons.video, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 6: Scheduled Date & Time Picker
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Match Date & Time *',
                        prefixIcon: Icon(LucideIcons.calendarClock, size: 18),
                        suffixIcon: Icon(LucideIcons.chevronRight, size: 18),
                      ),
                      child: Text(
                        DateFormat('EEE, MMM d, yyyy • h:mm a').format(_scheduledTime),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Schedule Match Fixture'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
