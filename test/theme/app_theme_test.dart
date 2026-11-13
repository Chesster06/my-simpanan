import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/theme/app_colors.dart';
import 'package:mysimpanan/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('defines required palette tokens correctly', () {
      expect(AppColors.primary, const Color(0xFF6366F1));
      expect(AppColors.primaryHover, const Color(0xFF4F46E5));
      expect(AppColors.secondary, const Color(0xFF20970B));
      expect(AppColors.neutral, const Color(0xFF9C9C9C));
      expect(AppColors.background, const Color(0xFFFAFAFA));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.textPrimary, const Color(0xFF0A0A0A));
      expect(AppColors.textSecondary, const Color(0xFF6B6B6B));
      expect(AppColors.border, const Color(0xFFE8E8EC));
      expect(AppColors.success, const Color(0xFF10B981));
      expect(AppColors.warning, const Color(0xFFF59E0B));
      expect(AppColors.error, const Color(0xFFEF4444));
    });
  });

  group('AppTheme', () {
    test('lightTheme configures colors and component themes as expected', () {
      final theme = AppTheme.lightTheme;

      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.error, AppColors.error);

      // Card theme verification
      expect(theme.cardTheme.elevation, 0);
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
      expect(cardShape, isNotNull);
      expect(cardShape!.side.color, AppColors.border);
      expect(cardShape.side.width, 1.0);
      expect(cardShape.borderRadius, BorderRadius.circular(12));

      // Elevated button theme verification
      final buttonStyle = theme.elevatedButtonTheme.style;
      expect(buttonStyle, isNotNull);
      final bgColor = buttonStyle!.backgroundColor?.resolve({});
      expect(bgColor, AppColors.primary);
      final btnShape = buttonStyle.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(btnShape, isNotNull);
      expect(btnShape!.borderRadius, BorderRadius.circular(6));
    });
  });
}
