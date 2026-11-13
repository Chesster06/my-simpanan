import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/dashboard_screen.dart';
import 'package:mysimpanan/widgets/app_logo_badge.dart';
import 'package:mysimpanan/widgets/savings_goal_card.dart';
import 'package:mysimpanan/widgets/summary_header_card.dart';

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
  testWidgets('DashboardScreen renders empty state when no goals exist', (tester) async {
    final repository = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(provider: provider),
      ),
    );

    expect(find.byType(AppLogoBadge), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byKey(const Key('app_bar_add_goal_button')), findsOneWidget);
    expect(find.byType(SummaryHeaderCard), findsOneWidget);
    expect(find.text('No Savings Goals Yet'), findsOneWidget);
    expect(find.byKey(const Key('empty_state_illustration')), findsOneWidget);
  });

  testWidgets('tapping app bar add goal icon navigates to CreateGoalScreen by default', (tester) async {
    final repository = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(provider: provider),
      ),
    );

    await tester.tap(find.byKey(const Key('app_bar_add_goal_button')));
    await tester.pumpAndSettle();

    expect(find.text('New Savings Goal'), findsOneWidget);
    expect(find.text('Commitment Schedule Preview'), findsOneWidget);
  });

  testWidgets('tapping empty state illustration navigates to CreateGoalScreen', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(provider: provider),
      ),
    );

    final emptyStateImage = find.byKey(const Key('empty_state_illustration'));
    await tester.ensureVisible(emptyStateImage);
    await tester.tap(emptyStateImage);
    await tester.pumpAndSettle();

    expect(find.text('New Savings Goal'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders goal list when goals are present', (tester) async {
    final repository = MockSavingsRepository([
      SavingsGoal(
        id: 'g-1',
        name: 'ASNB Bumiputera',
        targetAmount: 5000.0,
        currentSavings: 1500.0,
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 12, 31),
      ),
    ]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(provider: provider),
      ),
    );

    expect(find.byType(SavingsGoalCard), findsOneWidget);
    expect(find.text('ASNB Bumiputera'), findsOneWidget);
  });

  testWidgets('tapping SavingsGoalCard navigates to GoalDetailScreen by default', (tester) async {
    final repository = MockSavingsRepository([
      SavingsGoal(
        id: 'g-1',
        name: 'ASNB Bumiputera',
        targetAmount: 5000.0,
        currentSavings: 1500.0,
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 12, 31),
      ),
    ]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(provider: provider),
      ),
    );

    await tester.tap(find.byType(SavingsGoalCard));
    await tester.pumpAndSettle();

    expect(find.text('Installment Schedule'), findsOneWidget);
  });

  testWidgets('tapping settings icon navigates to SettingsScreen by default', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(provider: provider),
      ),
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Reminder Preferences'), findsOneWidget);
    expect(find.text('Data Management'), findsOneWidget);
  });
}
