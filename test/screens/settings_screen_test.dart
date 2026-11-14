import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/settings_screen.dart';
import 'package:mysimpanan/widgets/app_logo_badge.dart';

class MockSavingsRepository implements SavingsRepository {
  List<SavingsGoal> storedGoals;
  MockSavingsRepository([this.storedGoals = const []]);

  @override
  Future<List<SavingsGoal>> loadGoals() async => storedGoals;

  @override
  Future<void> saveGoals(List<SavingsGoal> goals) async {
    storedGoals = goals;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pref_reminders_enabled': true,
      'pref_reminder_lead_days': 3,
      'pref_reminder_time_hour': 9,
      'pref_reminder_time_minute': 0,
    });
  });

  testWidgets('SettingsScreen renders all sections, titles, and about details', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    // App Bar
    expect(find.text('Settings'), findsOneWidget);

    // Section Headers
    expect(find.text('Choose Language'), findsOneWidget);
    expect(find.text('Reminder Preferences'), findsOneWidget);
    expect(find.text('About'), findsNWidgets(2));

    // Preferences items
    expect(find.text('Enable Installment Reminders'), findsOneWidget);
    expect(find.text('Reminder Lead Time'), findsOneWidget);
    expect(find.text('Daily Reminder Time'), findsOneWidget);

    // About details
    expect(find.byType(AppLogoBadge), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);
  });

  testWidgets('Toggling Enable Installment Reminders updates switch and persists value', (tester) async {
    final repository = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pref_reminders_enabled'), isFalse);
  });

  testWidgets('Changing Reminder Lead Time dropdown updates preference', (tester) async {
    final repository = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    // Tap dropdown
    await tester.tap(find.text('3 days before'));
    await tester.pumpAndSettle();

    // Select 5 days before
    await tester.tap(find.text('5 days before').last);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('pref_reminder_lead_days'), equals(5));
  });
}
