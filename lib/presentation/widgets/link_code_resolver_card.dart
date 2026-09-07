import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/events/models/event_model.dart';
import '../../features/events/providers/event_providers.dart';

class LinkCodeResolverCard extends ConsumerStatefulWidget {
  const LinkCodeResolverCard({super.key});

  @override
  ConsumerState<LinkCodeResolverCard> createState() => _LinkCodeResolverCardState();
}

class _LinkCodeResolverCardState extends ConsumerState<LinkCodeResolverCard> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resolveAndNavigate() async {
    final rawInput = _controller.text.trim();
    if (rawInput.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a match link, event URL, or fest code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Check if it is a match URL (e.g. /match/123 or https://domain.com/match/123)
      if (rawInput.contains('/match/') || rawInput.contains('/matches/')) {
        final uri = Uri.tryParse(rawInput);
        String? matchId;
        if (uri != null && uri.pathSegments.isNotEmpty) {
          final idx = uri.pathSegments.indexWhere(
              (seg) => seg == 'match' || seg == 'matches');
          if (idx != -1 && idx + 1 < uri.pathSegments.length) {
            matchId = uri.pathSegments[idx + 1];
          }
        }
        matchId ??= rawInput.split('/match/').last.split('?').first.trim();
        if (matchId.isNotEmpty) {
          if (mounted) setState(() => _isLoading = false);
          context.push('/match/$matchId');
          return;
        }
      }

      // 2. Check if it is an event URL (e.g. /event/plexus-2026 or https://domain.com/event/plexus-2026)
      String? slug;
      if (rawInput.contains('/event/')) {
        final uri = Uri.tryParse(rawInput);
        if (uri != null && uri.pathSegments.isNotEmpty) {
          final idx = uri.pathSegments.indexOf('event');
          if (idx != -1 && idx + 1 < uri.pathSegments.length) {
            slug = uri.pathSegments[idx + 1];
          }
        }
        slug ??= rawInput.split('/event/').last.split('?').first.trim();
      }

      // 3. Extract clean query or slug
      slug ??= rawInput
          .replaceAll(RegExp(r'^https?://[^/]+/'), '')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '')
          .toLowerCase();

      if (slug.isNotEmpty) {
        final dao = ref.read(eventDaoProvider);
        final matches = await dao.findEvents(slug);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (matches.length > 1) {
          // Multiple tournaments found with similar names - show disambiguation picker!
          _showDisambiguationSheet(matches);
          return;
        } else if (matches.length == 1) {
          context.push('/event/${matches.first.shareSlug}');
          return;
        } else {
          // Try navigation directly to slug/ID
          context.push('/event/$slug');
          return;
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not parse this link. Enter an event code like "fest-2026".';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid link format. Please check the URL or code.';
        });
      }
    }
  }

  void _showDisambiguationSheet(List<EventModel> matches) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.trophy, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Multiple Tournaments Found',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'More than one tournament matches your search. Please choose yours:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ...matches.map((event) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.trophy, color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      event.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.venue != null && event.venue!.isNotEmpty)
                          Text('📍 ${event.venue}', style: const TextStyle(fontSize: 12)),
                        Text(
                          'Dates: ${DateFormat("MMM d").format(event.startDate)} - ${DateFormat("MMM d, yyyy").format(event.endDate)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          'Code: ${event.shareSlug}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/event/${event.shareSlug}');
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.surface, AppColors.surfaceAlt],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.link2,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have an invite code or link?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Paste any shared spectator URL or enter an event code',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Input field with action button
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _errorMessage != null ? AppColors.liveRed : AppColors.border,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _resolveAndNavigate(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'e.g. event/zenith-2026 or paste invite link',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      color: AppColors.textMuted,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: const Size(40, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _resolveAndNavigate,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.arrowRight, size: 18),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 14,
                    color: AppColors.liveRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.liveRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
