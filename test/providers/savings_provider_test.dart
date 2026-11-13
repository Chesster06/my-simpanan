import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';

class FakeSavingsRepository implements SavingsRepository {
  List<SavingsGoal> storedGoals = [];

  @override
  Future<List<SavingsGoal>> loadGoals() async {
    return List.from(storedGoals);
  }

  @override
  Future<void> saveGoals(List<SavingsGoal> goals) async {
    storedGoals = List.from(goals);
  }
}

void main() {
  group('SavingsProvider', () {
    late FakeSavingsRepository repository;
    late SavingsProvider provider;

    setUp(() {
      repository = FakeSavingsRepository();
      provider = SavingsProvider(repository: repository);
    });

    test('initialize loads goals from repository and updates isLoading state', () async {
      repository.storedGoals = [
        SavingsGoal(
          id: 'goal-1',
          name: 'Emergency Fund',
          targetAmount: 3000.0,
          currentSavings: 500.0,
          startDate: DateTime(2026, 1, 1),
          targetDate: DateTime(2026, 6, 1),
        ),
      ];

      expect(provider.isLoading, false);
      expect(provider.goals, isEmpty);

      final initFuture = provider.initialize();
      expect(provider.isLoading, true);

      await initFuture;
      expect(provider.isLoading, false);
      expect(provider.goals.length, 1);
      expect(provider.goals.first.name, 'Emergency Fund');
    });

    test('calculated getters return accurate values across multiple goals and installments', () async {
      final now = DateTime.now();
      final currentMonthDue = DateTime(now.year, now.month, 15);
      final nextMonthDue = DateTime(now.year, now.month + 1, 15);

      final goal1 = SavingsGoal(
        id: 'goal-1',
        name: 'Goal 1',
        targetAmount: 1000.0,
        currentSavings: 200.0,
        startDate: DateTime(now.year, 1, 1),
        targetDate: DateTime(now.year + 1, 1, 1),
        installments: [
          InstallmentItem(
            id: 'i-1',
            monthLabel: 'Month 1',
            amount: 100.0,
            dueDate: currentMonthDue,
            status: PaymentStatus.pending,
          ),
          InstallmentItem(
            id: 'i-2',
            monthLabel: 'Month 2',
            amount: 100.0,
            dueDate: nextMonthDue,
            status: PaymentStatus.pending,
          ),
        ],
      );

      final goal2 = SavingsGoal(
        id: 'goal-2',
        name: 'Goal 2',
        targetAmount: 2000.0,
        currentSavings: 600.0,
        startDate: DateTime(now.year, 1, 1),
        targetDate: DateTime(now.year + 1, 1, 1),
        installments: [
          InstallmentItem(
            id: 'i-3',
            monthLabel: 'Month 1',
            amount: 150.0,
            dueDate: currentMonthDue,
            status: PaymentStatus.pending,
          ),
          InstallmentItem(
            id: 'i-4',
            monthLabel: 'Month 2',
            amount: 150.0,
            dueDate: nextMonthDue,
            status: PaymentStatus.paid,
            paidDate: now,
          ),
        ],
      );

      repository.storedGoals = [goal1, goal2];
      await provider.initialize();

      expect(provider.totalSavings, 800.0);
      expect(provider.totalTarget, 3000.0);
      expect(provider.monthlyCommitmentForCurrentMonth, 250.0);
      expect(provider.pendingInstallmentsCount, 3);
    });

    test('addGoal appends goal, persists via repository, and notifies listeners', () async {
      await provider.initialize();

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      final newGoal = SavingsGoal(
        id: 'new-goal',
        name: 'Vacation',
        targetAmount: 1500.0,
        currentSavings: 0.0,
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 12, 1),
      );

      await provider.addGoal(newGoal);

      expect(notified, true);
      expect(provider.goals.length, 1);
      expect(repository.storedGoals.length, 1);
      expect(repository.storedGoals.first.id, 'new-goal');
    });

    test('updateGoal modifies existing goal and persists changes', () async {
      final initialGoal = SavingsGoal(
        id: 'goal-1',
        name: 'Old Name',
        targetAmount: 1000.0,
        currentSavings: 100.0,
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 6, 1),
      );
      repository.storedGoals = [initialGoal];
      await provider.initialize();

      final updated = initialGoal.copyWith(name: 'Updated Name', currentSavings: 300.0);
      await provider.updateGoal(updated);

      expect(provider.goals.first.name, 'Updated Name');
      expect(provider.goals.first.currentSavings, 300.0);
      expect(repository.storedGoals.first.name, 'Updated Name');
    });

    test('deleteGoal removes goal and persists changes', () async {
      repository.storedGoals = [
        SavingsGoal(
          id: 'goal-1',
          name: 'Goal 1',
          targetAmount: 1000.0,
          currentSavings: 0.0,
          startDate: DateTime(2026, 1, 1),
          targetDate: DateTime(2026, 6, 1),
        ),
      ];
      await provider.initialize();

      await provider.deleteGoal('goal-1');

      expect(provider.goals, isEmpty);
      expect(repository.storedGoals, isEmpty);
    });

    test('payInstallment marks installment as paid, records paidDate, and increments savings', () async {
      final item = InstallmentItem(
        id: 'inst-1',
        monthLabel: 'May 2026',
        amount: 250.0,
        dueDate: DateTime(2026, 5, 25),
        status: PaymentStatus.pending,
      );
      final goal = SavingsGoal(
        id: 'goal-1',
        name: 'Gadget',
        targetAmount: 1000.0,
        currentSavings: 100.0,
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 6, 1),
        installments: [item],
      );
      repository.storedGoals = [goal];
      await provider.initialize();

      await provider.payInstallment(goalId: 'goal-1', installmentId: 'inst-1');

      final updatedGoal = provider.goals.first;
      expect(updatedGoal.currentSavings, 350.0);
      final updatedItem = updatedGoal.installments.first;
      expect(updatedItem.status, PaymentStatus.paid);
      expect(updatedItem.paidDate, isNotNull);
      expect(repository.storedGoals.first.currentSavings, 350.0);
    });

    test('payEarlyInstallment marks installment as paidEarly, sets paidDate, and increments savings', () async {
      final item = InstallmentItem(
        id: 'inst-future',
        monthLabel: 'Dec 2026',
        amount: 300.0,
        dueDate: DateTime(2026, 12, 25),
        status: PaymentStatus.pending,
      );
      final goal = SavingsGoal(
        id: 'goal-1',
        name: 'Investment',
        targetAmount: 2000.0,
        currentSavings: 500.0,
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 12, 31),
        installments: [item],
      );
      repository.storedGoals = [goal];
      await provider.initialize();

      await provider.payEarlyInstallment(goalId: 'goal-1', installmentId: 'inst-future');

      final updatedGoal = provider.goals.first;
      expect(updatedGoal.currentSavings, 800.0);
      final updatedItem = updatedGoal.installments.first;
      expect(updatedItem.status, PaymentStatus.paidEarly);
      expect(updatedItem.paidDate, isNotNull);
      expect(repository.storedGoals.first.currentSavings, 800.0);
      expect(repository.storedGoals.first.installments.first.status, PaymentStatus.paidEarly);
    });
  });
}
