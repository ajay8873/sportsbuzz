import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/events/providers/event_providers.dart';
import '../../../features/sports/models/sport_category.dart';
import '../../../features/sports/models/sport_model.dart';
import '../../../features/sports/providers/sport_providers.dart';
import '../../../features/matches/models/match_model.dart';
import '../../../features/matches/models/match_status.dart';
import '../../../features/matches/providers/match_providers.dart';
import '../../common/empty_state_view.dart';
import '../../common/status_badge.dart';
import 'dialogs/create_sport_dialog.dart';
import 'dialogs/create_match_dialog.dart';
import 'dialogs/edit_match_dialog.dart';

import '../../../core/utils/share_util.dart';

class AdminEventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const AdminEventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<AdminEventDetailScreen> createState() =>
      _AdminEventDetailScreenState();
}

class _AdminEventDetailScreenState
    extends ConsumerState<AdminEventDetailScreen> {
  SportCategory _activeCategory = SportCategory.outdoor;
  String? _selectedSportId;

  void _copyShareLink(String shareSlug) {
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
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventByIdProvider(widget.eventId));
    final sportsAsync = ref.watch(sportsForEventProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin'),
        ),
        title: eventAsync.when(
          data: (event) => Text(event?.name ?? 'Event Management'),
          loading: () => const Text('Loading Fest...'),
          error: (_, __) => const Text('Event Management'),
        ),
        actions: [
          eventAsync.maybeWhen(
            data: (event) => event != null
                ? IconButton(
                    icon: const Icon(LucideIcons.share2),
                    tooltip: 'Share Fest Link',
                    onPressed: () => _copyShareLink(event.shareSlug),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(eventByIdProvider(widget.eventId));
              ref.invalidate(sportsForEventProvider(widget.eventId));
            },
          ),
        ],
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const EmptyStateView(
              title: 'Fest Not Found',
              message: 'The requested event could not be found.',
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.calendar,
                                              size: 14, color: AppColors.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${DateFormat("MMM d").format(event.startDate)} - ${DateFormat("MMM d, yyyy").format(event.endDate)}',
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
                                                size: 14, color: AppColors.textMuted),
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
                            IconButton.outlined(
                              icon: const Icon(LucideIcons.externalLink, size: 16),
                              tooltip: 'View Public Page',
                              onPressed: () =>
                                  context.push('/event/${event.shareSlug}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Switcher (Indoor / Outdoor)
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SegmentedButton<SportCategory>(
                          segments: const [
                            ButtonSegment(
                              value: SportCategory.outdoor,
                              label: Text('Outdoor Games'),
                              icon: Icon(LucideIcons.sun, size: 16),
                            ),
                            ButtonSegment(
                              value: SportCategory.indoor,
                              label: Text('Indoor Games'),
                              icon: Icon(LucideIcons.home, size: 16),
                            ),
                          ],
                          selected: {_activeCategory},
                          onSelectionChanged: (set) {
                            setState(() {
                              _activeCategory = set.first;
                              _selectedSportId = null;
                            });
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Add Sport'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  CreateSportDialog(eventId: widget.eventId),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sports Chips List
                    sportsAsync.when(
                      data: (sports) {
                        final filteredSports = sports
                            .where((s) => s.category == _activeCategory)
                            .toList();

                        if (filteredSports.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Text(
                                'No ${_activeCategory.label} sports added yet. Tap "Add Sport" to add one.',
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }

                        // Auto-select first if none selected
                        if (_selectedSportId == null &&
                            filteredSports.isNotEmpty) {
                          _selectedSportId = filteredSports.first.id;
                        }

                        final selectedSport = filteredSports.firstWhere(
                          (s) => s.id == _selectedSportId,
                          orElse: () => filteredSports.first,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: filteredSports.map((sport) {
                                  final isSelected =
                                      sport.id == _selectedSportId;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(sport.name),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() =>
                                              _selectedSportId = sport.id);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Fixtures Section for Selected Sport
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${selectedSport.name} Fixtures',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                      'Scoring Model: ${selectedSport.scoringModel.label}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                                  ElevatedButton.icon(
                                    icon: const Icon(LucideIcons.plus,
                                        size: 16),
                                    label: const Text('Schedule Match'),
                                    onPressed: () async {
                                      final created = await showDialog(
                                        context: context,
                                        builder: (_) => CreateMatchDialog(
                                          sportId: selectedSport.id,
                                          sportName: selectedSport.name,
                                          scoringModel:
                                              selectedSport.scoringModel,
                                        ),
                                      );
                                      if (created != null) {
                                        ref.invalidate(matchesForSportProvider(selectedSport.id));
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SportFixturesList(sport: selectedSport),
                          ],
                        );
                      },
                      loading: () => const Center(
                          child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )),
                      error: (e, _) => Text('Error loading sports: $e'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SportFixturesList extends ConsumerWidget {
  final SportModel sport;

  const _SportFixturesList({required this.sport});

  void _confirmDeleteMatch(BuildContext context, WidgetRef ref, MatchModel match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Match Fixture?'),
        content: Text(
          'Are you sure you want to delete the fixture "${match.teamA} vs ${match.teamB}"? This will permanently delete all scores and live data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.liveRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(matchDaoProvider).deleteMatch(match.id);
              ref.invalidate(matchesForSportProvider(match.sportId));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Match "${match.teamA} vs ${match.teamB}" deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesForSportProvider(sport.id));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return EmptyStateView(
            icon: LucideIcons.calendarX,
            title: 'No Matches Scheduled',
            message:
                'Tap "Schedule Match" to add fixtures for ${sport.name}.',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final match = matches[index];
            final timeFormat = DateFormat('h:mm a, MMM d');

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Stage, Status Badge, & Match Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (match.stage != null)
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.trophy,
                                    size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    match.stage!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Spacer(),
                        StatusBadge(status: match.status, compact: true),
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: const Icon(LucideIcons.ellipsisVertical,
                              size: 16, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          tooltip: 'Match Options',
                          onSelected: (action) {
                            if (action == 'edit') {
                              showDialog(
                                context: context,
                                builder: (_) => EditMatchDialog(match: match),
                              );
                            } else if (action == 'delete') {
                              _confirmDeleteMatch(context, ref, match);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.pencil,
                                      size: 15, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Edit Fixture'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.trash2,
                                      size: 15, color: AppColors.liveRed),
                                  SizedBox(width: 8),
                                  Text('Delete Fixture',
                                      style:
                                          TextStyle(color: AppColors.liveRed)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Prominent Match Teams Display & Action Button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match.teamA,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                match.teamB,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: match.status == MatchStatus.live
                                ? AppColors.liveRed
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          icon: Icon(
                            match.status == MatchStatus.live
                                ? LucideIcons.radio
                                : LucideIcons.edit3,
                            size: 15,
                          ),
                          label: Text(
                            match.status == MatchStatus.live
                                ? 'Live Scorer'
                                : 'Score Match',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => context.push(
                              '/admin/matches/${match.id}/score'),
                        ),
                      ],
                    ),
                    const Divider(height: 18),

                    // Footer: Time & Venue
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.clock,
                                size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(match.scheduledTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (match.venue != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.mapPin,
                                  size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                match.venue!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      )),
      error: (e, _) => Text('Error loading matches: $e'),
    );
  }
}
