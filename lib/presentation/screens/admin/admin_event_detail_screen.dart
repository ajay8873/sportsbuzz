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
import '../../../core/services/admin_auth_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../../widgets/auth_user_button.dart';
import '../../widgets/batch_points_table_widget.dart';
import 'dialogs/manage_co_admins_dialog.dart';

class AdminEventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const AdminEventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<AdminEventDetailScreen> createState() =>
      _AdminEventDetailScreenState();
}

class _AdminEventDetailScreenState
    extends ConsumerState<AdminEventDetailScreen> {
  int _currentAdminTab = 0; // 0 = Sports & Matches, 1 = Standings & Points Table
  String _activeCategory = 'all'; // 'all', 'outdoor', 'indoor'

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

  void _confirmDeleteSport(SportModel sport) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sport?'),
        content: Text(
          'Are you sure you want to remove "${sport.name}" and all of its scheduled fixtures from this fest?',
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
              await ref.read(sportDaoProvider).deleteSport(sport.id);
              ref.invalidate(sportsForEventProvider(widget.eventId));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sport "${sport.name}" removed'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete Sport'),
          ),
        ],
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
          error: (_, _) => const Text('Event Management'),
        ),
        actions: [
          eventAsync.maybeWhen(
            data: (event) {
              if (event == null) return const SizedBox.shrink();
              final currentUserEmail = ref.watch(currentUserEmailProvider);
              final isSuperAdmin = ref.watch(isSuperAdminProvider);
              final isCreator = event.creatorEmail != null &&
                  event.creatorEmail!.trim().toLowerCase() == currentUserEmail?.trim().toLowerCase();
              final canManageCoAdmins = isSuperAdmin || isCreator;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canManageCoAdmins)
                    IconButton(
                      icon: const Icon(LucideIcons.userCheck),
                      tooltip: 'Manage Co-Admins & Permissions',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => ManageCoAdminsDialog(event: event),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(LucideIcons.share2),
                    tooltip: 'Share Fest Link',
                    onPressed: () => _copyShareLink(event.shareSlug),
                  ),
                ],
              );
            },
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
          const SizedBox(width: 4),
          const AuthUserButton(),
          const SizedBox(width: 8),
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

          final currentUserEmail = ref.watch(currentUserEmailProvider);
          final isUnlocked = ref.watch(unlockedEventsProvider).contains(widget.eventId);
          final hasAdminAuthority = event.canUserAdmin(currentUserEmail) || isUnlocked;

          if (!hasAdminAuthority) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.liveRedSurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.liveRed.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(
                              LucideIcons.shieldAlert,
                              size: 36,
                              color: AppColors.liveRed,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Organizer Authority Required',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Shared spectator links are view-only. Only the tournament creator (${event.creatorEmail ?? "Organizer"}), authorized co-admins, or global superadmin (${AuthService.superAdminEmail}) can manage fixtures and scoring for "${event.name}".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.45),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(LucideIcons.arrowLeft, size: 16),
                                label: const Text('View Spectator Arena'),
                                onPressed: () => context.go('/event/${event.shareSlug}'),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(LucideIcons.keyRound, size: 16),
                                label: const Text('Enter PIN (Fallback)'),
                                onPressed: () => AdminAuthService.promptPin(
                                  context: context,
                                  ref: ref,
                                  event: event,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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

                    // Admin Mode Switcher: Sports & Fixtures vs Points Table
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() => _currentAdminTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _currentAdminTab == 0
                                      ? AppColors.surface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _currentAdminTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.gamepad2,
                                      size: 15,
                                      color: _currentAdminTab == 0
                                          ? AppColors.cricbuzzGreen
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Sports & Fixtures',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _currentAdminTab == 0
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _currentAdminTab == 0
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() => _currentAdminTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _currentAdminTab == 1
                                      ? AppColors.surface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _currentAdminTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.trophy,
                                      size: 15,
                                      color: _currentAdminTab == 1
                                          ? AppColors.cricbuzzGreen
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Points Table (${event.standings.length})',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _currentAdminTab == 1
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _currentAdminTab == 1
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_currentAdminTab == 1) ...[
                      BatchPointsTableWidget(
                        event: event,
                        showAdminControls: true,
                      ),
                    ] else ...[
                      // Category Switcher (All / Outdoor / Indoor)
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'all',
                                label: Text('All Sports'),
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
                            selected: {_activeCategory},
                            onSelectionChanged: (set) {
                              setState(() {
                                _activeCategory = set.first;
                              });
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Add Sport'),
                            onPressed: () async {
                              final createdSport = await showDialog(
                                context: context,
                                builder: (_) =>
                                    CreateSportDialog(eventId: widget.eventId),
                              );
                              if (createdSport != null && mounted) {
                                setState(() {
                                  _activeCategory = 'all';
                                });
                                ref.invalidate(
                                    sportsForEventProvider(widget.eventId));
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sports Chips List
                      sportsAsync.when(
                        data: (sports) {
                          final filteredSports = sports.where((s) {
                            if (_activeCategory == 'outdoor') {
                              return s.category == SportCategory.outdoor;
                            } else if (_activeCategory == 'indoor') {
                              return s.category == SportCategory.indoor;
                            }
                            return true;
                          }).toList();

                          if (filteredSports.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Text(
                                  'No sports added in this category yet. Tap "Add Sport" to add one.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredSports.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 18),
                            itemBuilder: (context, index) {
                              final sport = filteredSports[index];
                              return _SportCard(
                                sport: sport,
                                onScheduleMatch: () async {
                                  final created = await showDialog(
                                    context: context,
                                    builder: (_) => CreateMatchDialog(
                                      sportId: sport.id,
                                      sportName: sport.name,
                                      scoringModel: sport.scoringModel,
                                    ),
                                  );
                                  if (created != null) {
                                    ref.invalidate(
                                        matchesForSportProvider(sport.id));
                                  }
                                },
                                onDeleteSport: () =>
                                    _confirmDeleteSport(sport),
                              );
                            },
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

class _SportCard extends StatelessWidget {
  final SportModel sport;
  final VoidCallback onScheduleMatch;
  final VoidCallback onDeleteSport;

  const _SportCard({
    required this.sport,
    required this.onScheduleMatch,
    required this.onDeleteSport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sport Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    sport.category == SportCategory.outdoor
                        ? LucideIcons.trophy
                        : LucideIcons.crown,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sport.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              sport.category.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              sport.scoringModel.label,
                              style: const TextStyle(
                                fontSize: 11,
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
                ),
                const SizedBox(width: 6),

                // Delete Icon Button (Icon only)
                IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.liveRed,
                    backgroundColor: AppColors.liveRedSurface,
                    padding: const EdgeInsets.all(7),
                    minimumSize: const Size(34, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: AppColors.liveRed.withValues(alpha: 0.25),
                      ),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(LucideIcons.trash2, size: 15),
                  tooltip: 'Delete ${sport.name}',
                  onPressed: onDeleteSport,
                ),
                const SizedBox(width: 6),

                // Schedule Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(LucideIcons.plus, size: 13),
                  label: const Text(
                    'Schedule',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  onPressed: onScheduleMatch,
                ),
              ],
            ),
          ),

          // Box-like Structure Below for Fixtures
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: _SportFixturesList(
              sport: sport,
              onScheduleMatch: onScheduleMatch,
            ),
          ),
        ],
      ),
    );
  }
}

class _SportFixturesList extends ConsumerWidget {
  final SportModel sport;
  final VoidCallback? onScheduleMatch;

  const _SportFixturesList({
    required this.sport,
    this.onScheduleMatch,
  });

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
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.calendarDays,
                  size: 28,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No fixtures scheduled for ${sport.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add fixtures to start live scoring and track results.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onScheduleMatch != null) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text(
                      'Schedule Fixture Now',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    onPressed: onScheduleMatch,
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
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
