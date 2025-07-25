import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final bool isProcessing;

  const ActionButtonsWidget({
    Key? key,
    required this.onCancel,
    required this.isProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isProcessing ? onCancel : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorLight,
                side: BorderSide(
                  color: isProcessing
                      ? AppTheme.errorLight
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(vertical: 4.h),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'cancel',
                    color: isProcessing
                        ? AppTheme.errorLight
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Cancel Analysis',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isProcessing
                          ? AppTheme.errorLight
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
