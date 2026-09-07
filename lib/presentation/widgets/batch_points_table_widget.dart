import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/events/models/event_model.dart';
import '../../features/events/models/fest_points_model.dart';
import '../../features/events/providers/event_providers.dart';
import '../../features/sports/providers/sport_providers.dart';
import '../../core/services/admin_auth_service.dart';
import '../screens/admin/dialogs/create_event_dialog.dart';
import '../screens/admin/dialogs/edit_points_entry_dialog.dart';

/// Live Fest Points Table / Standings Widget
/// Displays dynamic sports-wise standings (P, W, L, D, PTS).
/// Supports admin addition/editing and public spectator viewing.
class BatchPointsTableWidget extends ConsumerStatefulWidget {
  final EventModel? event;
  final bool showAdminControls;

  const BatchPointsTableWidget({
    super.key,
    this.event,
    this.showAdminControls = false,
  });

  @override
  ConsumerState<BatchPointsTableWidget> createState() =>
      _BatchPointsTableWidgetState();
}

class _BatchPointsTableWidgetState
    extends ConsumerState<BatchPointsTableWidget> {
  String _selectedFilter = 'all'; // 'all', 'batch', 'team', 'individual'
  String _selectedSportFilter = 'all'; // 'all' or specific sportId/name
  String? _selectedEventId;

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD97706); // Gold
      case 2:
        return const Color(0xFF64748B); // Silver
      case 3:
        return const Color(0xFFB45309); // Bronze
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return LucideIcons.crown;
      case 2:
        return LucideIcons.medal;
      case 3:
        return LucideIcons.award;
      default:
        return LucideIcons.circle;
    }
  }

  Future<void> _openAddOrEditEntryDialog(
    BuildContext context,
    EventModel currentEvent, [
    FestPointsEntry? existing,
  ]) async {
    final messenger = ScaffoldMessenger.of(context);
    final entry = await showDialog<FestPointsEntry>(
      context: context,
      builder: (_) => EditPointsEntryDialog(
        eventId: currentEvent.id,
        initialEntry: existing,
      ),
    );

    if (entry != null && mounted) {
      final list = List<FestPointsEntry>.from(currentEvent.standings);
      if (existing != null) {
        final idx = list.indexWhere((e) => e.id == existing.id);
        if (idx != -1) {
          list[idx] = entry;
        } else {
          list.add(entry);
        }
      } else {
        list.add(entry);
      }

      final updatedEvent = currentEvent.copyWith(standings: list);
      await ref.read(eventDaoProvider).updateEvent(updatedEvent);
      ref.invalidate(allEventsProvider);
      ref.invalidate(eventByIdProvider(currentEvent.id));
      ref.invalidate(eventBySlugProvider(currentEvent.shareSlug));

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.check, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  existing != null
                      ? 'Updated points for "${entry.name}"'
                      : 'Added "${entry.name}" to standings',
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteEntry(
    BuildContext context,
    EventModel currentEvent,
    FestPointsEntry entry,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Standings?'),
        content: Text(
          'Are you sure you want to remove "${entry.name}" from the points table?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.liveRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      final list = List<FestPointsEntry>.from(currentEvent.standings)
        ..removeWhere((e) => e.id == entry.id);

      final updatedEvent = currentEvent.copyWith(standings: list);
      await ref.read(eventDaoProvider).updateEvent(updatedEvent);
      ref.invalidate(allEventsProvider);
      ref.invalidate(eventByIdProvider(currentEvent.id));
      ref.invalidate(eventBySlugProvider(currentEvent.shareSlug));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event != null) {
      final canManage = widget.showAdminControls &&
          ref.watch(unlockedEventsProvider).contains(widget.event!.id);
      return _buildStandingsCard(
        context,
        widget.event!,
        canManage: canManage,
      );
    }

    final eventsAsync = ref.watch(allEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildNoEventsPlaceholder(context);
        }

        final currentEventId = _selectedEventId ?? events.first.id;
        final selectedEvent = events.firstWhere(
          (e) => e.id == currentEventId,
          orElse: () => events.first,
        );

        final canManage = widget.showAdminControls &&
            ref.watch(unlockedEventsProvider).contains(selectedEvent.id);

        return _buildStandingsCard(
          context,
          selectedEvent,
          allEvents: events,
          canManage: canManage,
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading standings: $err',
            style: const TextStyle(color: AppColors.liveRed),
          ),
        ),
      ),
    );
  }

  Widget _buildNoEventsPlaceholder(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.trophy,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Tournaments Active',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Host a fest or enter an invite link to view live sport standings and rankings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Host Tournament'),
              onPressed: () async {
                final created = await showDialog<EventModel>(
                  context: context,
                  builder: (_) => const CreateEventDialog(),
                );
                if (created != null && context.mounted) {
                  ref.invalidate(allEventsProvider);
                  context.push('/admin/events/${created.id}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsCard(
    BuildContext context,
    EventModel event, {
    List<EventModel>? allEvents,
    required bool canManage,
  }) {
    final sportsAsync = ref.watch(sportsForEventProvider(event.id));
    final standings = List<FestPointsEntry>.from(event.standings);

    // Sort by points desc, then won desc, then drawn desc
    standings.sort((a, b) {
      final cmpPts = b.points.compareTo(a.points);
      if (cmpPts != 0) return cmpPts;
      final cmpWon = b.won.compareTo(a.won);
      if (cmpWon != 0) return cmpWon;
      final cmpDrawn = b.drawn.compareTo(a.drawn);
      if (cmpDrawn != 0) return cmpDrawn;
      return a.name.compareTo(b.name);
    });

    final filteredList = standings.where((e) {
      // Sport filter
      if (_selectedSportFilter != 'all') {
        final matchesId = e.sportId == _selectedSportFilter;
        final matchesName = e.sportName == _selectedSportFilter;
        if (!matchesId && !matchesName) return false;
      }

      // Contender type filter
      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'team') {
        return e.contenderType == 'team' || e.contenderType == 'house';
      }
      return e.contenderType == _selectedFilter;
    }).toList();

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            LayoutBuilder(
              builder: (context, headerConstraints) {
                final isNarrow = headerConstraints.maxWidth < 520;

                final titleContent = Row(
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Points Table & Standings',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.name,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (allEvents != null && allEvents.length > 1) ...[
                      DropdownButton<String>(
                        value: event.id,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(LucideIcons.chevronDown, size: 16),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        items: allEvents.map((ev) {
                          return DropdownMenuItem(
                            value: ev.id,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: Text(
                                ev.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            setState(() => _selectedEventId = id);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (canManage)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: const Text(
                          'Add Points',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () =>
                            _openAddOrEditEntryDialog(context, event),
                      ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleContent,
                      if (allEvents != null && allEvents.length > 1 ||
                          canManage) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [actions],
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleContent),
                    actions,
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Sports-Wise Filter Selector
            sportsAsync.when(
              data: (sports) {
                // Collect configured event sports and any sport names from standings entries
                final sportOptions = <String, String>{}; // displayName -> filterValue
                for (final s in sports) {
                  sportOptions[s.name] = s.id;
                }
                for (final e in standings) {
                  if (e.sportName != null &&
                      e.sportName!.isNotEmpty &&
                      e.sportName != 'All Sports') {
                    sportOptions.putIfAbsent(
                        e.sportName!, () => e.sportId ?? e.sportName!);
                  }
                }

                if (sportOptions.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            avatar: const Icon(LucideIcons.layers, size: 14),
                            label: const Text('All Sports'),
                            selected: _selectedSportFilter == 'all',
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedSportFilter == 'all'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedSportFilter == 'all'
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedSportFilter = 'all');
                              }
                            },
                          ),
                          ...sportOptions.entries.map((entry) {
                            final isSelected =
                                _selectedSportFilter == entry.value ||
                                    _selectedSportFilter == entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ChoiceChip(
                                avatar:
                                    const Icon(LucideIcons.trophy, size: 14),
                                label: Text(entry.key),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() =>
                                        _selectedSportFilter = entry.value);
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Contender Type Filter Tabs (All / Batches / Teams / Athletes)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  _buildTab('all', 'All', LucideIcons.trophy),
                  _buildTab('batch', 'Batches', LucideIcons.graduationCap),
                  _buildTab('team', 'Teams', LucideIcons.users),
                  _buildTab('individual', 'Athletes', LucideIcons.user),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Table or Empty Standings
            if (filteredList.isEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.award,
                        size: 32, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    Text(
                      _selectedSportFilter == 'all'
                          ? 'No standings registered yet'
                          : 'No standings for this sport yet',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canManage
                          ? 'Tap "Add Points" above to record match results and points.'
                          : 'Standings will appear live once published by organizers.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, tableConstraints) {
                  const minTableWidth = 440.0;
                  final tableWidth = tableConstraints.maxWidth < minTableWidth
                      ? minTableWidth
                      : tableConstraints.maxWidth;

                  final tableContent = SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // Sports-Wise Table Header: RANK, TEAM/CONTENDER, P, W, L, D, PTS
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 34,
                                child: Text(
                                  '#',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'TEAM / CONTENDER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 32,
                                child: Text(
                                  'P',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 32,
                                child: Text(
                                  'W',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 32,
                                child: Text(
                                  'L',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.liveRed,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 32,
                                child: Text(
                                  'D',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 44,
                                child: Text(
                                  'PTS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (canManage) const SizedBox(width: 54),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Table Rows
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: AppColors.divider,
                          ),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final rank = index + 1;
                            final isTop3 = rank <= 3;
                            final rankColor = _getRankColor(rank);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  // Rank Badge
                                  SizedBox(
                                    width: 34,
                                    child: Row(
                                      children: [
                                        if (isTop3)
                                          Icon(
                                            _getRankIcon(rank),
                                            size: 15,
                                            color: rankColor,
                                          )
                                        else
                                          Text(
                                            '$rank',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Name + Subtitle + Sport Tag
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isTop3
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceAlt,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.contenderType.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            if (item.sportName != null &&
                                                item.sportName!.isNotEmpty &&
                                                item.sportName != 'All Sports') ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primarySurface,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.sportName!,
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (item.category != null &&
                                                item.category!.isNotEmpty) ...[
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  item.category!,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textMuted,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Played (P)
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${item.played}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),

                                  // Won (W)
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${item.won}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),

                                  // Lost (L)
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${item.lost}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.liveRed,
                                      ),
                                    ),
                                  ),

                                  // Drawn (D)
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${item.drawn}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ),

                                  // Points Badge (PTS)
                                  SizedBox(
                                    width: 44,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isTop3
                                            ? AppColors.primarySurface
                                            : AppColors.surfaceAlt,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isTop3
                                              ? AppColors.primary
                                                  .withValues(alpha: 0.3)
                                              : AppColors.border,
                                        ),
                                      ),
                                      child: Text(
                                        '${item.points}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: isTop3
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Admin Edit / Delete Actions
                                  if (canManage)
                                    SizedBox(
                                      width: 54,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              LucideIcons.pencil,
                                              size: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                            tooltip: 'Edit Record',
                                            onPressed: () =>
                                                _openAddOrEditEntryDialog(
                                              context,
                                              event,
                                              item,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              LucideIcons.trash2,
                                              size: 14,
                                              color: AppColors.liveRed,
                                            ),
                                            tooltip: 'Remove',
                                            onPressed: () =>
                                                _confirmDeleteEntry(
                                              context,
                                              event,
                                              item,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );

                  if (tableConstraints.maxWidth < minTableWidth) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: tableContent,
                    );
                  }
                  return tableContent;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedFilter = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
