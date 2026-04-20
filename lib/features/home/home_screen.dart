import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/primary_button.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/body_type.dart';
import '../../core/models/workout_session.dart';
import '../../core/state/app_state.dart';
import '../workout/workout_session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final theme = Theme.of(context);
        final strings = AppStrings.of(appState.languageCode);
        final profile = appState.profile!;
        final activeSession = appState.activeSession;
        final completedSessions = appState.sessions
            .where((item) => !item.isActive)
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(strings.home, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 10),
                              Text(
                                strings.hello(profile.name),
                                style: theme.textTheme.displayLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                activeSession == null
                                    ? strings.homeOverview
                                    : strings.homeOverviewActive,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: strings.settings,
                          onPressed: () {
                            _showSettingsSheet(context, appState);
                          },
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AuraCard(
                      padding: const EdgeInsets.all(28),
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
                                      activeSession == null
                                          ? strings.readyToTrain
                                          : strings.activeSession,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      activeSession == null
                                          ? strings.quickStartCopy
                                          : strings.sessionSummary(
                                              activeSession.exercises.length,
                                              activeSession.totalSets,
                                            ),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  activeSession == null
                                      ? Icons.play_arrow_rounded
                                      : Icons.bolt_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: activeSession == null
                                ? strings.startWorkout
                                : strings.resumeWorkout,
                            onPressed: () async {
                              if (activeSession == null) {
                                await appState.startWorkoutSession();
                              }
                              if (context.mounted) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => WorkoutSessionScreen(
                                      appState: appState,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      completedSessions.isEmpty
                          ? strings.recentHistory
                          : '${strings.recentHistory} · ${completedSessions.length}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    if (completedSessions.isEmpty)
                      AuraCard(
                        child: Text(
                          strings.noClosedSessions,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...completedSessions.take(10).map(
                            (session) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: WorkoutSummaryCard(
                                session: session,
                                authorName: profile.name,
                                authorHandle: profile.name.toLowerCase(),
                                highlightColor: theme.colorScheme.primary,
                                onRename: (title) {
                                  return appState.renameWorkoutSession(
                                    sessionId: session.id,
                                    title: title,
                                  );
                                },
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),
                    Text('Amigos · demo', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 14),
                    ..._buildDemoFriendCards(theme).map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: card,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    super.key,
    required this.session,
    required this.authorName,
    required this.authorHandle,
    required this.highlightColor,
    this.onRename,
  });

  final WorkoutSession session;
  final String authorName;
  final String authorHandle;
  final Color highlightColor;
  final Future<void> Function(String title)? onRename;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = session.startedAt.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final durationMinutes = session.duration.inMinutes;
    final volume = session.totalVolume.toStringAsFixed(0);

    return AuraCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: highlightColor.withValues(alpha: 0.18),
                child: Text(
                  authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(authorHandle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(date, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'rename' && onRename != null) {
                    await _showRenameSummaryDialog(
                      context,
                      initialTitle: session.title,
                      onSave: onRename!,
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'rename',
                    child: Text('Renombrar'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            session.title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _WorkoutMetric(
                  label: 'Tiempo',
                  value: '${durationMinutes}min',
                ),
              ),
              Expanded(
                child: _WorkoutMetric(
                  label: 'Volumen',
                  value: '$volume kg',
                ),
              ),
              Expanded(
                child: _WorkoutMetric(
                  label: 'Series',
                  value: '${session.totalSets}',
                ),
              ),
            ],
          ),
          if (session.exercises.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...session.exercises.take(3).map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${exercise.sets.length} series · ${exercise.exerciseName}',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkoutMetric extends StatelessWidget {
  const _WorkoutMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

List<Widget> _buildDemoFriendCards(ThemeData theme) {
  return [
    AuraCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.18),
                child: const Text('A'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('albitadinamita', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('Demo social', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Biceps + pecho + hombro', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: _WorkoutMetric(label: 'Tiempo', value: '53min')),
              Expanded(child: _WorkoutMetric(label: 'Volumen', value: '4230 kg')),
              Expanded(child: _WorkoutMetric(label: 'Series', value: '12')),
            ],
          ),
        ],
      ),
    ),
  ];
}

Future<void> _showRenameSummaryDialog(
  BuildContext context, {
  required String initialTitle,
  required Future<void> Function(String title) onSave,
}) async {
  final controller = TextEditingController(text: initialTitle);
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Renombrar entrenamiento'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Titulo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await onSave(controller.text);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}

Future<void> _showSettingsSheet(BuildContext context, AppState appState) async {
  final profile = appState.profile!;
  final nameController = TextEditingController(text: profile.name);
  final heightController =
      TextEditingController(text: profile.heightCm.toStringAsFixed(0));
  final weightController =
      TextEditingController(text: profile.weightKg.toStringAsFixed(0));
  var selectedBodyType = profile.bodyType;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      final strings = AppStrings.of(appState.languageCode);
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.settings, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 18),
                  Text(strings.profile, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Altura'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Peso'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BodyType>(
                    value: selectedBodyType,
                    items: BodyType.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.title),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setModalState(() => selectedBodyType = value);
                    },
                    decoration: const InputDecoration(labelText: 'Tipo de cuerpo'),
                  ),
                  const SizedBox(height: 20),
                  Text(strings.appearance, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ThemeMode.values.map((mode) {
                      return ChoiceChip(
                        label: Text(mode.localizedLabel(strings)),
                        selected: appState.themeMode == mode,
                        onSelected: (_) async {
                          await appState.updateThemeMode(mode);
                        },
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 20),
                  Text(strings.language, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(strings.spanish),
                        selected: appState.languageCode == 'es',
                        onSelected: (_) async {
                          await appState.updateLanguageCode('es');
                        },
                      ),
                      ChoiceChip(
                        label: Text(strings.english),
                        selected: appState.languageCode == 'en',
                        onSelected: (_) async {
                          await appState.updateLanguageCode('en');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Guardar cambios',
                    onPressed: () async {
                      final height = double.tryParse(heightController.text);
                      final weight = double.tryParse(weightController.text);
                      if (height == null || weight == null) {
                        return;
                      }
                      await appState.updateProfile(
                        name: nameController.text,
                        heightCm: height,
                        weightKg: weight,
                        bodyType: selectedBodyType,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
