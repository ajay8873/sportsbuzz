import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/events/models/event_model.dart';
import '../../features/events/providers/event_providers.dart';
import '../common/empty_state_view.dart';
import 'admin/dialogs/create_event_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(allEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(LucideIcons.flame, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('SportsBuzz Campus'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.shieldCheck),
            tooltip: 'Admin & Scorer Console',
            onPressed: () => context.push('/admin'),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Banner Card
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primarySurface, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.trophy,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'College Sports & Fests Arena',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Live multi-sport scoreboards, fixture schedules & streaming.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Big Hero Action Button to Create Event
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(LucideIcons.plusCircle, size: 20),
                            label: const Text(
                              'Create & Host New Fest',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () async {
                              final createdEvent =
                                  await showDialog<EventModel>(
                                context: context,
                                builder: (_) => const CreateEventDialog(),
                              );
                              if (createdEvent != null && context.mounted) {
                                context.push('/admin/events/${createdEvent.id}');
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton.icon(
                              icon:
                                  const Icon(LucideIcons.shieldCheck, size: 16),
                              label: const Text('Admin Management Console'),
                              onPressed: () => context.push('/admin'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Active College Fests Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'ACTIVE & UPCOMING UNIVERSITY FESTS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('Host a Fest'),
                      onPressed: () => context.push('/admin'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return EmptyStateView(
                        icon: LucideIcons.trophy,
                        title: 'No University Fests Yet',
                        message:
                            'Be the first to create and host a campus sports fest or athletic meet.',
                        action: ElevatedButton.icon(
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Create Fest'),
                          onPressed: () async {
                            final createdEvent =
                                await showDialog<EventModel>(
                              context: context,
                              builder: (_) => const CreateEventDialog(),
                            );
                            if (createdEvent != null && context.mounted) {
                              context.push('/admin/events/${createdEvent.id}');
                            }
                          },
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final dateFormat = DateFormat('MMM d, yyyy');

                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                context.push('/event/${event.shareSlug}'),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      LucideIcons.trophy,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
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
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 4,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(LucideIcons.calendar,
                                                    size: 13,
                                                    color: AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (event.venue != null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(LucideIcons.mapPin,
                                                      size: 13,
                                                      color: AppColors.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      event.venue!,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(LucideIcons.arrowRight,
                                      size: 18, color: AppColors.primary),
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
                  error: (e, _) => Text('Error loading events: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
