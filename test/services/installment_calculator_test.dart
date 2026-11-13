import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/services/installment_calculator.dart';

void main() {
  group('InstallmentCalculator', () {
    test('returns empty list when currentSavings >= targetAmount', () {
      final schedule = InstallmentCalculator.generateSchedule(
        targetAmount: 1000.0,
        currentSavings: 1000.0,
        startDate: DateTime(2027, 1, 1),
        targetDate: DateTime(2027, 10, 25),
        dueDay: 25,
      );
      expect(schedule, isEmpty);

      final scheduleOver = InstallmentCalculator.generateSchedule(
        targetAmount: 1000.0,
        currentSavings: 1200.0,
        startDate: DateTime(2027, 1, 1),
        targetDate: DateTime(2027, 10, 25),
        dueDay: 25,
      );
      expect(scheduleOver, isEmpty);
    });

    test('generates minimum 1 installment when targetDate is in same month or in past', () {
      final scheduleSameMonth = InstallmentCalculator.generateSchedule(
        targetAmount: 1000.0,
        currentSavings: 400.0,
        startDate: DateTime(2027, 3, 10),
        targetDate: DateTime(2027, 3, 20),
        dueDay: 25,
      );
      expect(scheduleSameMonth.length, 1);
      expect(scheduleSameMonth.first.amount, 600.0);
      expect(scheduleSameMonth.first.status, PaymentStatus.pending);
      expect(scheduleSameMonth.first.monthLabel, 'March 2027');

      final schedulePast = InstallmentCalculator.generateSchedule(
        targetAmount: 500.0,
        currentSavings: 100.0,
        startDate: DateTime(2027, 5, 10),
        targetDate: DateTime(2027, 2, 10),
        dueDay: 15,
      );
      expect(schedulePast.length, 1);
      expect(schedulePast.first.amount, 400.0);
      expect(schedulePast.first.monthLabel, 'May 2027');
    });

    test('generates correct monthly schedule across multiple months', () {
      // Jan 2027 to Jun 2027 = 6 months: Jan, Feb, Mar, Apr, May, Jun
      final schedule = InstallmentCalculator.generateSchedule(
        targetAmount: 1200.0,
        currentSavings: 0.0,
        startDate: DateTime(2027, 1, 15),
        targetDate: DateTime(2027, 6, 25),
        dueDay: 25,
      );

      expect(schedule.length, 6);
      expect(schedule[0].monthLabel, 'January 2027');
      expect(schedule[1].monthLabel, 'February 2027');
      expect(schedule[2].monthLabel, 'March 2027');
      expect(schedule[3].monthLabel, 'April 2027');
      expect(schedule[4].monthLabel, 'May 2027');
      expect(schedule[5].monthLabel, 'June 2027');

      for (final item in schedule) {
        expect(item.amount, 200.0);
        expect(item.status, PaymentStatus.pending);
      }
    });

    test('distributes penny-rounding evenly so sum strictly equals target minus currentSavings', () {
      // Remaining = 1000.0. 3 months: Jan, Feb, Mar 2027
      // 1000 / 3 = 333.3333...
      // Expected sum = 1000.00 exactly (e.g. 333.34 + 333.33 + 333.33 = 1000.00)
      final schedule = InstallmentCalculator.generateSchedule(
        targetAmount: 1000.0,
        currentSavings: 0.0,
        startDate: DateTime(2027, 1, 1),
        targetDate: DateTime(2027, 3, 25),
        dueDay: 25,
      );

      expect(schedule.length, 3);
      final total = schedule.fold<double>(0.0, (acc, item) => acc + item.amount);
      // Compare with micro-precision tolerance for double
      expect((total - 1000.0).abs() < 0.0001, isTrue);
      expect(schedule[0].amount, 333.34);
      expect(schedule[1].amount, 333.33);
      expect(schedule[2].amount, 333.33);
    });

    test('handles dueDay exceeding days in month properly (e.g. Feb 30 clamped to Feb 28/29)', () {
      final schedule = InstallmentCalculator.generateSchedule(
        targetAmount: 400.0,
        currentSavings: 0.0,
        startDate: DateTime(2027, 1, 1),
        targetDate: DateTime(2027, 2, 28),
        dueDay: 31,
      );

      expect(schedule.length, 2);
      expect(schedule[0].dueDate, DateTime(2027, 1, 31));
      // 2027 is not a leap year, so Feb has 28 days
      expect(schedule[1].dueDate, DateTime(2027, 2, 28));
    });
  });
}
