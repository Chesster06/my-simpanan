import 'package:flutter/foundation.dart';
import '../models/installment_item.dart';
import '../models/payment_status.dart';
import '../models/savings_goal.dart';
import '../repositories/savings_repository.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsRepository repository;

  List<SavingsGoal> _goals = [];
  bool _isLoading = false;

  SavingsProvider({required this.repository});

  SavingsRepository get _repository => repository;

  List<SavingsGoal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;

  double get totalSavings =>
      _goals.fold(0.0, (sum, goal) => sum + goal.currentSavings);

  double get totalTarget =>
      _goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);

  double get monthlyCommitmentForCurrentMonth {
    final now = DateTime.now();
    double sum = 0.0;
    for (final goal in _goals) {
      for (final inst in goal.installments) {
        if (inst.dueDate.year == now.year &&
            inst.dueDate.month == now.month &&
            inst.status == PaymentStatus.pending) {
          sum += inst.amount;
        }
      }
    }
    return sum;
  }

  int get pendingInstallmentsCount {
    int count = 0;
    for (final goal in _goals) {
      for (final inst in goal.installments) {
        if (inst.status == PaymentStatus.pending) {
          count++;
        }
      }
    }
    return count;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _goals = await _repository.loadGoals();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    _goals = [..._goals, goal];
    await _repository.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      final updatedList = List<SavingsGoal>.from(_goals);
      updatedList[index] = goal;
      _goals = updatedList;
      await _repository.saveGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _goals = _goals.where((g) => g.id != goalId).toList();
    await _repository.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> payInstallment({
    required String goalId,
    required String installmentId,
  }) async {
    await _updateInstallmentPayment(
      goalId: goalId,
      installmentId: installmentId,
      newStatus: PaymentStatus.paid,
    );
  }

  Future<void> payEarlyInstallment({
    required String goalId,
    required String installmentId,
  }) async {
    await _updateInstallmentPayment(
      goalId: goalId,
      installmentId: installmentId,
      newStatus: PaymentStatus.paidEarly,
    );
  }

  Future<void> _updateInstallmentPayment({
    required String goalId,
    required String installmentId,
    required PaymentStatus newStatus,
  }) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final goal = _goals[goalIndex];
    final instIndex = goal.installments.indexWhere((i) => i.id == installmentId);
    if (instIndex == -1) return;

    final targetItem = goal.installments[instIndex];
    final updatedItem = targetItem.copyWith(
      status: newStatus,
      paidDate: DateTime.now(),
    );

    final updatedInstallments = List<InstallmentItem>.from(goal.installments);
    updatedInstallments[instIndex] = updatedItem;

    final updatedGoal = goal.copyWith(
      currentSavings: goal.currentSavings + targetItem.amount,
      installments: updatedInstallments,
    );

    final updatedGoals = List<SavingsGoal>.from(_goals);
    updatedGoals[goalIndex] = updatedGoal;
    _goals = updatedGoals;

    await _repository.saveGoals(_goals);
    notifyListeners();
  }
}
