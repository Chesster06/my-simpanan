import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/widgets/summary_header_card.dart';

void main() {
  testWidgets('SummaryHeaderCard renders total savings, commitment, and pending badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryHeaderCard(
            totalSavings: 12500.50,
            dueThisMonth: 450.00,
            pendingCount: 3,
          ),
        ),
      ),
    );

    expect(find.text('Total Savings'), findsOneWidget);
    expect(find.text('RM 12,500.50'), findsOneWidget);
    expect(find.text('Due This Month'), findsOneWidget);
    expect(find.text('RM 450.00'), findsOneWidget);
    expect(find.text('3 pending'), findsOneWidget);
  });

  testWidgets('SummaryHeaderCard renders zero amounts and zero pending badge correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryHeaderCard(
            totalSavings: 0.0,
            dueThisMonth: 0.0,
            pendingCount: 0,
          ),
        ),
      ),
    );

    expect(find.text('Total Savings'), findsOneWidget);
    expect(find.text('Due This Month'), findsOneWidget);
    expect(find.text('RM 0.00'), findsNWidgets(2));
    expect(find.text('0 pending'), findsOneWidget);
  });
}
