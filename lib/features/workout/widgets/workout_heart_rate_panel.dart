import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/widgets/aura_card.dart';
import '../../../core/health/wearable_heart_rate_stream_service.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/models/heart_rate_status.dart';
import '../../../core/state/app_state.dart';

class WorkoutHeartRatePanel extends StatefulWidget {
  const WorkoutHeartRatePanel({
    super.key,
    required this.appState,
    this.wearableStreamService,
  });

  final WearableHeartRateStreamService? wearableStreamService;

  final AppState appState;

  @override
  State<WorkoutHeartRatePanel> createState() => _WorkoutHeartRatePanelState();
}

class _WorkoutHeartRatePanelState extends State<WorkoutHeartRatePanel> {
  late final WearableHeartRateStreamService _wearableStreamService;
  StreamSubscription? _wearableSubscription;
  bool _isStreamingWearable = false;
  String? _healthMessage;

  @override
  void initState() {
    super.initState();
    _wearableStreamService =
        widget.wearableStreamService ?? WearableHeartRateStreamService();
  }

  @override
  void dispose() {
    unawaited(_stopWearableStream());
    super.dispose();
  }

  Future<void> _startWearableStream() async {
    final activeSession = widget.appState.activeSession;
    if (_isStreamingWearable || activeSession == null) {
      return;
    }

    final strings = AppStrings.of(widget.appState.languageCode);
    final startResult = await _wearableStreamService.start(
      startedAt: activeSession.startedAt,
    );

    String? message;
    switch (startResult.status) {
      case WearableHeartRateStreamStatus.success:
        message = strings.wearableStreamStarted;
        break;
      case WearableHeartRateStreamStatus.unsupported:
        message = strings.wearableStreamUnsupported;
        break;
      case WearableHeartRateStreamStatus.denied:
        message = strings.wearableStreamDenied;
        break;
      case WearableHeartRateStreamStatus.failed:
        message = strings.wearableStreamFailed;
        break;
    }

    if (!startResult.isSuccess) {
      if (mounted) {
        setState(() {
          _healthMessage = message;
        });
      }
      return;
    }

    _wearableSubscription = _wearableStreamService
        .stream(startedAt: activeSession.startedAt)
        .listen((reading) async {
      await widget.appState.importHeartRateReadings(
        readings: [reading],
        exerciseId: widget.appState.currentHeartRateExerciseId(),
      );
    });

    if (!mounted) {
      return;
    }

    setState(() {
      _isStreamingWearable = true;
      _healthMessage = message;
    });
  }

  Future<void> _stopWearableStream() async {
    await _wearableSubscription?.cancel();
    _wearableSubscription = null;
    await _wearableStreamService.stop();

    if (!mounted) {
      return;
    }

    final strings = AppStrings.of(widget.appState.languageCode);
    setState(() {
      _isStreamingWearable = false;
      _healthMessage = strings.wearableStreamStopped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final theme = Theme.of(context);
    final strings = AppStrings.of(appState.languageCode);
    final samples = appState.recentHeartRateSamples();
    final hasStatusSignal = appState.hasHeartRateStatusSignal();
    final currentStatus = appState.currentHeartRateStatus();
    final currentBpm = samples.isEmpty ? null : samples.last.bpm;
    final baseline = appState.currentHeartRateBaseline();
    final threshold = appState.currentHeartRateReturnCueThreshold();
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
                    if (currentBpm == null)
                      Text(
                        strings.noHeartRateSamplesYet,
                        style: theme.textTheme.bodyLarge,
                      )
                    else if (hasStatusSignal)
                      Text(
                        currentStatus.titleFor(appState.languageCode),
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
          if (hasStatusSignal) ...[
            const SizedBox(height: 12),
            Text(
              currentStatus.descriptionFor(appState.languageCode),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (trackedExerciseName != null) ...[
            const SizedBox(height: 12),
            Text(
              strings.selectedExerciseForHeartRate(trackedExerciseName),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (baseline != null && samples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              strings.heartRateBaseline(baseline, threshold ?? baseline),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            strings.heartRateCoachSettingsHint,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: _isStreamingWearable
                ? _stopWearableStream
                : _startWearableStream,
            icon: Icon(
              _isStreamingWearable ? Icons.stop_circle : Icons.sensors,
            ),
            label: Text(
              _isStreamingWearable
                  ? strings.stopWearableStream
                  : strings.startWearableStream,
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
