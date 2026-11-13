import 'dart:io' as io;
import 'package:flutter/material.dart';

/// Minimalist SVG-style vector painter for modern empty states.
/// Draws an elegant, clean piggy bank & coin outline with animated floating coin.
class MinimalistSavingsIllustration extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;
  final bool animate;

  const MinimalistSavingsIllustration({
    super.key,
    this.size = 110,
    this.primaryColor = const Color(0xFF6366F1),
    this.accentColor = const Color(0xFF10B981),
    this.animate = true,
  });

  @override
  State<MinimalistSavingsIllustration> createState() => _MinimalistSavingsIllustrationState();
}

class _MinimalistSavingsIllustrationState extends State<MinimalistSavingsIllustration>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _coinAnimation;

  static bool get _isRunningInFlutterTest {
    try {
      return io.Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.animate && !_isRunningInFlutterTest) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2200),
      )..repeat(reverse: true);

      _coinAnimation = Tween<double>(begin: -4.0, end: 6.0).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeInOutCubic),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || _coinAnimation == null) {
      return CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _SavingsVectorPainter(
          primaryColor: widget.primaryColor,
          accentColor: widget.accentColor,
          coinOffsetY: 0.0,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _coinAnimation!,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SavingsVectorPainter(
            primaryColor: widget.primaryColor,
            accentColor: widget.accentColor,
            coinOffsetY: _coinAnimation!.value,
          ),
        );
      },
    );
  }
}

class _SavingsVectorPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double coinOffsetY;

  _SavingsVectorPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.coinOffsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final subtleFillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final coinPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final coinFillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Center circular subtle background
    canvas.drawCircle(Offset(w * 0.5, h * 0.55), w * 0.38, subtleFillPaint);

    // Piggy Body Path
    final bodyPath = Path();
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.48, h * 0.60), width: w * 0.52, height: h * 0.42),
      Radius.circular(w * 0.20),
    );
    bodyPath.addRRect(bodyRect);
    canvas.drawPath(bodyPath, strokePaint);

    // Snout
    final snoutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.70, h * 0.52, w * 0.12, h * 0.16),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(snoutRect, strokePaint);

    // Eye dot
    final eyePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.62, h * 0.54), 2.2, eyePaint);

    // Ear triangle
    final earPath = Path()
      ..moveTo(w * 0.50, h * 0.41)
      ..lineTo(w * 0.55, h * 0.30)
      ..lineTo(w * 0.60, h * 0.42);
    canvas.drawPath(earPath, strokePaint);

    // Feet
    canvas.drawLine(Offset(w * 0.35, h * 0.81), Offset(w * 0.35, h * 0.88), strokePaint);
    canvas.drawLine(Offset(w * 0.60, h * 0.81), Offset(w * 0.60, h * 0.88), strokePaint);

    // Coin slot on top
    canvas.drawLine(Offset(w * 0.40, h * 0.39), Offset(w * 0.48, h * 0.39), strokePaint);

    // Animated Coin falling into slot
    final coinCenter = Offset(w * 0.44, h * 0.25 + coinOffsetY);
    final coinRadius = w * 0.10;
    canvas.drawCircle(coinCenter, coinRadius, coinFillPaint);
    canvas.drawCircle(coinCenter, coinRadius, coinPaint);

    // Currency symbol inside coin (minimalist line)
    canvas.drawLine(
      Offset(coinCenter.dx, coinCenter.dy - coinRadius * 0.5),
      Offset(coinCenter.dx, coinCenter.dy + coinRadius * 0.5),
      coinPaint,
    );
    canvas.drawLine(
      Offset(coinCenter.dx - coinRadius * 0.35, coinCenter.dy - coinRadius * 0.1),
      Offset(coinCenter.dx + coinRadius * 0.35, coinCenter.dy - coinRadius * 0.1),
      coinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SavingsVectorPainter oldDelegate) {
    return oldDelegate.coinOffsetY != coinOffsetY ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Interactive button wrapper with iOS-style tactile spring scale on tap.
class InteractiveBouncyScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const InteractiveBouncyScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
  });

  @override
  State<InteractiveBouncyScale> createState() => _InteractiveBouncyScaleState();
}

class _InteractiveBouncyScaleState extends State<InteractiveBouncyScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center,
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
