import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SecurityBackgroundWidget extends StatefulWidget {
  final Widget child;

  const SecurityBackgroundWidget({
    super.key,
    required this.child,
  });

  @override
  State<SecurityBackgroundWidget> createState() =>
      _SecurityBackgroundWidgetState();
}

class _SecurityBackgroundWidgetState extends State<SecurityBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _patternController;
  late AnimationController _gradientController;
  late Animation<double> _patternAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    _patternController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _patternAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _patternController,
      curve: Curves.linear,
    ));

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _patternController.repeat();
    _gradientController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _patternController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Base gradient background
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.lightTheme.scaffoldBackgroundColor,
                      AppTheme.lightTheme.primaryColor.withValues(
                          alpha: 0.05 + (_gradientAnimation.value * 0.03)),
                      AppTheme.lightTheme.scaffoldBackgroundColor,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Security pattern overlay
          AnimatedBuilder(
            animation: _patternAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: SecurityPatternPainter(
                  animationValue: _patternAnimation.value,
                  primaryColor: AppTheme.lightTheme.primaryColor,
                ),
              );
            },
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class SecurityPatternPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  SecurityPatternPainter({
    required this.animationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Draw animated security grid pattern
    final gridSpacing = size.width * 0.15;
    final offsetX = (animationValue * gridSpacing) % gridSpacing;
    final offsetY = (animationValue * gridSpacing * 0.7) % gridSpacing;

    // Vertical lines
    for (double x = -gridSpacing + offsetX;
        x < size.width + gridSpacing;
        x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = -gridSpacing + offsetY;
        y < size.height + gridSpacing;
        y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw security dots at intersections
    for (double x = -gridSpacing + offsetX;
        x < size.width + gridSpacing;
        x += gridSpacing) {
      for (double y = -gridSpacing + offsetY;
          y < size.height + gridSpacing;
          y += gridSpacing) {
        final distance =
            ((x - size.width / 2).abs() + (y - size.height / 2).abs()) /
                (size.width + size.height);
        final radius =
            2.0 * (1.0 - distance) * (0.5 + 0.5 * (1.0 - animationValue));

        if (radius > 0.5) {
          canvas.drawCircle(
            Offset(x, y),
            radius,
            dotPaint,
          );
        }
      }
    }

    // Draw subtle shield patterns
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final shieldRadius = size.width * 0.3;

    final shieldPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.05)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Animated concentric circles for security visualization
    for (int i = 0; i < 3; i++) {
      final radius =
          shieldRadius * (0.3 + 0.3 * i) * (0.8 + 0.2 * animationValue);
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        shieldPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SecurityPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
