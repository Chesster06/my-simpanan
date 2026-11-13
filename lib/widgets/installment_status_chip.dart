import 'package:flutter/material.dart';
import '../models/payment_status.dart';

class InstallmentStatusChip extends StatelessWidget {
  final PaymentStatus status;

  const InstallmentStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text, String label) = switch (status) {
      PaymentStatus.pending => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          'Pending',
        ),
      PaymentStatus.paid => (
          const Color(0xFFD1FAE5),
          const Color(0xFF059669),
          'Paid',
        ),
      PaymentStatus.paidEarly => (
          const Color(0xFFEEF2FF),
          const Color(0xFF4F46E5),
          'Paid Early',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
