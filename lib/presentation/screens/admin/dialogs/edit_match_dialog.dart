import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/models/match_model.dart';
import '../../../../features/matches/models/match_status.dart';
import '../../../../features/matches/providers/match_providers.dart';
import '../../../widgets/stream_guide_dialog.dart';

class EditMatchDialog extends ConsumerStatefulWidget {
  final MatchModel match;

  const EditMatchDialog({
    super.key,
    required this.match,
  });

  @override
  ConsumerState<EditMatchDialog> createState() => _EditMatchDialogState();
}

class _EditMatchDialogState extends ConsumerState<EditMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _teamAController;
  late final TextEditingController _teamBController;
  late final TextEditingController _stageController;
  late final TextEditingController _venueController;
  late final TextEditingController _streamUrlController;
  late DateTime _scheduledTime;
  late MatchStatus _status;

  @override
  void initState() {
    super.initState();
    _teamAController = TextEditingController(text: widget.match.teamA);
    _teamBController = TextEditingController(text: widget.match.teamB);
    _stageController = TextEditingController(text: widget.match.stage ?? '');
    _venueController = TextEditingController(text: widget.match.venue ?? '');
    _streamUrlController =
        TextEditingController(text: widget.match.streamUrl ?? '');
    _scheduledTime =
        widget.match.scheduledTime ?? DateTime.now().add(const Duration(hours: 1));
    _status = widget.match.status;
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

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final teamA = _teamAController.text.trim();
    final teamB = _teamBController.text.trim();

    final updatedMatch = widget.match.copyWith(
      title: '$teamA vs $teamB',
      teamA: teamA,
      teamB: teamB,
      status: _status,
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
    );

    final matchDao = ref.read(matchDaoProvider);
    await matchDao.updateMatch(updatedMatch);

    ref.invalidate(matchesForSportProvider(widget.match.sportId));
    ref.invalidate(matchByIdProvider(widget.match.id));

    if (mounted) {
      Navigator.of(context).pop(updatedMatch);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match fixture updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                          'Edit Match Fixture',
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
                      hintText: 'e.g. Finals, Semi-Final, League Match',
                      prefixIcon: Icon(LucideIcons.trophy, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 4: Court / Venue
                  TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(
                      labelText: 'Court / Ground / Venue',
                      prefixIcon: Icon(LucideIcons.mapPin, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 5: Live Video Stream URL
                  TextFormField(
                    controller: _streamUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Live Video Stream URL (Optional)',
                      hintText: 'VDO.Ninja / YouTube / Livepeer / Twitch link',
                      prefixIcon: Icon(LucideIcons.video, size: 18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => StreamGuideDialog.show(context),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.helpCircle,
                                size: 13, color: AppColors.primary),
                            const SizedBox(width: 5),
                            const Flexible(
                              child: Text(
                                'How to get stream link? (Step-by-step guide)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 6: Scheduled Date & Time Picker
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Scheduled Date & Time *',
                        prefixIcon: Icon(LucideIcons.calendarClock, size: 18),
                        suffixIcon: Icon(LucideIcons.chevronRight, size: 18),
                      ),
                      child: Text(
                        DateFormat('EEE, MMM d, yyyy • h:mm a')
                            .format(_scheduledTime),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 7: Match Status
                  DropdownButtonFormField<MatchStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Match Status',
                      prefixIcon: Icon(LucideIcons.activity, size: 18),
                    ),
                    items: MatchStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _status = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Save Match Changes'),
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
