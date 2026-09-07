import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/matches/models/match_model.dart';
import '../../features/matches/providers/match_providers.dart';

class HeroLiveMatchSearch extends ConsumerStatefulWidget {
  const HeroLiveMatchSearch({super.key});

  @override
  ConsumerState<HeroLiveMatchSearch> createState() => _HeroLiveMatchSearchState();
}

class _HeroLiveMatchSearchState extends ConsumerState<HeroLiveMatchSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
        if (_query.isNotEmpty) {
          _isExpanded = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveMatchesAsync = ref.watch(allLiveMatchesStreamProvider);

    return liveMatchesAsync.when(
      data: (allLive) {
        final filteredLive = _query.isEmpty
            ? allLive
            : allLive.where((m) {
                final a = m.teamA.toLowerCase();
                final b = m.teamB.toLowerCase();
                final t = m.title.toLowerCase();
                final s = (m.stage ?? '').toLowerCase();
                final sport = m.sportId.toLowerCase();
                return a.contains(_query) ||
                    b.contains(_query) ||
                    t.contains(_query) ||
                    s.contains(_query) ||
                    sport.contains(_query);
              }).toList();

        return Container(
          margin: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _query.isNotEmpty ? AppColors.primary : AppColors.border,
              width: _query.isNotEmpty ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.search,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search live match by team, sport, or fest...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted.withValues(alpha: 0.8),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty) ...[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      ),
                    ] else if (allLive.isNotEmpty) ...[
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.liveRedSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.liveRed.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.liveRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${allLive.length} LIVE',
                                style: const TextStyle(
                                  color: AppColors.liveRed,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                                size: 13,
                                color: AppColors.liveRed,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Live Match List / Search Results Section
              if (_query.isNotEmpty || _isExpanded) ...[
                const Divider(height: 1, color: AppColors.border),
                if (filteredLive.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.searchX, size: 18, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          _query.isNotEmpty
                              ? 'No live match found matching "$_query"'
                              : 'No matches are currently live',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    itemCount: filteredLive.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      return _HeroLiveMatchItem(match: filteredLive[index]);
                    },
                  ),
                ],
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _HeroLiveMatchItem extends ConsumerWidget {
  final MatchModel match;

  const _HeroLiveMatchItem({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamParams = MatchStreamParams(
      matchId: match.id,
      status: match.status,
      enableVideoSyncDelay: false,
    );
    final matchStateAsync = ref.watch(liveMatchStateStreamProvider(streamParams));
    final scoreSummary = matchStateAsync.valueOrNull?.currentScore.displaySummary ?? 'Live Score...';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/match/${match.id}'),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Live Red Indicator Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.liveRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.radio, color: Colors.white, size: 10),
                    SizedBox(width: 3),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Match Details (Teams & Stage)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${match.teamA} vs ${match.teamB}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (match.stage != null && match.stage!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        match.stage!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Live Score Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  scoreSummary,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Direct Link Action Arrow
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
