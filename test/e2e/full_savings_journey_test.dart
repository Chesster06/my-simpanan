import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysimpanan/main.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/dashboard_screen.dart';
import 'package:mysimpanan/screens/create_goal_screen.dart';
import 'package:mysimpanan/screens/goal_detail_screen.dart';
import 'package:mysimpanan/screens/settings_screen.dart';
import 'package:mysimpanan/widgets/summary_header_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Comprehensive full savings journey end-to-end integration test', (tester) async {
    // 1. Setup in-memory SharedPreferences backing for persistent simulation
    SharedPreferences.setMockInitialValues({});
    const repository = SharedPrefsSavingsRepository();
    var provider = SavingsProvider(repository: repository);
    await provider.initialize();

    // 2. Launch App with genuine root widget
    await tester.pumpWidget(MySimpananApp(savingsProvider: provider));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify initial empty state
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('No Savings Goals Yet'), findsOneWidget);
    expect(find.text('RM 0.00'), findsWidgets);

    // 3. Navigate to Create Goal Screen via Center Add Button
    await tester.tap(find.byKey(const Key('nav_center_add_button')));
    await tester.pumpAndSettle();
    expect(find.byType(CreateGoalScreen), findsOneWidget);

    // 4. Input Goal Details:
    // ASNB goal with target RM 1,000, initial savings RM 200, across 4 months.
    // Fixed start date and target date 3 months later = 4 total installment periods
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final targetDate = DateTime(now.year, now.month + 3, 25);

    await tester.pumpWidget(
      MaterialApp(
        home: CreateGoalScreen(
          provider: provider,
          initialStartDate: startDate,
          initialTargetDate: targetDate,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('goal_name_field')), 'ASNB');
    await tester.enterText(find.byKey(const Key('target_amount_field')), '1000');
    await tester.enterText(find.byKey(const Key('current_savings_field')), '200');
    await tester.pumpAndSettle();

    // Scroll to Save Goal button and tap it
    final saveButton = find.byKey(const Key('save_goal_button'));
    await tester.scrollUntilVisible(
      saveButton,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify goal is registered in provider
    expect(provider.goals.length, 1);
    final createdGoal = provider.goals.first;
    expect(createdGoal.name, 'ASNB');
    expect(createdGoal.targetAmount, 1000.0);
    expect(createdGoal.currentSavings, 200.0);
    expect(createdGoal.installments.length, 4);

    // 5. Return to Dashboard and verify Dashboard aggregates
    await tester.pumpWidget(MySimpananApp(savingsProvider: provider));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(SummaryHeaderCard), findsOneWidget);
    // Total savings should be RM 200.00
    expect(find.text('RM 200.00'), findsWidgets);
    // Due this month should be RM 200.00 (since 800 / 4 months = 200 each)
    expect(provider.totalSavings, 200.0);
    expect(provider.monthlyCommitmentForCurrentMonth, 200.0);

    // 6. Navigate to Goal Detail screen
    await tester.tap(find.text('ASNB'));
    await tester.pumpAndSettle();
    expect(find.byType(GoalDetailScreen), findsOneWidget);

    // Verify Goal Detail screen displays the 4 monthly installments
    expect(find.text('Installment Schedule'), findsOneWidget);
    expect(find.text('4 pending'), findsOneWidget);
    expect(find.text('RM 200.00 / RM 1,000.00'), findsOneWidget);

    // 7. Execute "Pay Early" on installment #2 (index 1) via Checkbox and bottom PAY EARLY button
    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(4));

    // Tap Checkbox on the second installment (at index 1)
    await tester.tap(checkboxes.at(1));
    await tester.pumpAndSettle();

    // Verify bottom button updates and tap it
    final payEarlyBottomBtn = find.byKey(const Key('pay_early_bottom_button'));
    expect(payEarlyBottomBtn, findsOneWidget);
    await tester.tap(payEarlyBottomBtn);
    await tester.pumpAndSettle();

    // Verify Pay Early confirmation dialog
    expect(find.text('Pay Early Confirmation'), findsOneWidget);
    final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm');
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // 8. Verify current savings increments to RM 400.00 and status updates to "Paid Early"
    expect(provider.totalSavings, 400.0);
    final updatedGoal = provider.goals.first;
    expect(updatedGoal.currentSavings, 400.0);
    expect(updatedGoal.installments[1].status, PaymentStatus.paidEarly);
    expect(find.textContaining('Paid'), findsWidgets);
    expect(find.text('RM 400.00 / RM 1,000.00'), findsOneWidget);

    // Pop back from Goal Detail screen to Dashboard
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    // 9. Simulate app restart with repository persistence:
    // Create new provider instance and initialize from the same persistent repository
    final restartedProvider = SavingsProvider(repository: repository);
    await restartedProvider.initialize();

    expect(restartedProvider.goals.length, 1);
    final reloadedGoal = restartedProvider.goals.first;
    expect(reloadedGoal.name, 'ASNB');
    expect(reloadedGoal.targetAmount, 1000.0);
    expect(reloadedGoal.currentSavings, 400.0);
    expect(reloadedGoal.installments.length, 4);
    expect(reloadedGoal.installments[1].status, PaymentStatus.paidEarly);

    // Render restarted app on Dashboard
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(provider: restartedProvider),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('RM 400.00'), findsWidgets);

    // 10. Navigate to Settings
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    // Pop back to dashboard
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('RM 400.00'), findsWidgets);
  });
}
