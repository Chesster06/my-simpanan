import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/savings_goal.dart';

void main() {
  group('PaymentStatus', () {
    test('serialization and displayName work properly', () {
      expect(PaymentStatus.pending.name, 'pending');
      expect(PaymentStatus.paid.name, 'paid');
      expect(PaymentStatus.paidEarly.name, 'paidEarly');

      expect(PaymentStatus.pending.displayName, 'Pending');
      expect(PaymentStatus.paid.displayName, 'Paid');
      expect(PaymentStatus.paidEarly.displayName, 'Paid Early');

      expect(PaymentStatusExtension.fromString('pending'), PaymentStatus.pending);
      expect(PaymentStatusExtension.fromString('paid'), PaymentStatus.paid);
      expect(PaymentStatusExtension.fromString('paidEarly'), PaymentStatus.paidEarly);
      expect(PaymentStatusExtension.fromString('unknown'), PaymentStatus.pending);
    });
  });

  group('InstallmentItem', () {
    test('instantiation, copyWith, and json serialization', () {
      final dueDate = DateTime(2027, 1, 25);
      final item = InstallmentItem(
        id: 'inst-1',
        monthLabel: 'January 2027',
        amount: 250.0,
        dueDate: dueDate,
        status: PaymentStatus.pending,
      );

      expect(item.id, 'inst-1');
      expect(item.monthLabel, 'January 2027');
      expect(item.amount, 250.0);
      expect(item.dueDate, dueDate);
      expect(item.status, PaymentStatus.pending);
      expect(item.paidDate, isNull);

      final paidDate = DateTime(2027, 1, 20);
      final updated = item.copyWith(
        status: PaymentStatus.paidEarly,
        paidDate: paidDate,
      );
      expect(updated.status, PaymentStatus.paidEarly);
      expect(updated.paidDate, paidDate);
      expect(updated.amount, 250.0);

      final json = updated.toJson();
      final restored = InstallmentItem.fromJson(json);

      expect(restored.id, updated.id);
      expect(restored.monthLabel, updated.monthLabel);
      expect(restored.amount, updated.amount);
      expect(restored.dueDate, updated.dueDate);
      expect(restored.status, updated.status);
      expect(restored.paidDate, updated.paidDate);
    });
  });

  group('SavingsGoal', () {
    test('instantiation, copyWith, json serialization, and calculated getters', () {
      final start = DateTime(2027, 1, 1);
      final target = DateTime(2027, 4, 25);
      final inst1 = InstallmentItem(
        id: '1',
        monthLabel: 'January 2027',
        amount: 250.0,
        dueDate: DateTime(2027, 1, 25),
        status: PaymentStatus.paid,
        paidDate: DateTime(2027, 1, 25),
      );
      final inst2 = InstallmentItem(
        id: '2',
        monthLabel: 'February 2027',
        amount: 250.0,
        dueDate: DateTime(2027, 2, 25),
        status: PaymentStatus.pending,
      );

      final goal = SavingsGoal(
        id: 'goal-1',
        name: 'Emergency Fund',
        targetAmount: 1000.0,
        currentSavings: 250.0,
        startDate: start,
        targetDate: target,
        dueDay: 25,
        installments: [inst1, inst2],
      );

      expect(goal.remainingAmount, 750.0);
      expect(goal.progressPercentage, 0.25);
      expect(goal.isCompleted, isFalse);
      expect(goal.nextPendingInstallment, inst2);

      final completedGoal = goal.copyWith(currentSavings: 1000.0);
      expect(completedGoal.remainingAmount, 0.0);
      expect(completedGoal.progressPercentage, 1.0);
      expect(completedGoal.isCompleted, isTrue);

      final json = goal.toJson();
      final fromJson = SavingsGoal.fromJson(json);

      expect(fromJson.id, goal.id);
      expect(fromJson.name, goal.name);
      expect(fromJson.targetAmount, goal.targetAmount);
      expect(fromJson.currentSavings, goal.currentSavings);
      expect(fromJson.startDate, goal.startDate);
      expect(fromJson.targetDate, goal.targetDate);
      expect(fromJson.dueDay, goal.dueDay);
      expect(fromJson.installments.length, 2);
      expect(fromJson.installments.first.id, '1');
    });

    test('progressPercentage handles targetAmount zero or negative cleanly', () {
      final goalZero = SavingsGoal(
        id: 'zero',
        name: 'Zero',
        targetAmount: 0.0,
        currentSavings: 0.0,
        startDate: DateTime(2027, 1, 1),
        targetDate: DateTime(2027, 1, 25),
      );
      expect(goalZero.progressPercentage, 0.0);
      expect(goalZero.isCompleted, isTrue);

      final goalOver = goalZero.copyWith(targetAmount: 100.0, currentSavings: 150.0);
      expect(goalOver.progressPercentage, 1.0);
      expect(goalOver.remainingAmount, 0.0);
    });
  });
}
