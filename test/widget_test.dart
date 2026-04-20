import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura_lift/app.dart';

void main() {
  testWidgets('renders onboarding shell', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'exercise_catalog_v1': jsonEncode([
        {
          'id': 'test-exercise-1',
          'name': 'Press de banca con barra',
          'muscleGroup': 'Pecho',
          'isCustom': false,
          'createdAt': '2026-01-01T00:00:00Z',
        },
      ]),
    });

    await tester.pumpWidget(const AuraLiftApp());
    await tester.pumpAndSettle();

    expect(find.text('Configura tu base'), findsOneWidget);
  });
}
