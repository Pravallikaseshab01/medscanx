import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DragDropZone extends StatefulWidget {
  final Function(List<String>) onFilesDropped;
  final bool isActive;

  const DragDropZone({
    super.key,
    required this.onFilesDropped,
    this.isActive = false,
  });

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _dashAnimation;
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _dashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(DragDropZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dashAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 25.h,
          decoration: BoxDecoration(
            color: _isDragOver
                ? AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05)
                : AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(
              color: _isDragOver
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.5),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'cloud_upload',
                color: _isDragOver
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 8.w,
              ),
              SizedBox(height: 2.h),
              Text(
                _isDragOver ? 'Drop files here' : 'Drag & drop files here',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: _isDragOver
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'or tap to browse files',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Supports: JPG, PNG, PDF, DOCX (Max 10MB)',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
