import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/widgets/notched_bottom_nav_bar.dart';

void main() {
  testWidgets('NotchedBottomNavBar renders navigation items and triggers actions', (tester) async {
    int? tappedIndex;
    bool addGoalTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NotchedBottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
            onAddGoal: () {
              addGoalTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(NotchedBottomNavBar), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Goals'), findsNothing);
    expect(find.text('More'), findsNothing);

    final addButton = find.byKey(const Key('nav_center_add_button'));
    expect(addButton, findsOneWidget);

    // Tap Center Add Button
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(addGoalTapped, isTrue);

    // Tap Analytics
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(tappedIndex, 1);
  });
}
