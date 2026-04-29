import 'package:flutter/material.dart';

import '../../../core/design_system/widgets/aura_card.dart';
import '../../../core/health/apple_health_heart_rate_service.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/models/heart_rate_status.dart';
import '../../../core/state/app_state.dart';

class WorkoutHeartRatePanel extends StatefulWidget {
  const WorkoutHeartRatePanel({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WorkoutHeartRatePanel> createState() => _WorkoutHeartRatePanelState();
}

class _WorkoutHeartRatePanelState extends State<WorkoutHeartRatePanel> {
  final HealthHeartRateService _heartRateService = HealthHeartRateService();
  bool _isSyncingHealth = false;
  String? _healthMessage;

  Future<void> _syncHeartRateFromHealth() async {
    final activeSession = widget.appState.activeSession;
    if (_isSyncingHealth || activeSession == null) {
      return;
    }

    setState(() {
      _isSyncingHealth = true;
      _healthMessage = null;
    });

    final strings = AppStrings.of(widget.appState.languageCode);
    final result = await _heartRateService.fetchHeartRateReadings(
      startTime: activeSession.startedAt.toLocal(),
      endTime: DateTime.now(),
    );
    if (!mounted) {
      return;
    }

    var message = switch (result.status) {
      HealthHeartRateStatus.unsupported => strings.heartHealthUnsupported,
      HealthHeartRateStatus.denied => strings.heartHealthDenied,
      HealthHeartRateStatus.failed => strings.heartHealthSyncFailed,
      HealthHeartRateStatus.success => null,
    };

    if (result.status == HealthHeartRateStatus.success) {
      final imported = await widget.appState.importHeartRateReadings(
        readings: result.readings,
        exerciseId: widget.appState.currentHeartRateExerciseId(),
      );
      message = imported == 0
          ? strings.heartHealthNoSamples
          : strings.heartHealthImported(imported);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSyncingHealth = false;
      _healthMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final theme = Theme.of(context);
    final strings = AppStrings.of(appState.languageCode);
    final samples = appState.recentHeartRateSamples();
    final currentStatus = appState.currentHeartRateStatus();
    final currentBpm = samples.isEmpty ? null : samples.last.bpm;
    final baseline = appState.currentHeartRateBaseline();
    final threshold = baseline == null ? null : (baseline * 1.15).round();
    final trackedExerciseName = appState.currentHeartRateExerciseName();

    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.heartRate,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentBpm == null
                          ? strings.noHeartRateSamplesYet
                          : '$currentBpm ${strings.heartRateUnit} · ${currentStatus.titleFor(appState.languageCode)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  currentBpm == null ? '--' : '$currentBpm',
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentStatus.descriptionFor(appState.languageCode),
            style: theme.textTheme.bodyMedium,
          ),
          if (trackedExerciseName != null) ...[
            const SizedBox(height: 12),
            Text(
              strings.selectedExerciseForHeartRate(trackedExerciseName),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (baseline != null) ...[
            const SizedBox(height: 12),
            Text(
              strings.heartRateBaseline(baseline, threshold ?? baseline),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            strings.heartHealthCopy,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSyncingHealth ? null : _syncHeartRateFromHealth,
            icon: _isSyncingHealth
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.favorite_outline),
            label: Text(
              _isSyncingHealth
                  ? strings.heartHealthSyncing
                  : strings.syncHeartHealth,
            ),
          ),
          if (_healthMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _healthMessage!,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
