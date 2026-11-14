import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/main.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/dashboard_screen.dart';

class FakeSavingsRepository implements SavingsRepository {
  List<SavingsGoal> goals = [];
  @override
  Future<List<SavingsGoal>> loadGoals() async => goals;
  @override
  Future<void> saveGoals(List<SavingsGoal> newGoals) async {
    goals = newGoals;
  }
}

void main() {
  testWidgets('MySimpananApp initializes and renders DashboardScreen with AppTheme', (tester) async {
    final repository = FakeSavingsRepository();
    final provider = SavingsProvider(repository: repository);
    await provider.initialize();

    await tester.pumpWidget(
      MySimpananApp(savingsProvider: provider),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('MySimpanan'), findsOneWidget);
  });
}
