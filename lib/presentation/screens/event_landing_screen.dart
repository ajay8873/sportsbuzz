import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/events/providers/event_providers.dart';
import '../../features/sports/models/sport_category.dart';
import '../../features/sports/providers/sport_providers.dart';
import '../../features/matches/models/match_status.dart';
import '../../features/matches/providers/match_providers.dart';
import '../common/empty_state_view.dart';
import '../widgets/match_card.dart';
import '../../../core/utils/share_util.dart';
import '../../core/services/admin_auth_service.dart';

class EventLandingScreen extends ConsumerStatefulWidget {
  final String shareSlug;

  const EventLandingScreen({super.key, required this.shareSlug});

  @override
  ConsumerState<EventLandingScreen> createState() => _EventLandingScreenState();
}

class _EventLandingScreenState extends ConsumerState<EventLandingScreen> {
  String _selectedCategory = 'all'; // 'all', 'outdoor', 'indoor'
  String _selectedSportId = 'all'; // 'all' or specific sport ID
  MatchStatus _selectedStatusTab = MatchStatus.live;

  void _copyShareLink() {
    final link = ShareUtil.getEventShareUrl(widget.shareSlug);
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
    final eventAsync = ref.watch(eventBySlugProvider(widget.shareSlug));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Row(
          children: [
            const Icon(LucideIcons.flame, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                eventAsync.valueOrNull?.name ?? 'SportsFest Arena',
                style: const TextStyle(fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2),
            tooltip: 'Share Fest Link',
            onPressed: _copyShareLink,
          ),
          IconButton(
            icon: const Icon(LucideIcons.shieldCheck),
            tooltip: 'Organizer & Scorer Login',
            onPressed: () async {
              final event = eventAsync.valueOrNull;
              if (event == null) return;
              final ok = await AdminAuthService.promptPin(
                context: context,
                ref: ref,
                event: event,
              );
              if (ok && context.mounted) {
                context.push('/admin/events/${event.id}');
              }
            },
          ),
        ],
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const EmptyStateView(
              title: 'Fest Not Found',
              message:
                  'The sports fest link may be invalid or has been archived.',
            );
          }

          final sportsAsync = ref.watch(sportsForEventProvider(event.id));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(eventBySlugProvider(widget.shareSlug));
              ref.invalidate(sportsForEventProvider(event.id));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Header Card
                    Card(
                      elevation: 0,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 6,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.calendar,
                                                  size: 13,
                                                  color: AppColors.textSecondary),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${DateFormat("MMM d").format(event.startDate)} - ${DateFormat("MMM d, yyyy").format(event.endDate)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
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
                                                      fontWeight: FontWeight.w500,
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
                                IconButton.filledTonal(
                                  icon: const Icon(LucideIcons.share2, size: 18),
                                  tooltip: 'Share Fest',
                                  onPressed: _copyShareLink,
                                ),
                              ],
                            ),
                            if (event.description != null &&
                                event.description!.isNotEmpty) ...[
                              const Divider(height: 24),
                              Text(
                                event.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Outdoor / Indoor / All Categories Segmented Switcher
                    Row(
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'all',
                              label: Text('All'),
                              icon: Icon(LucideIcons.layers, size: 15),
                            ),
                            ButtonSegment(
                              value: 'outdoor',
                              label: Text('Outdoor'),
                              icon: Icon(LucideIcons.sun, size: 15),
                            ),
                            ButtonSegment(
                              value: 'indoor',
                              label: Text('Indoor'),
                              icon: Icon(LucideIcons.home, size: 15),
                            ),
                          ],
                          selected: {_selectedCategory},
                          onSelectionChanged: (set) {
                            setState(() {
                              _selectedCategory = set.first;
                              _selectedSportId = 'all';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Horizontally Scrollable Sports Chips with 'All' option by default
                    sportsAsync.when(
                      data: (sports) {
                        if (sports.isEmpty) {
                          return const EmptyStateView(
                            title: 'No Sports Added Yet',
                            message:
                                'Tournament organizers have not scheduled any games yet.',
                          );
                        }

                        // Filter sports by selected category segment
                        final filteredSports = sports.where((s) {
                          if (_selectedCategory == 'outdoor') {
                            return s.category == SportCategory.outdoor;
                          } else if (_selectedCategory == 'indoor') {
                            return s.category == SportCategory.indoor;
                          }
                          return true;
                        }).toList();

                        // Map of sport IDs to names for quick lookup
                        final sportMap = {
                          for (final s in sports) s.id: s.name,
                        };

                        // Determine active sport IDs to query matches for
                        List<String> querySportIds;
                        if (_selectedSportId == 'all') {
                          querySportIds = filteredSports.map((s) => s.id).toList();
                        } else {
                          querySportIds = [_selectedSportId];
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // 'All' Filter Chip (Selected by default)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      avatar: const Icon(LucideIcons.sparkles, size: 15),
                                      label: const Text('All Sports'),
                                      selected: _selectedSportId == 'all',
                                      onSelected: (val) {
                                        if (val) {
                                          setState(() => _selectedSportId = 'all');
                                        }
                                      },
                                    ),
                                  ),
                                  ...filteredSports.map((sport) {
                                    final isSelected =
                                        sport.id == _selectedSportId;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ChoiceChip(
                                        avatar: Icon(
                                          sport.category == SportCategory.outdoor
                                              ? LucideIcons.trophy
                                              : LucideIcons.crown,
                                          size: 15,
                                        ),
                                        label: Text(sport.name),
                                        selected: isSelected,
                                        onSelected: (val) {
                                          if (val) {
                                            setState(() =>
                                                _selectedSportId = sport.id);
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Fixture Tabs: Scheduled (clock), Live (radio), Completed (checkCircle2)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  _TabButton(
                                    icon: LucideIcons.radio,
                                    label: 'Live Matches',
                                    isSelected: _selectedStatusTab ==
                                        MatchStatus.live,
                                    activeColor: AppColors.liveRed,
                                    onTap: () => setState(() =>
                                        _selectedStatusTab =
                                            MatchStatus.live),
                                  ),
                                  _TabButton(
                                    icon: LucideIcons.clock,
                                    label: 'Scheduled',
                                    isSelected: _selectedStatusTab ==
                                        MatchStatus.scheduled,
                                    activeColor: AppColors.scheduledAmber,
                                    onTap: () => setState(() =>
                                        _selectedStatusTab =
                                            MatchStatus.scheduled),
                                  ),
                                  _TabButton(
                                    icon: LucideIcons.checkCircle2,
                                    label: 'Completed',
                                    isSelected: _selectedStatusTab ==
                                        MatchStatus.completed,
                                    activeColor: AppColors.completedGreen,
                                    onTap: () => setState(() =>
                                        _selectedStatusTab =
                                            MatchStatus.completed),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Fixtures List for Current Sports & Selected Tab
                            _ViewerMatchesList(
                              sportIds: querySportIds,
                              sportMap: sportMap,
                              statusFilter: _selectedStatusTab,
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading sports: $e'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading fest: $e')),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected
            ? activeColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? activeColor : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? activeColor : AppColors.textSecondary,
                    ),
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

class _ViewerMatchesList extends ConsumerWidget {
  final List<String> sportIds;
  final Map<String, String> sportMap;
  final MatchStatus statusFilter;

  const _ViewerMatchesList({
    required this.sportIds,
    required this.sportMap,
    required this.statusFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sportIds.isEmpty) {
      return EmptyStateView(
        icon: LucideIcons.calendarX2,
        title: 'No Matches Found',
        message: 'No matches have been added for this selection.',
      );
    }

    final matchesAsync = ref.watch(matchesForSportIdsProvider(sportIds));

    return matchesAsync.when(
      data: (matches) {
        final filteredMatches =
            matches.where((m) => m.status == statusFilter).toList();

        if (filteredMatches.isEmpty) {
          return EmptyStateView(
            icon: statusFilter == MatchStatus.live
                ? LucideIcons.radio
                : statusFilter == MatchStatus.scheduled
                    ? LucideIcons.clock
                    : LucideIcons.checkCircle2,
            title: 'No ${statusFilter.label} Matches',
            message: 'No matches in this category currently.',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredMatches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final match = filteredMatches[index];
            return MatchCard(
              match: match,
              sportName: sportMap[match.sportId],
            );
          },
        );
      },
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      )),
      error: (e, _) => Text('Error loading matches: $e'),
    );
  }
}
