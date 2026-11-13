import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/installment_item.dart';
import '../models/payment_status.dart';
import '../theme/app_colors.dart';
import 'installment_status_chip.dart';

class InstallmentRowItem extends StatelessWidget {
  final InstallmentItem installment;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback? onPayEarly;

  const InstallmentRowItem({
    super.key,
    required this.installment,
    this.isSelected = false,
    this.onSelectChanged,
    this.onPayEarly,
  });

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

  @override
  Widget build(BuildContext context) {
    final isPending = installment.status == PaymentStatus.pending;

    return InkWell(
      onTap: isPending && onSelectChanged != null ? () => onSelectChanged!(!isSelected) : null,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE8E8EC),
              width: 1.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (isPending) ...[
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onSelectChanged,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              const Icon(
                Icons.check_circle,
                size: 22,
                color: AppColors.success,
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    installment.monthLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due ${_formatDate(installment.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(installment.amount),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (isPending)
                  InstallmentStatusChip(status: installment.status)
                else
                  Text(
                    installment.paidDate != null
                        ? 'Paid ${_formatDate(installment.paidDate!)}'
                        : 'Paid',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
