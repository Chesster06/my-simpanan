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
    return Container(
      width: size.dimension,
      height: size.dimension,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: size.dimension,
          height: size.dimension,
          child: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.cover,
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
