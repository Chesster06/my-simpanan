import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/widgets/app_logo_badge.dart';

void main() {
  testWidgets('AppLogoBadge renders with default medium size and ClipRRect', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogoBadge(),
        ),
      ),
    );

    expect(find.byType(AppLogoBadge), findsOneWidget);
    final clipRRectFinder = find.byType(ClipRRect);
    expect(clipRRectFinder, findsOneWidget);

    final clipRRect = tester.widget<ClipRRect>(clipRRectFinder);
    expect(clipRRect.borderRadius, BorderRadius.circular(16));

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, 44);
    expect(sizedBox.height, 44);
  });

  testWidgets('AppLogoBadge renders correctly for small and large sizes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppLogoBadge(size: AppLogoBadgeSize.small),
              AppLogoBadge(size: AppLogoBadgeSize.large),
            ],
          ),
        ),
      ),
    );

    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    expect(sizedBoxes[0].width, 32);
    expect(sizedBoxes[0].height, 32);

    expect(sizedBoxes[1].width, 64);
    expect(sizedBoxes[1].height, 64);
  });
}
