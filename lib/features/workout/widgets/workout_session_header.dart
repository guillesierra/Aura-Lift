import 'package:flutter/material.dart';

import '../../../core/design_system/widgets/aura_card.dart';
import '../../../core/localization/app_strings.dart';

class WorkoutSessionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const WorkoutSessionHeaderDelegate({
    required this.child,
  });

  static const _height = 148.0;

  final Widget child;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant WorkoutSessionHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class WorkoutSessionHeaderCard extends StatelessWidget {
  const WorkoutSessionHeaderCard({
    super.key,
    required this.title,
    required this.duration,
    required this.totalVolume,
    required this.totalSets,
    required this.onRename,
    required this.onBack,
  });

  final String title;
  final Duration duration;
  final double totalVolume;
  final int totalSets;
  final Future<void> Function(String title) onRename;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    return AuraCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                iconSize: 22,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    await _showRenameWorkoutDialog(
                      context,
                      initialTitle: title,
                      onSave: onRename,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: strings.duration,
                  value: _formatDuration(duration),
                  emphasized: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderMetric(
                  label: strings.volume,
                  value: '${totalVolume.toStringAsFixed(0)} kg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderMetric(
                  label: strings.sets,
                  value: '$totalSets',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (minutes < 60) {
      return '${minutes}m ${seconds}s';
    }
    final hours = value.inHours;
    final remainingMinutes = minutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h ${remainingMinutes}m';
  }
}

Future<void> _showRenameWorkoutDialog(
  BuildContext context, {
  required String initialTitle,
  required Future<void> Function(String title) onSave,
}) async {
  final controller = TextEditingController(text: initialTitle);
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(strings.workoutName),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: strings.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await onSave(controller.text);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(strings.save),
          ),
        ],
      );
    },
  );
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.44),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: emphasized ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
