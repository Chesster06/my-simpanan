import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/notifications_screen.dart';
import 'package:mysimpanan/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      SettingsScreen.keyRemindersEnabled: true,
      SettingsScreen.keyReminderLeadDays: 3,
    });
  });

  testWidgets('NotificationsScreen shows empty state when no pending installments', (tester) async {
    final repo = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repo);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reminders & Notifications'), findsOneWidget);
    expect(find.text('All Caught Up!'), findsOneWidget);
  });

  testWidgets('NotificationsScreen displays clean text notices according to lead settings and navigates on tap', (tester) async {
    final now = DateTime.now();
    // Due 2 days from now (within 3-day lead window)
    final dueInTwoDays = DateTime(now.year, now.month, now.day + 2);
    // Due 30 days from now (outside 3-day lead window, shouldn't appear)
    final dueInThirtyDays = DateTime(now.year, now.month, now.day + 30);

    final goal = SavingsGoal(
      id: 'g-asnb',
      name: 'ASNB Bumiputera',
      targetAmount: 1000,
      currentSavings: 200,
      startDate: DateTime(now.year, now.month, 1),
      targetDate: DateTime(now.year, now.month + 3, 25),
      installments: [
        InstallmentItem(
          id: 'inst-1',
          monthLabel: 'November 2026',
          amount: 200.0,
          dueDate: dueInTwoDays,
          status: PaymentStatus.pending,
        ),
        InstallmentItem(
          id: 'inst-2',
          monthLabel: 'December 2026',
          amount: 200.0,
          dueDate: dueInThirtyDays,
          status: PaymentStatus.pending,
        ),
      ],
    );

    final repo = MockSavingsRepository([goal]);
    final provider = SavingsProvider(repository: repo);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    // The near installment displays as plain text notice
    expect(find.text('ASNB Bumiputera'), findsOneWidget);
    expect(find.text('RM 200.00'), findsOneWidget);
    expect(find.textContaining('Your upcoming installment of RM 200.00 for November 2026 is due in 2 days'), findsOneWidget);

    // Far installment does not appear because it's outside the 3-day setting
    expect(find.textContaining('December 2026'), findsNothing);

    // No buttons inside notice cards
    expect(find.text('View & Pay Early'), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);

    // Tap on notice card navigates to goal detail
    await tester.tap(find.text('ASNB Bumiputera'));
    await tester.pumpAndSettle();

    expect(find.text('Installment Schedule'), findsOneWidget);
  });

  testWidgets('NotificationsScreen shows empty state if reminders are disabled in settings', (tester) async {
    SharedPreferences.setMockInitialValues({
      SettingsScreen.keyRemindersEnabled: false,
      SettingsScreen.keyReminderLeadDays: 3,
    });

    final now = DateTime.now();
    final goal = SavingsGoal(
      id: 'g-asnb',
      name: 'ASNB Bumiputera',
      targetAmount: 1000,
      currentSavings: 200,
      startDate: DateTime(now.year, now.month, 1),
      targetDate: DateTime(now.year, now.month + 3, 25),
      installments: [
        InstallmentItem(
          id: 'inst-1',
          monthLabel: 'November 2026',
          amount: 200.0,
          dueDate: DateTime(now.year, now.month, now.day + 1),
          status: PaymentStatus.pending,
        ),
      ],
    );

    final repo = MockSavingsRepository([goal]);
    final provider = SavingsProvider(repository: repo);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Caught Up!'), findsOneWidget);
    expect(find.text('Reminders are currently disabled in Settings.'), findsOneWidget);
  });
}
