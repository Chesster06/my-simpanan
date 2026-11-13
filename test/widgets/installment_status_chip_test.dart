import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/widgets/installment_status_chip.dart';

void main() {
  group('InstallmentStatusChip', () {
    testWidgets('renders pending status with warning colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstallmentStatusChip(status: PaymentStatus.pending),
          ),
        ),
      );

      final textFinder = find.text('Pending');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, const Color(0xFFD97706));

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFEF3C7));
      expect(decoration.borderRadius, BorderRadius.circular(9999));
    });

    testWidgets('renders paid status with success colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstallmentStatusChip(status: PaymentStatus.paid),
          ),
        ),
      );

      final textFinder = find.text('Paid');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, const Color(0xFF059669));

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFD1FAE5));
      expect(decoration.borderRadius, BorderRadius.circular(9999));
    });

    testWidgets('renders paidEarly status with indigo colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstallmentStatusChip(status: PaymentStatus.paidEarly),
          ),
        ),
      );

      final textFinder = find.text('Paid Early');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, const Color(0xFF4F46E5));

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFEEF2FF));
      expect(decoration.borderRadius, BorderRadius.circular(9999));
    });
  });
}
