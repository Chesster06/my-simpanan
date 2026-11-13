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
    expect(find.text('Reminder Preferences'), findsOneWidget);
    expect(find.text('Data Management'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    // Preferences items
    expect(find.text('Enable Installment Reminders'), findsOneWidget);
    expect(find.text('Reminder Lead Time'), findsOneWidget);
    expect(find.text('Daily Reminder Time'), findsOneWidget);

    // Data management items
    expect(find.text('Reset All Data'), findsOneWidget);

    // About details
    expect(find.byType(AppLogoBadge), findsOneWidget);
    expect(find.text('MySimpanan'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(
      find.text(
        'A disciplined savings goal tracker with scheduled monthly installments, Pay Early checklist, and smart reminders.',
      ),
      findsOneWidget,
    );
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

  testWidgets('Reset All Data shows confirmation dialog and cancels without clearing', (tester) async {
    final goal = SavingsGoal(
      id: 'g-1',
      name: 'Emergency Fund',
      targetAmount: 3000,
      currentSavings: 500,
      startDate: DateTime(2026, 1, 1),
      targetDate: DateTime(2026, 12, 31),
    );
    final repository = MockSavingsRepository([goal]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset All Data'));
    await tester.pumpAndSettle();

    expect(find.text('Reset All Data?'), findsOneWidget);
    expect(
      find.text('This will permanently delete all your savings goals and installment history. This action cannot be undone.'),
      findsOneWidget,
    );

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Reset All Data?'), findsNothing);
    expect(provider.goals.length, equals(1));
  });

  testWidgets('Reset All Data confirmed deletes all goals and displays confirmation snackbar', (tester) async {
    final goal = SavingsGoal(
      id: 'g-1',
      name: 'Emergency Fund',
      targetAmount: 3000,
      currentSavings: 500,
      startDate: DateTime(2026, 1, 1),
      targetDate: DateTime(2026, 12, 31),
    );
    final repository = MockSavingsRepository([goal]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset All Data'));
    await tester.pumpAndSettle();

    // Tap Confirm Reset
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(provider.goals.isEmpty, isTrue);
    expect(find.text('All savings data has been reset'), findsOneWidget);
  });
}
