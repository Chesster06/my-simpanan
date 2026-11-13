import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/widgets/savings_goal_card.dart';

void main() {
  final testGoal = SavingsGoal(
    id: 'goal-1',
    name: 'ASNB Bumiputera',
    targetAmount: 10000.0,
    currentSavings: 4000.0,
    startDate: DateTime(2026, 1, 1),
    targetDate: DateTime(2026, 12, 31),
    dueDay: 25,
    installments: [
      InstallmentItem(
        id: 'inst-1',
        monthLabel: 'Nov 2026',
        amount: 500.0,
        dueDate: DateTime(2026, 11, 25),
        status: PaymentStatus.pending,
      ),
    ],
  );

  testWidgets('SavingsGoalCard displays goal details, commitment, and responds to tap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavingsGoalCard(
            goal: testGoal,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('ASNB Bumiputera'), findsOneWidget);
    expect(find.text('RM 4,000.00 / RM 10,000.00'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('RM 500.00 / mo'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    final progressFinder = find.byType(LinearProgressIndicator);
    expect(progressFinder, findsOneWidget);
    final progress = tester.widget<LinearProgressIndicator>(progressFinder);
    expect(progress.value, 0.4);

    await tester.tap(find.byType(SavingsGoalCard));
    expect(tapped, isTrue);
  });

  testWidgets('SavingsGoalCard displays Paid status badge when current installment is paid', (tester) async {
    final paidGoal = testGoal.copyWith(
      currentSavings: 10000.0,
      installments: [
        InstallmentItem(
          id: 'inst-1',
          monthLabel: 'Nov 2026',
          amount: 500.0,
          dueDate: DateTime(2026, 11, 25),
          status: PaymentStatus.paid,
          paidDate: DateTime(2026, 11, 10),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavingsGoalCard(
            goal: paidGoal,
          ),
        ),
      ),
    );

    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });
}
