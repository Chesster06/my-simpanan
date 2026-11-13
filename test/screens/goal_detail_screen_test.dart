import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/goal_detail_screen.dart';

class MockSavingsRepository implements SavingsRepository {
  List<SavingsGoal> storedGoals;

  MockSavingsRepository({required this.storedGoals});

  @override
  Future<List<SavingsGoal>> loadGoals() async => List.from(storedGoals);

  @override
  Future<void> saveGoals(List<SavingsGoal> goals) async {
    storedGoals = List.from(goals);
  }
}

void main() {
  group('GoalDetailScreen', () {
    late MockSavingsRepository mockRepository;
    late SavingsProvider provider;
    late SavingsGoal testGoal;

    setUp(() async {
      final now = DateTime(2027, 1, 1);
      final installments = [
        InstallmentItem(
          id: 'inst-1',
          monthLabel: 'January 2027',
          amount: 250.0,
          dueDate: DateTime(2027, 1, 25),
          status: PaymentStatus.paid,
          paidDate: DateTime(2027, 1, 20),
        ),
        InstallmentItem(
          id: 'inst-2',
          monthLabel: 'February 2027',
          amount: 250.0,
          dueDate: DateTime(2027, 2, 25),
          status: PaymentStatus.pending,
        ),
        InstallmentItem(
          id: 'inst-3',
          monthLabel: 'March 2027',
          amount: 250.0,
          dueDate: DateTime(2027, 3, 25),
          status: PaymentStatus.pending,
        ),
        InstallmentItem(
          id: 'inst-4',
          monthLabel: 'April 2027',
          amount: 250.0,
          dueDate: DateTime(2027, 4, 25),
          status: PaymentStatus.pending,
        ),
      ];

      testGoal = SavingsGoal(
        id: 'goal-1',
        name: 'New Laptop',
        targetAmount: 1000.0,
        currentSavings: 250.0,
        startDate: now,
        targetDate: DateTime(2027, 4, 25),
        installments: installments,
      );

      mockRepository = MockSavingsRepository(storedGoals: [testGoal]);
      provider = SavingsProvider(repository: mockRepository);
      await provider.initialize();
    });

    testWidgets('renders goal details, top card, and installment schedule with checkboxes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GoalDetailScreen(
            goalId: 'goal-1',
            provider: provider,
          ),
        ),
      );

      expect(find.text('New Laptop'), findsWidgets);
      expect(find.text('Target Date: 25 Apr 2027'), findsOneWidget);
      expect(find.text('RM 250.00 / RM 1,000.00'), findsOneWidget);
      expect(find.text('Remaining: RM 750.00'), findsOneWidget);
      expect(find.text('Monthly: RM 250.00'), findsOneWidget);
      expect(find.text('Installment Schedule'), findsOneWidget);
      expect(find.text('3 pending'), findsOneWidget);
      expect(find.text('Select All'), findsOneWidget);

      expect(find.text('January 2027'), findsOneWidget);
      expect(find.text('February 2027'), findsOneWidget);
      expect(find.text('March 2027'), findsOneWidget);
      expect(find.text('April 2027'), findsOneWidget);

      expect(find.byType(Checkbox), findsNWidgets(3));
      expect(find.byKey(const Key('pay_early_bottom_button')), findsOneWidget);
    });

    testWidgets('selecting checkbox enables bottom PAY EARLY button and confirms payment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GoalDetailScreen(
            goalId: 'goal-1',
            provider: provider,
          ),
        ),
      );

      // Select February 2027
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      expect(find.text('PAY EARLY (RM 250.00)'), findsOneWidget);

      await tester.tap(find.byKey(const Key('pay_early_bottom_button')));
      await tester.pumpAndSettle();

      // Check dialog content
      expect(find.text('Pay Early Confirmation'), findsOneWidget);
      expect(find.textContaining('Pay early for 1 selected installment(s) totaling RM 250.00?'), findsOneWidget);

      // Confirm payment
      final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify the installment updated to Paid Early
      final updatedGoal = provider.goals.firstWhere((g) => g.id == 'goal-1');
      final febInst = updatedGoal.installments.firstWhere((i) => i.id == 'inst-2');
      expect(febInst.status, PaymentStatus.paidEarly);
      expect(updatedGoal.currentSavings, 500.0);
    });

    testWidgets('Select All toggles all pending installments and pays batch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GoalDetailScreen(
            goalId: 'goal-1',
            provider: provider,
          ),
        ),
      );

      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();

      expect(find.text('Deselect All'), findsOneWidget);
      expect(find.text('PAY EARLY (RM 750.00)'), findsOneWidget);

      await tester.tap(find.byKey(const Key('pay_early_bottom_button')));
      await tester.pumpAndSettle();

      final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      final updatedGoal = provider.goals.firstWhere((g) => g.id == 'goal-1');
      expect(updatedGoal.installments.every((i) => i.status == PaymentStatus.paid || i.status == PaymentStatus.paidEarly), isTrue);
      expect(updatedGoal.currentSavings, 1000.0);
    });

    testWidgets('delete goal prompts confirmation and deletes goal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GoalDetailScreen(
            goalId: 'goal-1',
            provider: provider,
          ),
        ),
      );

      final deleteIcon = find.byIcon(Icons.delete_outline);
      expect(deleteIcon, findsOneWidget);

      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      expect(find.text('Delete Goal'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to delete "New Laptop"?'), findsOneWidget);

      final deleteBtn = find.widgetWithText(TextButton, 'Delete');
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(provider.goals.any((g) => g.id == 'goal-1'), isFalse);
    });
  });
}
