import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/debug/demo_data.dart';
import 'core/design_system/app_theme.dart';
import 'core/auth/plugin_social_auth_service.dart';
import 'core/repositories/local_exercise_repository.dart';
import 'core/repositories/local_profile_repository.dart';
import 'core/repositories/local_settings_repository.dart';
import 'core/repositories/local_social_repository.dart';
import 'core/repositories/local_workout_repository.dart';
import 'core/state/app_state.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

class AuraLiftApp extends StatefulWidget {
  const AuraLiftApp({super.key});

  static const useDemoData = bool.fromEnvironment('AURA_LIFT_DEMO_DATA');

  @override
  State<AuraLiftApp> createState() => _AuraLiftAppState();
}

class _AuraLiftAppState extends State<AuraLiftApp> {
  static const _maxPhoneWidth = 430.0;

  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      profileRepository: AuraLiftApp.useDemoData
          ? DemoProfileRepository()
          : LocalProfileRepository(),
      exerciseRepository: AuraLiftApp.useDemoData
          ? DemoExerciseRepository()
          : LocalExerciseRepository(),
      workoutRepository: AuraLiftApp.useDemoData
          ? DemoWorkoutRepository()
          : LocalWorkoutRepository(),
      settingsRepository: AuraLiftApp.useDemoData
          ? DemoSettingsRepository()
          : LocalSettingsRepository(),
      socialRepository: AuraLiftApp.useDemoData
          ? DemoSocialRepository()
          : LocalSocialRepository(),
      socialAuthService: PluginSocialAuthService(),
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
            locale: Locale(_appState.languageCode),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('es'), Locale('en')],
            themeMode: _appState.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            builder: (context, child) => _PhoneFrame(
              maxWidth: _maxPhoneWidth,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const _BootstrapScreen(),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aura Lift',
          locale: Locale(_appState.languageCode),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('en')],
          themeMode: _appState.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          builder: (context, child) => _PhoneFrame(
            maxWidth: _maxPhoneWidth,
            child: child ?? const SizedBox.shrink(),
          ),
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
                    languageCode: _appState.languageCode,
                    onCompleted: _appState.completeOnboarding,
                  )
                : MainShell(
                    key: const ValueKey('home'),
                    appState: _appState,
                  ),
          ),
        );
      },
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.maxWidth,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) {
          return child;
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4C4C4E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.12),
                radius: 1.1,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.16),
                  const Color(0xFF4C4C4E),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Image.asset(
                  'assets/branding/aura_lift_opening.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
