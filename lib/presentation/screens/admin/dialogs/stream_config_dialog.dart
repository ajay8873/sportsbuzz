import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/matches/providers/match_providers.dart';

class StreamConfigDialog extends ConsumerStatefulWidget {
  final String matchId;
  final String? initialStreamUrl;

  const StreamConfigDialog({
    super.key,
    required this.matchId,
    this.initialStreamUrl,
  });

  @override
  ConsumerState<StreamConfigDialog> createState() => _StreamConfigDialogState();
}

class _StreamConfigDialogState extends ConsumerState<StreamConfigDialog> {
  final _urlController = TextEditingController();
  final _rtmpKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialStreamUrl ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _rtmpKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newUrl = _urlController.text.trim();
    final dao = ref.read(matchDaoProvider);
    await dao.updateStreamUrl(
      widget.matchId,
      newUrl.isEmpty ? null : newUrl,
    );
    ref.invalidate(matchByIdProvider(widget.matchId));

    if (mounted) {
      Navigator.of(context).pop(newUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Broadcast & RTMP Stream',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.video, size: 20, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Push your camera feed via mobile RTMP stream to YouTube Live. Viewers on web & mobile will automatically sync with this live feed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Live Video URL',
                  hintText: 'https://www.youtube.com/watch?v=YOUR_LIVE_ID',
                  prefixIcon: Icon(LucideIcons.tv, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rtmpKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'RTMP Stream Key (Optional for Scorer Camera)',
                  hintText: 'rtmp://a.rtmp.youtube.com/live2/...',
                  prefixIcon: Icon(LucideIcons.key, size: 18),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Update Live Stream Feed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
