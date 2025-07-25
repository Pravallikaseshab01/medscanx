import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ProcessingStepsWidget extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const ProcessingStepsWidget({
    Key? key,
    required this.currentStep,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processing Steps',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ...List.generate(steps.length, (index) {
            return _buildStepItem(
              stepNumber: index + 1,
              stepTitle: steps[index],
              isCompleted: index < currentStep,
              isActive: index == currentStep,
              isLast: index == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String stepTitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator column
        Column(
          children: [
            // Step circle
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppTheme.successLight
                    : isActive
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
              ),
              child: isCompleted
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 4.w,
                    )
                  : isActive
                      ? Container(
                          width: 3.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          stepNumber.toString(),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
            ),
            // Connecting line
            if (!isLast)
              Container(
                width: 2,
                height: 6.h,
                color: isCompleted
                    ? AppTheme.successLight
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
              ),
          ],
        ),
        SizedBox(width: 3.w),
        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1.h, bottom: isLast ? 0 : 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepTitle,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted || isActive
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isActive)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'In progress...',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
