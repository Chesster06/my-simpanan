import '../models/installment_item.dart';
import '../models/payment_status.dart';

class InstallmentCalculator {
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static List<InstallmentItem> generateSchedule({
    required double targetAmount,
    required double currentSavings,
    required DateTime startDate,
    required DateTime targetDate,
    required int dueDay,
  }) {
    final remainingAmount = targetAmount - currentSavings;
    if (remainingAmount <= 0) {
      return [];
    }

    // Determine number of monthly installments
    int monthDifference = (targetDate.year - startDate.year) * 12 + (targetDate.month - startDate.month) + 1;
    if (monthDifference < 1) {
      monthDifference = 1;
    }

    // Convert remaining amount into cents to ensure penny-exact integer math
    final totalCents = (remainingAmount * 100).round();
    final baseCents = totalCents ~/ monthDifference;
    final remainderCents = totalCents % monthDifference;

    final List<InstallmentItem> schedule = [];

    for (int i = 0; i < monthDifference; i++) {
      // Calculate year and month for this installment
      final totalMonthOffset = (startDate.year * 12) + (startDate.month - 1) + i;
      final year = totalMonthOffset ~/ 12;
      final month = (totalMonthOffset % 12) + 1;

      // Handle month days limit (e.g., Feb 28/29 or April 30)
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final actualDueDay = dueDay > daysInMonth ? daysInMonth : (dueDay < 1 ? 1 : dueDay);
      final dueDate = DateTime(year, month, actualDueDay);

      // Distribute extra cents across earlier months
      final itemCents = baseCents + (i < remainderCents ? 1 : 0);
      final amount = itemCents / 100.0;

      final monthLabel = '${_monthNames[month - 1]} $year';

      schedule.add(
        InstallmentItem(
          id: 'inst_${year}_$month',
          monthLabel: monthLabel,
          amount: amount,
          dueDate: dueDate,
          status: PaymentStatus.pending,
        ),
      );
    }

    return schedule;
  }
}
