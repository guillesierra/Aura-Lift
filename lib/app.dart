import 'package:flutter/material.dart';

import 'core/design_system/app_theme.dart';
import 'core/repositories/local_exercise_repository.dart';
import 'core/repositories/local_profile_repository.dart';
import 'core/repositories/local_workout_repository.dart';
import 'core/state/app_state.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class AuraLiftApp extends StatefulWidget {
  const AuraLiftApp({super.key});

  @override
  State<AuraLiftApp> createState() => _AuraLiftAppState();
}

class _AuraLiftAppState extends State<AuraLiftApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      profileRepository: LocalProfileRepository(),
      exerciseRepository: LocalExerciseRepository(),
      workoutRepository: LocalWorkoutRepository(),
    );
    _appState.bootstrap();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        if (!_appState.isBootstrapped) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aura Lift',
            themeMode: ThemeMode.system,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const _BootstrapScreen(),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aura Lift',
          themeMode: ThemeMode.system,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: _appState.profile == null
                ? OnboardingScreen(
                    key: const ValueKey('onboarding'),
                    onCompleted: _appState.completeOnboarding,
                  )
                : HomeScreen(
                    key: const ValueKey('home'),
                    appState: _appState,
                  ),
          ),
        );
      },
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
