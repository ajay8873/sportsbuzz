import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/events/models/event_model.dart';
import '../../../../features/events/providers/event_providers.dart';
import '../../../../features/sports/models/sport_model.dart';
import '../../../../features/sports/models/sport_category.dart';
import '../../../../features/sports/models/scoring_model.dart';
import '../../../../features/sports/providers/sport_providers.dart';
import '../../../../features/matches/models/match_model.dart';
import '../../../../features/matches/models/match_status.dart';
import '../../../../features/matches/models/sport_score.dart';
import '../../../../features/matches/providers/match_providers.dart';

class CreateEventDialog extends ConsumerStatefulWidget {
  const CreateEventDialog({super.key});

  @override
  ConsumerState<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends ConsumerState<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _venueController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _venueController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    if (_slugController.text.isEmpty ||
        _slugController.text == _slugify(_nameController.text.substring(0, _nameController.text.length - 1))) {
      _slugController.text = _slugify(value);
    }
  }

  String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newEvent = EventModel(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      shareSlug: _slugController.text.trim(),
      venue: _venueController.text.trim(),
      description: _descController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      createdAt: DateTime.now(),
    );

    final dao = ref.read(eventDaoProvider);
    await dao.createEvent(newEvent);

    // Auto-seed Cricket (Outdoor) and Volleyball (Outdoor) with scheduled fixtures
    final sportDao = ref.read(sportDaoProvider);
    final matchDao = ref.read(matchDaoProvider);
    final stateDao = ref.read(matchStateDaoProvider);

    final cricketSport = SportModel(
      id: 's_cricket_${newEvent.id}',
      eventId: newEvent.id,
      name: 'Cricket',
      category: SportCategory.outdoor,
      scoringModel: ScoringModel.runBased,
      iconName: 'trophy',
      createdAt: DateTime.now(),
    );
    await sportDao.createSport(cricketSport);

    final cricketMatch = MatchModel(
      id: 'm_cricket_${newEvent.id}',
      sportId: cricketSport.id,
      title: 'Dept of CS vs Dept of ME',
      teamA: 'Dept of CS',
      teamB: 'Dept of ME',
      status: MatchStatus.scheduled,
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      venue: 'Main Ground Pitch 1',
      stage: 'League Match',
      createdAt: DateTime.now(),
    );
    await matchDao.createMatch(cricketMatch);
    await stateDao.updateScore(
      matchId: cricketMatch.id,
      newScore: SportScore.createInitial(ScoringModel.runBased, sportName: 'Cricket'),
    );

    final volleyballSport = SportModel(
      id: 's_volleyball_${newEvent.id}',
      eventId: newEvent.id,
      name: 'Volleyball',
      category: SportCategory.outdoor,
      scoringModel: ScoringModel.setBased,
      iconName: 'shield',
      createdAt: DateTime.now(),
    );
    await sportDao.createSport(volleyballSport);

    final volleyballMatch = MatchModel(
      id: 'm_volleyball_${newEvent.id}',
      sportId: volleyballSport.id,
      title: 'Batch 2023 vs Batch 2024',
      teamA: 'Batch 2023',
      teamB: 'Batch 2024',
      status: MatchStatus.scheduled,
      scheduledTime: DateTime.now().add(const Duration(hours: 3)),
      venue: 'Volleyball Court A',
      stage: 'Semi-Final',
      createdAt: DateTime.now(),
    );
    await matchDao.createMatch(volleyballMatch);
    await stateDao.updateScore(
      matchId: volleyballMatch.id,
      newScore: SportScore.createInitial(ScoringModel.setBased, sportName: 'Volleyball'),
    );

    ref.invalidate(allEventsProvider);
    ref.invalidate(sportsForEventProvider(newEvent.id));

    if (mounted) {
      Navigator.of(context).pop(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
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
                      Text(
                        'Create University Fest',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Fest Name *',
                      hintText: 'e.g. PLEXUS 2026',
                      prefixIcon: Icon(LucideIcons.trophy, size: 18),
                    ),
                    onChanged: _onNameChanged,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter fest name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _slugController,
                    decoration: const InputDecoration(
                      labelText: 'Shareable URL Slug *',
                      hintText: 'e.g. plexus-2026',
                      prefixIcon: Icon(LucideIcons.link, size: 18),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter slug' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(
                      labelText: 'Campus Venue',
                      hintText: 'e.g. Main Athletic Stadium',
                      prefixIcon: Icon(LucideIcons.mapPin, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Annual Inter-College Sports Championship',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.globe,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Public Link: yourapp.com/event/${_slugController.text.isEmpty ? "your-fest" : _slugController.text}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Create Fest & Generate Share Link'),
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
