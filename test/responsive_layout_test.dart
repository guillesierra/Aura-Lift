import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura_lift/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final scenarios = <({double width, double textScale})>[
    (width: 320, textScale: 1.3),
    (width: 360, textScale: 1.4),
    (width: 390, textScale: 1.5),
  ];

  group('Responsive layout smoke tests', () {
    for (final scenario in scenarios) {
      testWidgets(
        'onboarding renders without overflow at ${scenario.width}px / x${scenario.textScale}',
        (tester) async {
          await _pumpAppScenario(
            tester,
            withProfile: false,
            width: scenario.width,
            textScale: scenario.textScale,
          );
        },
      );

      testWidgets(
        'home shell renders without overflow at ${scenario.width}px / x${scenario.textScale}',
        (tester) async {
          await _pumpAppScenario(
            tester,
            withProfile: true,
            width: scenario.width,
            textScale: scenario.textScale,
          );
        },
      );

      testWidgets(
        'training tab renders without overflow at ${scenario.width}px / x${scenario.textScale}',
        (tester) async {
          await _pumpAppScenario(
            tester,
            withProfile: true,
            width: scenario.width,
            textScale: scenario.textScale,
            navigate: (tester) async {
              await tester.tap(find.text('Entrenamiento').first);
              await tester.pumpAndSettle();
            },
          );
        },
      );

      testWidgets(
        'profile tab renders without overflow at ${scenario.width}px / x${scenario.textScale}',
        (tester) async {
          await _pumpAppScenario(
            tester,
            withProfile: true,
            width: scenario.width,
            textScale: scenario.textScale,
            navigate: (tester) async {
              await tester.tap(find.text('Perfil').first);
              await tester.pumpAndSettle();
            },
          );
        },
      );

      testWidgets(
        'calendar screen renders without overflow at ${scenario.width}px / x${scenario.textScale}',
        (tester) async {
          await _pumpAppScenario(
            tester,
            withProfile: true,
            width: scenario.width,
            textScale: scenario.textScale,
            navigate: (tester) async {
              await tester.tap(find.text('Perfil').first);
              await tester.pumpAndSettle();
              final calendarTile = find.byKey(
                const Key('profile_calendar_tile'),
              );
              await tester.scrollUntilVisible(
                calendarTile,
                180,
                scrollable: find.byType(Scrollable).first,
              );
              await tester.tap(calendarTile);
              await tester.pumpAndSettle();
            },
          );
        },
      );
    }
  });
}

Future<void> _pumpAppScenario(
  WidgetTester tester, {
  required bool withProfile,
  required double width,
  required double textScale,
  Future<void> Function(WidgetTester tester)? navigate,
}) async {
  SharedPreferences.setMockInitialValues(_mockPrefs(withProfile: withProfile));

  final view = tester.view;
  view.physicalSize = Size(width, 800);
  view.devicePixelRatio = 1.0;

  tester.binding.platformDispatcher.textScaleFactorTestValue = textScale;

  addTearDown(() {
    tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  final overflowErrors = <FlutterErrorDetails>[];
  final previousErrorHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    if (message.contains('NetworkImageLoadException') ||
        message.contains('HTTP request failed, statusCode: 400')) {
      return;
    }
    if (message.contains('A RenderFlex overflowed') ||
        message.contains('overflowed by')) {
      overflowErrors.add(details);
    }
    previousErrorHandler?.call(details);
  };

  addTearDown(() {
    FlutterError.onError = previousErrorHandler;
  });

  await tester.pumpWidget(const AuraLiftApp());
  await tester.pumpAndSettle(const Duration(seconds: 2));

  if (navigate != null) {
    await navigate(tester);
  }

  expect(
    overflowErrors,
    isEmpty,
    reason: 'Detected overflow errors at ${width}px and text scale x$textScale.',
  );
}

Map<String, Object> _mockPrefs({required bool withProfile}) {
  final exerciseCatalog = jsonEncode([
    {
      'id': 'test-exercise-1',
      'name': 'Press de banca con barra',
      'muscleGroup': 'Pecho',
      'isCustom': false,
      'createdAt': '2026-01-01T00:00:00Z',
    },
  ]);

  final values = <String, Object>{
    'exercise_catalog_v1': exerciseCatalog,
    'settings_language_code_v1': 'es',
    'settings_menu_animations_v1': true,
  };

  if (withProfile) {
    values['user_profile_v1'] = jsonEncode({
      'id': 'profile-test',
      'name': 'Guillermo',
      'heightCm': 176,
      'weightKg': 78,
      'bodyType': 'athletic',
      'avatarUrl': null,
      'presentation': 'Entrenando con constancia',
      'city': 'Madrid',
      'gym': 'Aura Gym',
      'createdAt': DateTime.utc(2026, 1, 1).toIso8601String(),
      'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
    });
  }

  return values;
}
