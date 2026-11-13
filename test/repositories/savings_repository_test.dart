import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsSavingsRepository', () {
    late SharedPrefsSavingsRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = SharedPrefsSavingsRepository();
    });

    test('loadGoals returns empty list when no stored data exists', () async {
      final goals = await repository.loadGoals();
      expect(goals, isEmpty);
    });

    test('saveGoals persists goals and loadGoals retrieves them intact', () async {
      final goal = SavingsGoal(
        id: 'goal-1',
        name: 'New Laptop',
        targetAmount: 5000.0,
        currentSavings: 1000.0,
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 6, 1),
        dueDay: 25,
        installments: [
          InstallmentItem(
            id: 'inst-1',
            monthLabel: 'Jan 2026',
            amount: 800.0,
            dueDate: DateTime(2026, 1, 25),
            status: PaymentStatus.paid,
            paidDate: DateTime(2026, 1, 20),
          ),
          InstallmentItem(
            id: 'inst-2',
            monthLabel: 'Feb 2026',
            amount: 800.0,
            dueDate: DateTime(2026, 2, 25),
            status: PaymentStatus.pending,
          ),
        ],
      );

      await repository.saveGoals([goal]);

      final loadedGoals = await repository.loadGoals();
      expect(loadedGoals.length, 1);
      final loaded = loadedGoals.first;
      expect(loaded.id, 'goal-1');
      expect(loaded.name, 'New Laptop');
      expect(loaded.targetAmount, 5000.0);
      expect(loaded.currentSavings, 1000.0);
      expect(loaded.installments.length, 2);
      expect(loaded.installments[0].status, PaymentStatus.paid);
      expect(loaded.installments[1].status, PaymentStatus.pending);
    });

    test('loadGoals handles corrupt JSON gracefully by returning empty list', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsSavingsRepository.storageKey: '{invalid-json',
      });

      final goals = await repository.loadGoals();
      expect(goals, isEmpty);
    });
  });
}
