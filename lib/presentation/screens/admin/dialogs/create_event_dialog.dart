import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/events/models/event_model.dart';
import '../../../../features/events/providers/event_providers.dart';
import '../../../../features/sports/providers/sport_providers.dart';
import '../../../../core/utils/share_util.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/admin_auth_service.dart';

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
  final _pinController = TextEditingController(text: '1234');

  final DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now().add(const Duration(days: 3));

  bool _isCustomSlug = false;
  bool _isCheckingSlug = false;
  bool _isSlugCollision = false;
  String _suggestedSlug = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _slugController.dispose();
    _venueController.dispose();
    _descController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _checkSlugAvailability(String rawSlug) {
    _debounceTimer?.cancel();
    final slug = _slugify(rawSlug);
    if (slug.isEmpty) {
      setState(() {
        _isSlugCollision = false;
        _suggestedSlug = '';
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _isCheckingSlug = true);
      final dao = ref.read(eventDaoProvider);
      final isTaken = await dao.isSlugTaken(slug);
      if (!mounted) return;
      if (isTaken) {
        final unique = await dao.resolveUniqueSlug(slug);
        if (mounted) {
          setState(() {
            _isCheckingSlug = false;
            _isSlugCollision = true;
            _suggestedSlug = unique;
          });
        }
      } else {
        setState(() {
          _isCheckingSlug = false;
          _isSlugCollision = false;
          _suggestedSlug = '';
        });
      }
    });
  }

  void _onNameChanged(String value) {
    if (!_isCustomSlug) {
      _slugController.text = _slugify(value);
      _checkSlugAvailability(_slugController.text);
    }
    setState(() {});
  }

  String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(eventDaoProvider);
    final rawSlug = _slugController.text.trim().toLowerCase();
    final finalSlug = await dao.resolveUniqueSlug(rawSlug);

    final uuid = const Uuid();
    final eventId = uuid.v4();

    final newEvent = EventModel(
      id: eventId,
      name: _nameController.text.trim(),
      shareSlug: finalSlug,
      venue: _venueController.text.trim(),
      description: _descController.text.trim(),
      adminPin: _pinController.text.trim().isEmpty ? '1234' : _pinController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      createdAt: DateTime.now(),
    );

    await dao.createEvent(newEvent);

    // Auto-unlock & mark as shared for event creator on this device
    await ref.read(unlockedEventsProvider.notifier).unlock(newEvent.id);
    await ref.read(sharedTournamentsProvider.notifier).addSharedEvent(newEvent.id);

    ref.invalidate(allEventsProvider);
    ref.invalidate(adminSharedEventsProvider);
    ref.invalidate(sportsForEventProvider(newEvent.id));

    if (mounted) {
      if (finalSlug != rawSlug) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notice: "$rawSlug" was already taken. Unique link assigned: "$finalSlug"'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      Navigator.of(context).pop(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSlug = _slugController.text.trim();
    final previewSlug = currentSlug.isNotEmpty ? currentSlug : 'your-fest';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SizedBox(
          width: double.infinity,
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
                      decoration: InputDecoration(
                        labelText: 'Shareable URL Slug *',
                        hintText: 'e.g. plexus-2026',
                        prefixIcon: const Icon(LucideIcons.link, size: 18),
                        suffixIcon: _isCheckingSlug
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        _isCustomSlug = val.trim().isNotEmpty;
                        _checkSlugAvailability(val);
                        setState(() {});
                      },
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Please enter slug' : null,
                    ),
                    if (_isSlugCollision && _suggestedSlug.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.info, size: 14, color: Colors.amber.shade900),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Name taken! Will auto-resolve to: "$_suggestedSlug"',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _slugController.text = _suggestedSlug;
                                  _isSlugCollision = false;
                                });
                              },
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.amber.shade900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      decoration: const InputDecoration(
                        labelText: 'Organizer / Scorer PIN *',
                        hintText: 'e.g. 1234',
                        counterText: '',
                        prefixIcon: Icon(LucideIcons.lock, size: 18),
                        helperText: 'Passcode required to edit matches & live scorecards',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Please enter an organizer PIN' : null,
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
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.globe,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Public Link: ${ShareUtil.getEventShareUrl(previewSlug)}',
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
      ),
    );
  }
}
