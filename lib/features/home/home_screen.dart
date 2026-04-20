import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/primary_button.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/models/body_type.dart';
import '../../core/models/user_profile.dart';
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
        final UserProfile profile = appState.profile!;
        final activeSession = appState.activeSession;
        final recentSessions = appState.sessions.where((item) => !item.isActive);

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aura Lift', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    Text(
                      'Hola, ${profile.name}',
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activeSession == null
                          ? 'Tu base ya esta lista. Vamos con entrenos reales, series y progreso.'
                          : 'Tienes una sesion en curso. Puedes retomarla donde la dejaste.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeSession == null
                                ? 'Nuevo entrenamiento'
                                : 'Sesion activa',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            activeSession == null
                                ? 'Crea una sesion y empieza a registrar ejercicios con peso, repeticiones y ultima referencia.'
                                : '${activeSession.exercises.length} ejercicios · ${activeSession.totalSets} series registradas',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: activeSession == null
                                ? 'Empezar entrenamiento'
                                : 'Reanudar entrenamiento',
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
                    const SizedBox(height: 16),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Perfil', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 18),
                          _MetricRow(
                            label: 'Altura',
                            value: '${profile.heightCm} cm',
                          ),
                          const SizedBox(height: 12),
                          _MetricRow(
                            label: 'Peso',
                            value: '${profile.weightKg} kg',
                          ),
                          const SizedBox(height: 12),
                          _MetricRow(
                            label: 'Tipo',
                            value: profile.bodyType.title,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catalogo', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Text(
                            '${appState.exercises.length} ejercicios listos, incluyendo personalizados.',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'La sesion ya muestra ultima vez por ejercicio y guarda series dentro del entreno.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historial reciente',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          if (recentSessions.isEmpty)
                            Text(
                              'Todavia no hay sesiones cerradas.',
                              style: theme.textTheme.bodyMedium,
                            )
                          else
                            ...recentSessions.toList().reversed.take(3).map(
                                  (session) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _SessionSummaryRow(
                                      date: session.startedAt,
                                      exercises: session.exercises.length,
                                      sets: session.totalSets,
                                    ),
                                  ),
                                ),
                        ],
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

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _SessionSummaryRow extends StatelessWidget {
  const _SessionSummaryRow({
    required this.date,
    required this.exercises,
    required this.sets,
  });

  final DateTime date;
  final int exercises;
  final int sets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('$day/$month/${local.year}', style: theme.textTheme.titleMedium),
          ),
          Text('$exercises ejercicios', style: theme.textTheme.bodyMedium),
          const SizedBox(width: 12),
          Text('$sets series', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
