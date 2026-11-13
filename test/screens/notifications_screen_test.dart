import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/notifications_screen.dart';

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
  testWidgets('NotificationsScreen shows empty state when no pending installments', (tester) async {
    final repo = MockSavingsRepository([]);
    final provider = SavingsProvider(repository: repo);
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(provider: provider),
      ),
    );

    expect(find.text('Reminders & Notifications'), findsOneWidget);
    expect(find.text('All Caught Up!'), findsOneWidget);
  });

  testWidgets('NotificationsScreen lists pending installment alerts and links to goal detail', (tester) async {
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
          monthLabel: 'March 2027',
          amount: 200.0,
          dueDate: DateTime(now.year, now.month + 1, 25),
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

    expect(find.text('ASNB Bumiputera'), findsOneWidget);
    expect(find.text('Installment: March 2027'), findsOneWidget);
    expect(find.text('RM 200.00'), findsOneWidget);
    expect(find.text('View & Pay Early'), findsOneWidget);

    await tester.tap(find.text('View & Pay Early'));
    await tester.pumpAndSettle();

    expect(find.text('Installment Schedule'), findsOneWidget);
  });
}
