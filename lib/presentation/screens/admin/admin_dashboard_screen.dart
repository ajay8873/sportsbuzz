import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/events/models/event_model.dart';
import '../../../features/events/providers/event_providers.dart';
import '../../common/empty_state_view.dart';
import '../../../core/utils/share_util.dart';
import 'dialogs/create_event_dialog.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _copyShareLink(BuildContext context, String shareSlug) {
    final link = ShareUtil.getEventShareUrl(shareSlug);
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Fest link copied: $link')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(allEventsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Row(
          children: [
            Icon(LucideIcons.shieldCheck, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Admin Portal',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh Events',
            onPressed: () => ref.invalidate(allEventsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Create New Fest'),
        onPressed: () async {
          final newEvent = await showDialog<EventModel?>(
            context: context,
            builder: (_) => const CreateEventDialog(),
          );
          if (newEvent != null && context.mounted) {
            ref.invalidate(allEventsProvider);
            context.push('/admin/events/${newEvent.id}');
          }
        },
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'University Athletic Meets & Fests',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage sports fixtures, assign scorers, and broadcast live scores.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: eventsAsync.when(
                    data: (events) {
                      if (events.isEmpty) {
                        return EmptyStateView(
                          icon: LucideIcons.calendar,
                          title: 'No Active Fests Found',
                          message:
                              'Create your first college fest to start scheduling matches and live streams.',
                          action: ElevatedButton.icon(
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Create Fest'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const CreateEventDialog(),
                              );
                            },
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final dateFormat = DateFormat('MMM dd, yyyy');
                          final dateStr =
                              '${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate)}';

                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  context.push('/admin/events/${event.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySurface,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppColors.border),
                                          ),
                                          child: const Icon(
                                            LucideIcons.trophy,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              ),
                                              if (event.venue != null) ...[
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      LucideIcons.mapPin,
                                                      size: 13,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        event.venue!,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton.outlined(
                                              icon: const Icon(
                                                  LucideIcons.share2,
                                                  size: 16),
                                              tooltip: 'Share Link',
                                              onPressed: () => _copyShareLink(
                                                  context, event.shareSlug),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton.filled(
                                              icon: const Icon(
                                                  LucideIcons.settings,
                                                  size: 16),
                                              tooltip: 'Manage Fest',
                                              onPressed: () => context.push(
                                                  '/admin/events/${event.id}'),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton.outlined(
                                              icon: const Icon(
                                                  LucideIcons.trash2,
                                                  color: Colors.redAccent,
                                                  size: 16),
                                              tooltip: 'Delete Fest',
                                              onPressed: () => _confirmDeleteFest(
                                                  context, ref, event),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (event.description != null &&
                                        event.description!.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        event.description!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                    const Divider(height: 20),
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      spacing: 12,
                                      runSpacing: 6,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.calendar,
                                                size: 14,
                                                color: AppColors.textMuted),
                                            const SizedBox(width: 6),
                                            Text(
                                              dateStr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Slug: /event/${event.shareSlug}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteFest(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Fest?'),
        content: Text(
          'Are you sure you want to delete "${event.name}"? All associated sports and fixtures will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final dao = ref.read(eventDaoProvider);
              await dao.deleteEvent(event.id);
              ref.invalidate(allEventsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${event.name}"')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
