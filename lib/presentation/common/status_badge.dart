import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../features/matches/models/match_status.dart';

class StatusBadge extends StatelessWidget {
  final MatchStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String text = status.label.toUpperCase();

    switch (status) {
      case MatchStatus.live:
        bg = AppColors.liveRedSurface;
        fg = AppColors.liveRed;
        icon = LucideIcons.radio;
        break;
      case MatchStatus.scheduled:
        bg = AppColors.scheduledAmberSurface;
        fg = AppColors.scheduledAmber;
        icon = LucideIcons.clock;
        break;
      case MatchStatus.completed:
        bg = AppColors.completedGreenSurface;
        fg = AppColors.completedGreen;
        icon = LucideIcons.checkCircle2;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
