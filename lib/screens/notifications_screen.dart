import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_status.dart';
import '../providers/savings_provider.dart';
import '../theme/app_colors.dart';
import 'goal_detail_screen.dart';
import 'settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final SavingsProvider provider;

  const NotificationsScreen({
    super.key,
    required this.provider,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _remindersEnabled = true;
  int _leadDays = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _remindersEnabled = prefs.getBool(SettingsScreen.keyRemindersEnabled) ?? true;
      _leadDays = prefs.getInt(SettingsScreen.keyReminderLeadDays) ?? 3;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final notifications = _collectNotifications();

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return _buildNoticeCard(context, item);
                        },
                      ),
          ),
        );
      },
    );
  }

  List<_NotificationNoticeItem> _collectNotifications() {
    if (!_remindersEnabled) {
      return [];
    }

    final list = <_NotificationNoticeItem>[];
    final currencyFormat = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final goal in widget.provider.goals) {
      for (final installment in goal.installments) {
        if (installment.status != PaymentStatus.pending) continue;

        final dueDateDay = DateTime(
          installment.dueDate.year,
          installment.dueDate.month,
          installment.dueDate.day,
        );

        final daysUntilDue = dueDateDay.difference(today).inDays;
        final isOverdue = daysUntilDue < 0;

        // Show notice only if overdue OR within the configured reminder lead days window
        if (isOverdue || daysUntilDue <= _leadDays) {
          final formattedAmount = currencyFormat.format(installment.amount);
          final formattedDueDate = dateFormat.format(installment.dueDate);

          String noticeMessage;
          if (isOverdue) {
            final daysAgo = daysUntilDue.abs();
            final dayWord = daysAgo == 1 ? 'day' : 'days';
            noticeMessage =
                'Your installment of $formattedAmount for ${installment.monthLabel} is overdue by $daysAgo $dayWord (due $formattedDueDate).';
          } else if (daysUntilDue == 0) {
            noticeMessage =
                'Your installment of $formattedAmount for ${installment.monthLabel} is due today ($formattedDueDate).';
          } else if (daysUntilDue == 1) {
            noticeMessage =
                'Your upcoming installment of $formattedAmount for ${installment.monthLabel} is due tomorrow ($formattedDueDate).';
          } else {
            noticeMessage =
                'Your upcoming installment of $formattedAmount for ${installment.monthLabel} is due in $daysUntilDue days on $formattedDueDate.';
          }

          list.add(
            _NotificationNoticeItem(
              goalId: goal.id,
              goalName: goal.name,
              amountFormatted: formattedAmount,
              noticeMessage: noticeMessage,
              isOverdue: isOverdue,
            ),
          );
        }
      }
    }

    list.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      return 0;
    });

    return list;
  }

  Widget _buildNoticeCard(BuildContext context, _NotificationNoticeItem item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GoalDetailScreen(
              goalId: item.goalId,
              provider: widget.provider,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isOverdue ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.isOverdue
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isOverdue ? Icons.warning_amber_rounded : Icons.notifications_active_outlined,
                size: 20,
                color: item.isOverdue ? AppColors.error : AppColors.primary,
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
                          item.goalName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        item.amountFormatted,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.noticeMessage,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: item.isOverdue ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Text(
              !_remindersEnabled
                  ? 'Reminders are currently disabled in Settings.'
                  : 'You have no pending installment reminders for the configured alert window. Great job keeping your savings on track!',
              textAlign: TextAlign.center,
              style: const TextStyle(
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

class _NotificationNoticeItem {
  final String goalId;
  final String goalName;
  final String amountFormatted;
  final String noticeMessage;
  final bool isOverdue;

  _NotificationNoticeItem({
    required this.goalId,
    required this.goalName,
    required this.amountFormatted,
    required this.noticeMessage,
    required this.isOverdue,
  });
}
