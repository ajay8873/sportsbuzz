import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/events/models/event_model.dart';
import '../../../../features/events/providers/event_providers.dart';
import '../../../../core/services/auth_service.dart';

class ManageCoAdminsDialog extends ConsumerStatefulWidget {
  final EventModel event;

  const ManageCoAdminsDialog({super.key, required this.event});

  @override
  ConsumerState<ManageCoAdminsDialog> createState() => _ManageCoAdminsDialogState();
}

class _ManageCoAdminsDialogState extends ConsumerState<ManageCoAdminsDialog> {
  final TextEditingController _emailController = TextEditingController();
  late List<String> _admins;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _admins = List.from(widget.event.adminEmails);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addEmail() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    if (AuthService.isSuperAdminEmail(email)) {
      setState(() => _error = 'This email is a global Superadmin (already has full access).');
      return;
    }

    if (widget.event.creatorEmail != null &&
        widget.event.creatorEmail!.trim().toLowerCase() == email) {
      setState(() => _error = 'This user is already the primary Tournament Creator.');
      return;
    }

    if (_admins.contains(email)) {
      setState(() => _error = 'This email is already an authorized co-admin.');
      return;
    }

    setState(() {
      _error = null;
      _admins.add(email);
      _emailController.clear();
    });

    await _saveChanges();
  }

  Future<void> _removeEmail(String email) async {
    setState(() {
      _admins.remove(email);
    });
    await _saveChanges();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final updated = widget.event.copyWith(adminEmails: _admins);
      await ref.read(eventDaoProvider).updateEvent(updated);
      ref.invalidate(eventByIdProvider(widget.event.id));
      ref.invalidate(allEventsProvider);
      ref.invalidate(adminSharedEventsProvider);
    } catch (e) {
      setState(() => _error = 'Failed to save changes: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.event.creatorEmail ?? 'Organizer (Initial Device)';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tournament Admin Authority',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Spectators with the link can only view scores. Only authorized emails below have editing & scoring authority for "${widget.event.name}".',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Superadmin card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.crown, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Global Superadmins (Supabase SQL)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SUPERADMIN',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Creator Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shieldAlert, color: AppColors.zestOrange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        creator,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.zestOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'CREATOR',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Co-Admins Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AUTHORIZED CO-ADMINS (${_admins.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_isSaving)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (_admins.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'No additional co-admins added yet. Add trusted scorers or organizers below.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else ...[
                ..._admins.map((email) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.mail, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.liveRed),
                          tooltip: 'Revoke Admin Access',
                          onPressed: () => _removeEmail(email),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 16),

              // Add Email Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Add Co-Admin Email',
                        hintText: 'e.g. scorer@college.edu',
                        prefixIcon: Icon(LucideIcons.userPlus, size: 16),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _addEmail(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _addEmail,
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.liveRed, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
