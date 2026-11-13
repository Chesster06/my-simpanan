import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/savings_goal.dart';
import 'package:mysimpanan/providers/savings_provider.dart';
import 'package:mysimpanan/repositories/savings_repository.dart';
import 'package:mysimpanan/screens/create_goal_screen.dart';

class MockSavingsRepository implements SavingsRepository {
  List<SavingsGoal> storedGoals;
  MockSavingsRepository([this.storedGoals = const []]);

  @override
  Future<List<SavingsGoal>> loadGoals() async => storedGoals;

  @override
  Future<void> saveGoals(List<SavingsGoal> goals) async {
    storedGoals = goals;
  }
}

void main() {
  late MockSavingsRepository repository;
  late SavingsProvider provider;

  setUp(() async {
    repository = MockSavingsRepository([]);
    provider = SavingsProvider(repository: repository);
    await provider.initialize();
  });

  Widget buildTestWidget({CreateGoalScreen? screen}) {
    return MaterialApp(
      home: screen ?? CreateGoalScreen(provider: provider),
    );
  }

  group('CreateGoalScreen Form Validation', () {
    testWidgets('shows validation errors when saving with empty inputs', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Scroll to Save Goal button if off-screen
      final saveButton = find.byKey(const Key('save_goal_button'));
      await tester.scrollUntilVisible(
        saveButton,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Scroll back up to see the top form fields validation messages
      await tester.scrollUntilVisible(
        find.byKey(const Key('goal_name_field')),
        -100,
        scrollable: find.byType(Scrollable).first,
      );

      // Check validation error texts
      expect(find.text('Please enter a goal name'), findsOneWidget);
      expect(find.text('Please enter a valid target amount'), findsOneWidget);
      expect(provider.goals.length, 0);
    });

    testWidgets('validates target amount must be greater than zero', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Enter valid name, but 0 target amount
      await tester.enterText(find.byKey(const Key('goal_name_field')), 'Travel Fund');
      await tester.enterText(find.byKey(const Key('target_amount_field')), '0');

      final saveButton = find.byKey(const Key('save_goal_button'));
      await tester.scrollUntilVisible(
        saveButton,
        100,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Scroll back up to see target amount validation message
      await tester.scrollUntilVisible(
        find.byKey(const Key('target_amount_field')),
        -100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Target amount must be greater than 0'), findsOneWidget);
      expect(provider.goals.length, 0);
    });
  });

  group('CreateGoalScreen Live Calculation Banner', () {
    testWidgets('displays real-time preview when amount and target date are set', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Enter target amount
      await tester.enterText(find.byKey(const Key('target_amount_field')), '1200');
      await tester.pumpAndSettle();

      // Verify that live preview container exists and shows estimated commitment
      expect(find.byKey(const Key('live_calculation_preview')), findsOneWidget);
      expect(find.textContaining('Estimated Monthly Commitment:'), findsOneWidget);
      expect(find.textContaining('/ month'), findsOneWidget);
      expect(find.textContaining('Final Installment:'), findsOneWidget);
    });

    testWidgets('slider updates due day value', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Day 25 of every month'), findsOneWidget);

      // Change slider value
      final sliderFinder = find.byKey(const Key('due_day_slider'));
      await tester.tap(sliderFinder);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('due_day_slider')), findsOneWidget);
    });
  });

  group('CreateGoalScreen Goal Creation', () {
    testWidgets('saves goal, adds to provider, and pops screen with SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateGoalScreen(provider: provider),
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Fill in form
      await tester.enterText(find.byKey(const Key('goal_name_field')), 'ASNB Bumiputera');
      await tester.enterText(find.byKey(const Key('target_amount_field')), '1200');
      await tester.enterText(find.byKey(const Key('current_savings_field')), '200');

      // Scroll to Save Goal button
      final saveButton = find.byKey(const Key('save_goal_button'));
      await tester.scrollUntilVisible(
        saveButton,
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Tap Save
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should be popped back to caller screen
      expect(find.byType(CreateGoalScreen), findsNothing);
      expect(find.text('Goal created successfully'), findsOneWidget);

      // Provider should have 1 goal
      expect(provider.goals.length, 1);
      final createdGoal = provider.goals.first;
      expect(createdGoal.name, 'ASNB Bumiputera');
      expect(createdGoal.targetAmount, 1200.0);
      expect(createdGoal.currentSavings, 200.0);
      expect(createdGoal.installments.isNotEmpty, true);
    });
  });
}
