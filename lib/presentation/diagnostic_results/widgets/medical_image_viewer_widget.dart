import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicalImageViewerWidget extends StatefulWidget {
  final String imageUrl;
  final bool hasHeatmap;

  const MedicalImageViewerWidget({
    Key? key,
    required this.imageUrl,
    this.hasHeatmap = true,
  }) : super(key: key);

  @override
  State<MedicalImageViewerWidget> createState() =>
      _MedicalImageViewerWidgetState();
}

class _MedicalImageViewerWidgetState extends State<MedicalImageViewerWidget> {
  bool _showHeatmap = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: CustomImageWidget(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              height: 30.h,
              fit: BoxFit.cover,
            ),
          ),
          if (_showHeatmap && widget.hasHeatmap)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              child: Container(
                width: double.infinity,
                height: 30.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withValues(alpha: 0.3),
                      Colors.yellow.withValues(alpha: 0.2),
                      Colors.green.withValues(alpha: 0.1),
                    ],
                    stops: const [0.2, 0.5, 0.8],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 2.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'visibility',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    _showHeatmap ? 'AI View' : 'Normal',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.hasHeatmap)
            Positioned(
              bottom: 2.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showHeatmap = !_showHeatmap;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: CustomIconWidget(
                    iconName:
                        _showHeatmap ? 'visibility_off' : 'remove_red_eye',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
