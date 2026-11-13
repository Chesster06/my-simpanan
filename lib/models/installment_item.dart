import 'payment_status.dart';

class InstallmentItem {
  final String id;
  final String monthLabel;
  final double amount;
  final DateTime dueDate;
  final PaymentStatus status;
  final DateTime? paidDate;

  const InstallmentItem({
    required this.id,
    required this.monthLabel,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidDate,
  });

  InstallmentItem copyWith({
    String? id,
    String? monthLabel,
    double? amount,
    DateTime? dueDate,
    PaymentStatus? status,
    DateTime? paidDate,
  }) {
    return InstallmentItem(
      id: id ?? this.id,
      monthLabel: monthLabel ?? this.monthLabel,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthLabel': monthLabel,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'paidDate': paidDate?.toIso8601String(),
    };
  }

  factory InstallmentItem.fromJson(Map<String, dynamic> json) {
    return InstallmentItem(
      id: json['id'] as String,
      monthLabel: json['monthLabel'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: PaymentStatusExtension.fromString(json['status'] as String),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
    );
  }
}
