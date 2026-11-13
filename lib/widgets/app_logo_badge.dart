import 'package:flutter/material.dart';
import 'package:mysimpanan/theme/app_colors.dart';

enum AppLogoBadgeSize {
  small(32.0),
  medium(44.0),
  large(64.0);

  final double dimension;
  const AppLogoBadgeSize(this.dimension);
}

class AppLogoBadge extends StatelessWidget {
  final AppLogoBadgeSize size;

  const AppLogoBadge({
    super.key,
    this.size = AppLogoBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    // Elegant squircle/rounded rectangle radius proportioned to dimension (iOS app icon radius ~22%)
    final borderRadius = BorderRadius.circular(size.dimension * 0.22);

    return Container(
      width: size.dimension,
      height: size.dimension,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: size.dimension,
          height: size.dimension,
          child: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primary,
                child: const Icon(
                  Icons.savings_outlined,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
