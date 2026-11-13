import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/installment_item.dart';
import '../models/payment_status.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/installment_row_item.dart';

class GoalDetailScreen extends StatefulWidget {
  final String goalId;
  final SavingsProvider provider;

  const GoalDetailScreen({
    super.key,
    required this.goalId,
    required this.provider,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final Set<String> _selectedInstallmentIds = {};

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  void _toggleSelect(String id, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedInstallmentIds.add(id);
      } else {
        _selectedInstallmentIds.remove(id);
      }
    });
  }

  void _selectAll(List<InstallmentItem> pending) {
    setState(() {
      if (_selectedInstallmentIds.length == pending.length) {
        _selectedInstallmentIds.clear();
      } else {
        _selectedInstallmentIds.clear();
        _selectedInstallmentIds.addAll(pending.map((i) => i.id));
      }
    });
  }

  Future<void> _processBatchPayEarly(BuildContext context, SavingsGoal goal, List<InstallmentItem> pendingItems) async {
    final selectedItems = pendingItems.where((i) => _selectedInstallmentIds.contains(i.id)).toList();
    if (selectedItems.isEmpty) return;

    final totalAmount = selectedItems.fold<double>(0.0, (sum, item) => sum + item.amount);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Pay Early Confirmation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Pay early for ${selectedItems.length} selected installment(s) totaling ${_formatCurrency(totalAmount)}? This will increase your current savings and mark them as Paid Early.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      for (final item in selectedItems) {
        await widget.provider.payEarlyInstallment(
          goalId: goal.id,
          installmentId: item.id,
        );
      }
      setState(() {
        _selectedInstallmentIds.clear();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully paid ${_formatCurrency(totalAmount)} early!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteGoal(BuildContext context, SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Delete Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await widget.provider.deleteGoal(goal.id);
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final goalIndex = widget.provider.goals.indexWhere((g) => g.id == widget.goalId);
        if (goalIndex == -1) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Goal Details'),
            ),
            body: const Center(
              child: Text(
                'Goal not found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final goal = widget.provider.goals[goalIndex];
        final pendingInstallments = goal.installments
            .where((i) => i.status == PaymentStatus.pending)
            .toList();

        final selectedPendingItems = pendingInstallments
            .where((i) => _selectedInstallmentIds.contains(i.id))
            .toList();
        final selectedTotalAmount = selectedPendingItems.fold<double>(
          0.0,
          (sum, item) => sum + item.amount,
        );

        final monthlyRate = goal.installments.isNotEmpty
            ? goal.installments.first.amount
            : 0.0;

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
            title: Text(
              goal.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: 'Delete Goal',
                onPressed: () => _confirmDeleteGoal(context, goal),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _buildTopCard(goal, monthlyRate),
                const SizedBox(height: 24),
                _buildScheduleHeader(context, goal, pendingInstallments),
                const SizedBox(height: 12),
                _buildScheduleList(context, goal),
                const SizedBox(height: 96),
              ],
            ),
          ),
          bottomSheet: pendingInstallments.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const Key('pay_early_bottom_button'),
                        onPressed: selectedPendingItems.isNotEmpty
                            ? () => _processBatchPayEarly(context, goal, pendingInstallments)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.neutral.withValues(alpha: 0.3),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          selectedPendingItems.isNotEmpty
                              ? 'PAY EARLY (${_formatCurrency(selectedTotalAmount)})'
                              : 'SELECT INSTALLMENTS TO PAY EARLY',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildTopCard(SavingsGoal goal, double monthlyRate) {
    final percentage = (goal.progressPercentage * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(20),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Target Date: ${_formatDate(goal.targetDate)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progressPercentage,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatCurrency(goal.currentSavings)} / ${_formatCurrency(goal.targetAmount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Remaining: ${_formatCurrency(goal.remainingAmount)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.border,
                width: 1.0,
              ),
            ),
            child: Text(
              'Monthly: ${_formatCurrency(monthlyRate)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleHeader(
    BuildContext context,
    SavingsGoal goal,
    List<InstallmentItem> pendingInstallments,
  ) {
    final allSelected = pendingInstallments.isNotEmpty &&
        _selectedInstallmentIds.length == pendingInstallments.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Installment Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '${pendingInstallments.length} pending',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (pendingInstallments.isNotEmpty)
          TextButton(
            onPressed: () => _selectAll(pendingInstallments),
            child: Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleList(BuildContext context, SavingsGoal goal) {
    if (goal.installments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
        child: const Center(
          child: Text(
            'No installments scheduled',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: goal.installments.map((installment) {
          final isSelected = _selectedInstallmentIds.contains(installment.id);
          return InstallmentRowItem(
            installment: installment,
            isSelected: isSelected,
            onSelectChanged: (val) => _toggleSelect(installment.id, val),
          );
        }).toList(),
      ),
    );
  }
}
