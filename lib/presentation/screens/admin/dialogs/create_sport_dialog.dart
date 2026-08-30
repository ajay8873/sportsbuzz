import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../features/sports/models/sport_model.dart';
import '../../../../features/sports/models/sport_category.dart';
import '../../../../features/sports/models/scoring_model.dart';
import '../../../../features/sports/providers/sport_providers.dart';
import '../../../../features/matches/models/match_model.dart';
import '../../../../features/matches/models/match_status.dart';
import '../../../../features/matches/models/sport_score.dart';
import '../../../../features/matches/providers/match_providers.dart';
import 'package:uuid/uuid.dart';

class SportPreset {
  final String name;
  final SportCategory category;
  final ScoringModel scoringModel;
  final String iconName;

  const SportPreset({
    required this.name,
    required this.category,
    required this.scoringModel,
    this.iconName = 'trophy',
  });
}

const List<SportPreset> kSportPresets = [
  SportPreset(
    name: 'Cricket',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.runBased,
    iconName: 'trophy',
  ),
  SportPreset(
    name: 'Football / Soccer',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.timeBased,
    iconName: 'activity',
  ),
  SportPreset(
    name: 'Volleyball',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.setBased,
    iconName: 'shield',
  ),
  SportPreset(
    name: 'Basketball',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.timeBased,
    iconName: 'activity',
  ),
  SportPreset(
    name: 'Badminton',
    category: SportCategory.indoor,
    scoringModel: ScoringModel.setBased,
    iconName: 'activity',
  ),
  SportPreset(
    name: 'Table Tennis',
    category: SportCategory.indoor,
    scoringModel: ScoringModel.setBased,
    iconName: 'activity',
  ),
  SportPreset(
    name: 'Tennis',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.setBased,
    iconName: 'activity',
  ),
  SportPreset(
    name: 'Kabaddi',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.timeBased,
    iconName: 'swords',
  ),
  SportPreset(
    name: 'Hockey',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.timeBased,
    iconName: 'activity',
  ),
  SportPreset(
    name: 'Chess',
    category: SportCategory.indoor,
    scoringModel: ScoringModel.boardBased,
    iconName: 'crown',
  ),
  SportPreset(
    name: 'Carrom',
    category: SportCategory.indoor,
    scoringModel: ScoringModel.boardBased,
    iconName: 'target',
  ),
  SportPreset(
    name: 'Tug of War',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.matchBased,
    iconName: 'swords',
  ),
  SportPreset(
    name: 'Athletics / Sprint',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.matchBased,
    iconName: 'flame',
  ),
  SportPreset(
    name: 'Custom Sport',
    category: SportCategory.outdoor,
    scoringModel: ScoringModel.timeBased,
    iconName: 'trophy',
  ),
];

class CreateSportDialog extends ConsumerStatefulWidget {
  final String eventId;

  const CreateSportDialog({super.key, required this.eventId});

  @override
  ConsumerState<CreateSportDialog> createState() => _CreateSportDialogState();
}

class _CreateSportDialogState extends ConsumerState<CreateSportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Cricket');

  SportPreset _selectedPreset = kSportPresets.first;
  late SportCategory _category;
  late ScoringModel _scoringModel;

  @override
  void initState() {
    super.initState();
    _category = _selectedPreset.category;
    _scoringModel = _selectedPreset.scoringModel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onPresetChanged(SportPreset? preset) {
    if (preset == null) return;
    setState(() {
      _selectedPreset = preset;
      _category = preset.category;
      _scoringModel = preset.scoringModel;
      if (preset.name != 'Custom Sport') {
        _nameController.text = preset.name;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uuid = const Uuid();
    final sportId = uuid.v4();

    final newSport = SportModel(
      id: sportId,
      eventId: widget.eventId,
      name: _nameController.text.trim(),
      category: _category,
      scoringModel: _scoringModel,
      iconName: _selectedPreset.iconName,
      createdAt: DateTime.now(),
    );

    final dao = ref.read(sportDaoProvider);
    await dao.createSport(newSport);

    ref.invalidate(sportsForEventProvider(widget.eventId));

    if (mounted) {
      Navigator.of(context).pop(newSport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                          'Add Sport to Fest',
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

                  // Select Sport Preset Dropdown
                  Text(
                    'SELECT SPORT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SportPreset>(
                    value: _selectedPreset,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(LucideIcons.trophy, size: 18),
                    ),
                    items: kSportPresets.map((preset) {
                      return DropdownMenuItem(
                        value: preset,
                        child: Text(
                          preset.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _onPresetChanged,
                  ),
                  const SizedBox(height: 16),

                  // Customized Display Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tournament / Event Name *',
                      hintText: 'e.g. Mens Volleyball Championship',
                      prefixIcon: Icon(LucideIcons.activity, size: 18),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter sport name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Sport Category Toggle
                  Text(
                    'SPORT CATEGORY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(LucideIcons.sun, size: 16),
                          label: const Text('Outdoor Game'),
                          selected: _category == SportCategory.outdoor,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _category = SportCategory.outdoor);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(LucideIcons.home, size: 16),
                          label: const Text('Indoor Game'),
                          selected: _category == SportCategory.indoor,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _category = SportCategory.indoor);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Sport to Event'),
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
