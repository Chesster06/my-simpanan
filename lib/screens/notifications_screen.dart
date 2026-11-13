import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_status.dart';
import '../providers/savings_provider.dart';
import '../theme/app_colors.dart';
import 'goal_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final SavingsProvider provider;

  const NotificationsScreen({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final pendingAlerts = _collectPendingInstallmentAlerts();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: AppColors.border,
                height: 1.0,
              ),
            ),
            title: const Text(
              'Reminders & Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: pendingAlerts.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingAlerts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alert = pendingAlerts[index];
                      return _buildAlertCard(context, alert);
                    },
                  ),
          ),
        );
      },
    );
  }

  List<_NotificationAlertItem> _collectPendingInstallmentAlerts() {
    final list = <_NotificationAlertItem>[];
    final currencyFormat = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    for (final goal in provider.goals) {
      for (final installment in goal.installments) {
        if (installment.status == PaymentStatus.pending) {
          final isOverdue = installment.dueDate.isBefore(DateTime.now());
          list.add(
            _NotificationAlertItem(
              goalId: goal.id,
              goalName: goal.name,
              monthLabel: installment.monthLabel,
              amountFormatted: currencyFormat.format(installment.amount),
              dueDateFormatted: dateFormat.format(installment.dueDate),
              isOverdue: isOverdue,
            ),
          );
        }
      }
    }
    return list;
  }

  Widget _buildAlertCard(BuildContext context, _NotificationAlertItem alert) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.isOverdue ? AppColors.error.withValues(alpha: 0.4) : AppColors.border,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert.isOverdue
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              alert.isOverdue ? Icons.warning_amber_rounded : Icons.notifications_active_outlined,
              size: 22,
              color: alert.isOverdue ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alert.goalName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      alert.amountFormatted,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Installment: ${alert.monthLabel}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.isOverdue
                      ? 'Overdue since ${alert.dueDateFormatted}'
                      : 'Upcoming due date: ${alert.dueDateFormatted}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: alert.isOverdue ? AppColors.error : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GoalDetailScreen(
                            goalId: alert.goalId,
                            provider: provider,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                    child: const Text(
                      'View & Pay Early',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 44,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have no pending installment reminders at the moment. Great job on keeping your savings on track!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationAlertItem {
  final String goalId;
  final String goalName;
  final String monthLabel;
  final String amountFormatted;
  final String dueDateFormatted;
  final bool isOverdue;

  _NotificationAlertItem({
    required this.goalId,
    required this.goalName,
    required this.monthLabel,
    required this.amountFormatted,
    required this.dueDateFormatted,
    required this.isOverdue,
  });
}
