import 'installment_item.dart';
import 'payment_status.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentSavings;
  final DateTime startDate;
  final DateTime targetDate;
  final int dueDay;
  final List<InstallmentItem> installments;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentSavings,
    required this.startDate,
    required this.targetDate,
    this.dueDay = 25,
    this.installments = const [],
  });

  double get remainingAmount {
    final remaining = targetAmount - currentSavings;
    return remaining > 0 ? remaining : 0.0;
  }

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final ratio = currentSavings / targetAmount;
    if (ratio < 0.0) return 0.0;
    if (ratio > 1.0) return 1.0;
    return ratio;
  }

  bool get isCompleted => currentSavings >= targetAmount;

  InstallmentItem? get nextPendingInstallment {
    for (final item in installments) {
      if (item.status == PaymentStatus.pending) {
        return item;
      }
    }
    return null;
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentSavings,
    DateTime? startDate,
    DateTime? targetDate,
    int? dueDay,
    List<InstallmentItem>? installments,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSavings: currentSavings ?? this.currentSavings,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      dueDay: dueDay ?? this.dueDay,
      installments: installments ?? this.installments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentSavings': currentSavings,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'dueDay': dueDay,
      'installments': installments.map((e) => e.toJson()).toList(),
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentSavings: (json['currentSavings'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      dueDay: (json['dueDay'] as num?)?.toInt() ?? 25,
      installments: (json['installments'] as List<dynamic>?)
              ?.map((e) => InstallmentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
