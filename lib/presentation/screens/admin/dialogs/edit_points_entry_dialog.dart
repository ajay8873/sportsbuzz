import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/events/models/fest_points_model.dart';
import '../../../../features/sports/providers/sport_providers.dart';

/// Popular collegiate fest sports for instant points recording
const List<String> kFestPopularSports = [
  'Cricket',
  'Football / Soccer',
  'Volleyball',
  'Basketball',
  'Badminton',
  'Table Tennis',
  'Tennis',
  'Kabaddi',
  'Kho-Kho',
  'Athletics / Track & Field',
  'Chess',
  'Carrom',
  'Hockey',
  'Tug of War',
  'Swimming',
  'Esports / Gaming',
  'Powerlifting',
];

class EditPointsEntryDialog extends ConsumerStatefulWidget {
  final String eventId;
  final FestPointsEntry? initialEntry;

  const EditPointsEntryDialog({
    super.key,
    required this.eventId,
    this.initialEntry,
  });

  @override
  ConsumerState<EditPointsEntryDialog> createState() =>
      _EditPointsEntryDialogState();
}

class _EditPointsEntryDialogState extends ConsumerState<EditPointsEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _contenderType;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _pointsController;
  late TextEditingController _customSportController;

  String? _selectedSportId;
  String? _selectedSportName;
  bool _isCustomSport = false;

  int _played = 0;
  int _won = 0;
  int _lost = 0;
  int _drawn = 0;
  bool _autoCalculate = true;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _contenderType = entry?.contenderType ?? 'team';
    _nameController = TextEditingController(text: entry?.name ?? '');
    _categoryController = TextEditingController(text: entry?.category ?? '');
    _customSportController = TextEditingController();
    _selectedSportId = entry?.sportId;
    _selectedSportName = entry?.sportName;

    if (entry != null &&
        entry.sportName != null &&
        entry.sportName!.isNotEmpty &&
        entry.sportName != 'All Sports') {
      _selectedSportName = entry.sportName;
      final matchesStandard = kFestPopularSports.any(
          (s) => s.toLowerCase() == entry.sportName!.trim().toLowerCase());
      if (!matchesStandard &&
          (entry.sportId == null || entry.sportId!.startsWith('custom_'))) {
        _isCustomSport = true;
        _selectedSportId = 'custom_sport_choice';
        _customSportController.text = entry.sportName!;
      }
    }

    _played = entry?.played ?? 0;
    _won = entry?.won ?? 0;
    _lost = entry?.lost ?? 0;
    _drawn = entry?.drawn ?? 0;

    final initialPts = entry != null
        ? entry.points
        : (_won * 2) + (_drawn * 1);
    _pointsController = TextEditingController(text: '$initialPts');

    if (entry != null && entry.points != (_won * 2) + (_drawn * 1)) {
      _autoCalculate = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _pointsController.dispose();
    _customSportController.dispose();
    super.dispose();
  }

  void _recalcPoints() {
    if (_autoCalculate) {
      final calculated = (_won * 2) + (_drawn * 1);
      _pointsController.text = '$calculated';
    }
    // Automatically keep played in sync if auto-sync
    if (_played < (_won + _lost + _drawn)) {
      setState(() {
        _played = _won + _lost + _drawn;
      });
    }
  }

  String _getNameHint() {
    switch (_contenderType) {
      case 'team':
        return 'e.g. Red Warriors, Titans Club';
      case 'batch':
        return 'e.g. Batch 2022 (Excalibur)';
      case 'individual':
        return 'e.g. Rahul Sharma, Priya Nair';
      default:
        return 'e.g. House Phoenix';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialEntry != null;
    final sportsAsync = ref.watch(sportsForEventProvider(widget.eventId));

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.trophy,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing ? 'Edit Standings Entry' : 'Add Standings Entry',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Sport Selector
                  const Text(
                    'SPORT / EVENT CATEGORY:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  sportsAsync.when(
                    data: (sports) {
                      final items = <DropdownMenuItem<String?>>[
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Sports / Overall Standings'),
                        ),
                      ];

                      // 1. Configured Tournament Sports
                      for (final s in sports) {
                        items.add(
                          DropdownMenuItem<String?>(
                            value: s.id,
                            child: Text('${s.name} (Tournament Sport)'),
                          ),
                        );
                      }

                      // 2. Standard Collegiate Sports
                      for (final stdSport in kFestPopularSports) {
                        final alreadyAdded = sports.any(
                            (s) => s.name.toLowerCase() == stdSport.toLowerCase());
                        if (alreadyAdded) continue;

                        final stdVal =
                            'std_${stdSport.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
                        items.add(
                          DropdownMenuItem<String?>(
                            value: stdVal,
                            child: Text(stdSport),
                          ),
                        );
                      }

                      // 3. Custom Sport Option
                      items.add(
                        const DropdownMenuItem<String?>(
                          value: 'custom_sport_choice',
                          child: Text(
                            '+ Add Other / Custom Sport...',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );

                      // Ensure selected value is valid
                      String? currentVal =
                          _isCustomSport ? 'custom_sport_choice' : _selectedSportId;
                      final valExists = items.any((it) => it.value == currentVal);
                      if (!valExists) {
                        currentVal = null;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String?>(
                            initialValue: currentVal,
                            decoration: const InputDecoration(
                              hintText: 'Select Sport (or All Sports)',
                              prefixIcon: Icon(LucideIcons.gamepad2, size: 18),
                            ),
                            items: items,
                            onChanged: (val) {
                              setState(() {
                                if (val == null) {
                                  _selectedSportId = null;
                                  _selectedSportName = 'All Sports';
                                  _isCustomSport = false;
                                } else if (val == 'custom_sport_choice') {
                                  _selectedSportId = 'custom_sport_choice';
                                  _isCustomSport = true;
                                  _selectedSportName =
                                      _customSportController.text.trim();
                                } else if (val.startsWith('std_')) {
                                  _selectedSportId = val;
                                  _isCustomSport = false;
                                  final found = kFestPopularSports.firstWhere(
                                    (s) =>
                                        'std_${s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}' ==
                                        val,
                                    orElse: () => val,
                                  );
                                  _selectedSportName = found;
                                } else {
                                  _selectedSportId = val;
                                  _isCustomSport = false;
                                  final found = sports.firstWhere(
                                    (s) => s.id == val,
                                    orElse: () => sports.first,
                                  );
                                  _selectedSportName = found.name;
                                }
                              });
                            },
                          ),
                          if (_isCustomSport) ...[
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _customSportController,
                              decoration: const InputDecoration(
                                labelText: 'Custom Sport Name *',
                                hintText:
                                    'e.g. Dodgeball, Kho-Kho, Arm Wrestling',
                                prefixIcon:
                                    Icon(LucideIcons.activity, size: 18),
                              ),
                              validator: (val) {
                                if (_isCustomSport &&
                                    (val == null || val.trim().isEmpty)) {
                                  return 'Please enter the custom sport name';
                                }
                                return null;
                              },
                              onChanged: (val) {
                                setState(() {
                                  _selectedSportName = val.trim();
                                });
                              },
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

                  // 2. Contender Type Selector
                  const Text(
                    'AWARD POINTS TO:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTypeChip('team', 'Team / Club', LucideIcons.users),
                      _buildTypeChip('batch', 'Batch / Dept', LucideIcons.graduationCap),
                      _buildTypeChip('individual', 'Individual', LucideIcons.user),
                      _buildTypeChip('house', 'House / Dorm', LucideIcons.shield),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Contender Name Input
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Contender / Team Name *',
                      hintText: _getNameHint(),
                      prefixIcon: const Icon(LucideIcons.medal, size: 18),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter contender or team name'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // 4. Group / Division / Subtitle (Optional)
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Group / Pool / Division (Optional)',
                      hintText: 'e.g. Group A, Finals Pool, Batch 2022',
                      prefixIcon: Icon(LucideIcons.tag, size: 18),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Match Record Counters (Played, Won, Defeat, Draw)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MATCH RECORD & STATS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              '2 pts/Win • 1 pt/Draw',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stats Grid (Played, Won, Defeat, Draw)
                        Row(
                          children: [
                            Expanded(
                              child: _buildCounterCard(
                                label: 'PLAYED (P)',
                                value: _played,
                                color: AppColors.textPrimary,
                                onChanged: (val) {
                                  setState(() => _played = val < 0 ? 0 : val);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCounterCard(
                                label: 'WON (W)',
                                value: _won,
                                color: AppColors.cricbuzzGreen,
                                onChanged: (val) {
                                  setState(() {
                                    _won = val < 0 ? 0 : val;
                                    _recalcPoints();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCounterCard(
                                label: 'DEFEAT (L)',
                                value: _lost,
                                color: AppColors.liveRed,
                                onChanged: (val) {
                                  setState(() {
                                    _lost = val < 0 ? 0 : val;
                                    _recalcPoints();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCounterCard(
                                label: 'DRAW (D)',
                                value: _drawn,
                                color: const Color(0xFFD97706),
                                onChanged: (val) {
                                  setState(() {
                                    _drawn = val < 0 ? 0 : val;
                                    _recalcPoints();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Total Points
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.award,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Points (PTS)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Auto: (Wins × 2) + (Draws × 1)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              isDense: true,
                            ),
                            onChanged: (val) {
                              _autoCalculate = false;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final finalSportName = _isCustomSport
                ? _customSportController.text.trim()
                : (_selectedSportName ?? 'All Sports');
            final finalSportId = _isCustomSport
                ? 'custom_${finalSportName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}'
                : _selectedSportId;

            final pts = int.tryParse(_pointsController.text.trim()) ??
                ((_won * 2) + (_drawn * 1));
            final entry = FestPointsEntry(
              id: widget.initialEntry?.id ?? const Uuid().v4(),
              eventId: widget.eventId,
              sportId: finalSportId,
              sportName: finalSportName,
              contenderType: _contenderType,
              name: _nameController.text.trim(),
              category: _categoryController.text.trim().isEmpty
                  ? null
                  : _categoryController.text.trim(),
              played: _played,
              won: _won,
              lost: _lost,
              drawn: _drawn,
              points: pts,
              updatedAt: DateTime.now(),
            );

            Navigator.of(context).pop(entry);
          },
          child: Text(isEditing ? 'Update Entry' : 'Save Entry'),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _contenderType == type;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      onSelected: (val) {
        if (val) {
          setState(() {
            _contenderType = type;
          });
        }
      },
    );
  }

  Widget _buildCounterCard({
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => onChanged(value > 0 ? value - 1 : 0),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.minus, size: 12),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              InkWell(
                onTap: () => onChanged(value + 1),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.plus, size: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
