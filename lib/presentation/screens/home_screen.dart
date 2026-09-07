import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/share_util.dart';
import '../../features/events/models/event_model.dart';
import '../../features/events/providers/event_providers.dart';
import '../common/empty_state_view.dart';
import '../widgets/batch_points_table_widget.dart';
import '../widgets/link_code_resolver_card.dart';
import '../widgets/sports_engine_showcase_widget.dart';
import 'admin/dialogs/create_event_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(allEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            // Zest App Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ZEST',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 3, top: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.cricbuzzGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 600 ? 16.0 : 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.zestOrangeSurface, AppColors.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.zestOrange,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.zestOrange.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
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
                                    'Live Campus Sports & Medical Fests',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Real-time scoreboards, live video streams, and inter-batch standings powered by direct link sharing.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          height: 1.45,
                                          fontSize: 13,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons Row (Coherent sizing and responsive)
                        LayoutBuilder(
                          builder: (context, heroConstraints) {
                            final isNarrow = heroConstraints.maxWidth < 440;
                            final hostBtn = ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.zestOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(0, 44),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(LucideIcons.plusCircle, size: 18),
                              label: const Text(
                                'Host Fest / Tournament',
                                style: TextStyle(
                                  fontSize: 14,
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
                                  ref.invalidate(allEventsProvider);
                                  context.push('/admin/events/${createdEvent.id}');
                                }
                              },
                            );

                            final adminBtn = OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                backgroundColor: AppColors.surface,
                                side: const BorderSide(color: AppColors.borderHover),
                                minimumSize: const Size(0, 44),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(LucideIcons.shieldCheck, size: 18),
                              label: const Text(
                                'Admin Console',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () => context.push('/admin'),
                            );

                            if (isNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  hostBtn,
                                  const SizedBox(height: 10),
                                  adminBtn,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                hostBtn,
                                const SizedBox(width: 12),
                                adminBtn,
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Direct Link & Event Code Resolver
                const LinkCodeResolverCard(),
                const SizedBox(height: 24),

                // 3. Medical College Batch Points Table
                const BatchPointsTableWidget(),
                const SizedBox(height: 24),

                // 4. Active Fests & Tournaments
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'ACTIVE & RECENT TOURNAMENTS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('New Tournament'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () async {
                        final createdEvent = await showDialog<EventModel>(
                          context: context,
                          builder: (_) => const CreateEventDialog(),
                        );
                        if (createdEvent != null && context.mounted) {
                          ref.invalidate(allEventsProvider);
                          context.push('/admin/events/${createdEvent.id}');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return EmptyStateView(
                        icon: LucideIcons.trophy,
                        title: 'No Active Tournaments Found',
                        message:
                            'Host your college sports fest or athletic meet to generate live spectator links.',
                        action: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Host First Tournament'),
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
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final dateFormat = DateFormat('MMM d, yyyy');

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                context.push('/event/${event.shareSlug}'),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      LucideIcons.trophy,
                                      color: AppColors.primary,
                                      size: 20,
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
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.calendar,
                                              size: 13,
                                              color: AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (event.venue != null &&
                                            event.venue!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(
                                                LucideIcons.mapPin,
                                                size: 13,
                                                color: AppColors.textMuted,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  event.venue!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Quick Copy Link button
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      LucideIcons.share2,
                                      size: 17,
                                      color: AppColors.textSecondary,
                                    ),
                                    tooltip: 'Copy Spectator Link',
                                    onPressed: () =>
                                        _copyShareLink(context, event.shareSlug),
                                  ),
                                  const SizedBox(width: 6),

                                  // Enter Arena Button
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(LucideIcons.arrowRight,
                                        size: 13),
                                    label: const Text(
                                      'Enter',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    onPressed: () =>
                                        context.push('/event/${event.shareSlug}'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Text('Error loading events: $error'),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Multi-Sport Scoring Engine Overview
                const SportsEngineShowcaseWidget(),
                const SizedBox(height: 32),

                // Footer Note
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.shieldCheck,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Zest Campus Sports & Fest Streaming Architecture',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
