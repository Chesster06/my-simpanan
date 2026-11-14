import 'package:flutter/material.dart';
import '../services/locale_service.dart';
import '../theme/app_colors.dart';
import 'minimalist_svg_illustrations.dart';

/// Custom notched navigation bar matching the modern curved design with a prominent center "+" action.
class NotchedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddGoal;

  const NotchedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        minimum: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 74,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Custom painted curved background
              Positioned.fill(
                child: CustomPaint(
                  painter: _NotchedBarPainter(
                    backgroundColor: AppColors.surface,
                    borderColor: AppColors.border,
                  ),
                ),
              ),

              // Navigation tab items row: Dashboard on the left, Analytics on the right
              Positioned.fill(
                child: Row(
                  children: [
                    // Left Tab: Dashboard
                    Expanded(
                      child: _buildNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: LocaleService.instance.tr('dashboard'),
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),

                    // Center gap for "+" button
                    const SizedBox(width: 80),

                    // Right Tab: Analytics
                    Expanded(
                      child: _buildNavItem(
                        icon: Icons.bar_chart_rounded,
                        activeIcon: Icons.insert_chart_rounded,
                        label: LocaleService.instance.tr('analytics'),
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                    ),
                  ],
                ),
              ),

              // Center elevated Floating "+" Button with purple glow
              Positioned(
                top: -16,
                child: InteractiveBouncyScale(
                  onTap: onAddGoal,
                  scaleDown: 0.90,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.38),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 32,
                        key: Key('nav_center_add_button'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? AppColors.primary : const Color(0xFF8E95A5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 23,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;

  _NotchedBarPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    const cornerRadius = 24.0;
    const notchRadius = 38.0;
    const s1 = 16.0;

    path.moveTo(0, cornerRadius);
    // Top-left rounded corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Line to left side of notch
    path.lineTo(centerX - notchRadius - s1, 0);

    // Smooth cubic bezier into notch
    path.cubicTo(
      centerX - notchRadius,
      0,
      centerX - notchRadius + 6,
      28,
      centerX,
      28,
    );

    // Smooth cubic bezier out of notch
    path.cubicTo(
      centerX + notchRadius - 6,
      28,
      centerX + notchRadius,
      0,
      centerX + notchRadius + s1,
      0,
    );

    // Line to top-right corner
    path.lineTo(w - cornerRadius, 0);
    path.quadraticBezierTo(w, 0, w, cornerRadius);

    // Down to bottom-right
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
  }
}
