import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class SportsEngineShowcaseWidget extends StatelessWidget {
  const SportsEngineShowcaseWidget({super.key});

  static const List<Map<String, dynamic>> _sports = [
    {
      'title': 'Cricket',
      'icon': LucideIcons.target,
      'rules': 'Free Hits, Wickets, Overs, Strike Rotation',
      'color': Color(0xFFD97706),
      'bgColor': Color(0xFFFFFBEB),
    },
    {
      'title': 'Football / Futsal',
      'icon': LucideIcons.timer,
      'rules': 'Match Clock, Halves, Cards, Penalties',
      'color': Color(0xFF059669),
      'bgColor': Color(0xFFECFDF5),
    },
    {
      'title': 'Volleyball',
      'icon': LucideIcons.zap,
      'rules': 'Sets, Serve Indicator, Deuce (24-24)',
      'color': Color(0xFF4F46E5),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'title': 'Basketball',
      'icon': LucideIcons.flame,
      'rules': 'Quarters, 1/2/3 Pts, 5-Foul Bonus',
      'color': Color(0xFFEA580C),
      'bgColor': Color(0xFFFFF7ED),
    },
    {
      'title': 'Badminton & TT',
      'icon': LucideIcons.award,
      'rules': 'Sets Won, Deuce, Advantage Rule',
      'color': Color(0xFF0D9488),
      'bgColor': Color(0xFFF0FDFA),
    },
    {
      'title': 'Chess & Carrom',
      'icon': LucideIcons.clock,
      'rules': 'Dual Timers, Moves, Coin Counters',
      'color': Color(0xFF6366F1),
      'bgColor': Color(0xFFF5F3FF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    LucideIcons.activity,
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
                        'Polymorphic Sports Scoring Engine',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Text(
                        'Automated collegiate tournament rules for every sport',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid of sport cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 550;
                final crossAxisCount = isWide ? 3 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sports.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isWide ? 2.4 : 1.9,
                  ),
                  itemBuilder: (context, index) {
                    final item = _sports[index];
                    final color = item['color'] as Color;
                    final bgColor = item['bgColor'] as Color;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['rules'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
