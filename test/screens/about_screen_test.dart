import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/screens/about_screen.dart';
import 'package:mysimpanan/widgets/app_logo_badge.dart';

void main() {
  testWidgets('AboutScreen renders app details and feature items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutScreen(),
      ),
    );

    expect(find.text('About MySimpanan'), findsOneWidget);
    expect(find.text('MySimpanan'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.byType(AppLogoBadge), findsOneWidget);
    expect(find.text('Key Capabilities'), findsOneWidget);
    expect(find.text('Targeted Savings'), findsOneWidget);
    expect(find.text('Scheduled Monthly Commitments'), findsOneWidget);
    expect(find.text('Pay Early Support'), findsOneWidget);
    expect(find.text('Configurable Reminders'), findsOneWidget);
  });
}
