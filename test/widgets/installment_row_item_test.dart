import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/models/installment_item.dart';
import 'package:mysimpanan/models/payment_status.dart';
import 'package:mysimpanan/widgets/installment_row_item.dart';
import 'package:mysimpanan/widgets/installment_status_chip.dart';

void main() {
  group('InstallmentRowItem', () {
    testWidgets('renders pending installment with checkbox on left and triggers toggle', (tester) async {
      bool? selectedState;

      final item = InstallmentItem(
        id: 'inst-1',
        monthLabel: 'January 2027',
        amount: 350.00,
        dueDate: DateTime(2027, 1, 25),
        status: PaymentStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallmentRowItem(
              installment: item,
              isSelected: false,
              onSelectChanged: (val) {
                selectedState = val;
              },
            ),
          ),
        ),
      );

      expect(find.text('January 2027'), findsOneWidget);
      expect(find.text('Due 25 Jan 2027'), findsOneWidget);
      expect(find.text('RM 350.00'), findsOneWidget);
      expect(find.byType(InstallmentStatusChip), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pump();

      expect(selectedState, isTrue);
    });

    testWidgets('renders paid installment with check icon and paid date', (tester) async {
      final item = InstallmentItem(
        id: 'inst-2',
        monthLabel: 'February 2027',
        amount: 250.50,
        dueDate: DateTime(2027, 2, 25),
        status: PaymentStatus.paid,
        paidDate: DateTime(2027, 2, 20),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallmentRowItem(
              installment: item,
            ),
          ),
        ),
      );

      expect(find.text('February 2027'), findsOneWidget);
      expect(find.text('Due 25 Feb 2027'), findsOneWidget);
      expect(find.text('RM 250.50'), findsOneWidget);
      expect(find.text('Paid 20 Feb 2027'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('renders paidEarly installment with check icon and paid early date', (tester) async {
      final item = InstallmentItem(
        id: 'inst-3',
        monthLabel: 'March 2027',
        amount: 500.00,
        dueDate: DateTime(2027, 3, 25),
        status: PaymentStatus.paidEarly,
        paidDate: DateTime(2027, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallmentRowItem(
              installment: item,
            ),
          ),
        ),
      );

      expect(find.text('March 2027'), findsOneWidget);
      expect(find.text('Due 25 Mar 2027'), findsOneWidget);
      expect(find.text('RM 500.00'), findsOneWidget);
      expect(find.text('Paid 15 Jan 2027'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
    });
  });
}
