import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_status.dart';
import '../models/savings_goal.dart';
import '../theme/app_colors.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  PaymentStatus get _currentStatus {
    final now = DateTime.now();
    for (final inst in goal.installments) {
      if (inst.dueDate.year == now.year && inst.dueDate.month == now.month) {
        return inst.status;
      }
    }
    if (goal.isCompleted) {
      return PaymentStatus.paid;
    }
    return goal.nextPendingInstallment != null
        ? PaymentStatus.pending
        : PaymentStatus.paid;
  }

  double get _currentCommitmentRate {
    final now = DateTime.now();
    for (final inst in goal.installments) {
      if (inst.dueDate.year == now.year && inst.dueDate.month == now.month) {
        return inst.amount;
      }
    }
    final next = goal.nextPendingInstallment;
    if (next != null) {
      return next.amount;
    }
    if (goal.installments.isNotEmpty) {
      return goal.installments.last.amount;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentStatus;
    final isPaid = status == PaymentStatus.paid || status == PaymentStatus.paidEarly;
    final percentage = (goal.progressPercentage * 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      isPaid ? 'Paid' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPaid ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatCurrency(goal.currentSavings)} / ${_formatCurrency(goal.targetAmount)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_formatCurrency(_currentCommitmentRate)} / mo',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
