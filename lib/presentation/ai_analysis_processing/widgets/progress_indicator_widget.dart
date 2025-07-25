import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final double progress;
  final bool isProcessing;

  const ProgressIndicatorWidget({
    Key? key,
    required this.progress,
    required this.isProcessing,
  }) : super(key: key);

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isProcessing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing && !oldWidget.isProcessing) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isProcessing && oldWidget.isProcessing) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isProcessing ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 40.w,
              height: 40.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 35.w,
                    height: 35.w,
                    child: CircularProgressIndicator(
                      value: widget.progress / 100,
                      strokeWidth: 1.5.w,
                      backgroundColor: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                  // Medical cross icon
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.surface,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: CustomIconWidget(
                      iconName: 'local_hospital',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 8.w,
                    ),
                  ),
                  // Progress percentage
                  Positioned(
                    bottom: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusSmall),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Text(
                        '${widget.progress.toInt()}%',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
