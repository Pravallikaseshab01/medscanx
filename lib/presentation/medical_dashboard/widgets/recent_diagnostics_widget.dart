import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentDiagnosticsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> diagnostics;
  final Function(Map<String, dynamic>) onDiagnosticTap;

  const RecentDiagnosticsWidget({
    Key? key,
    required this.diagnostics,
    required this.onDiagnosticTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Diagnostics',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medical-history');
                },
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          diagnostics.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: diagnostics.length > 3 ? 3 : diagnostics.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final diagnostic = diagnostics[index];
                    return _buildDiagnosticCard(diagnostic);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(Map<String, dynamic> diagnostic) {
    final severity = diagnostic['severity'] as String;
    final severityColor = _getSeverityColor(severity);

    return GestureDetector(
      onTap: () => onDiagnosticTap(diagnostic),
      onLongPress: () => _showQuickActions(diagnostic),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: severityColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: diagnostic['thumbnail'] != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                      child: CustomImageWidget(
                        imageUrl: diagnostic['thumbnail'] as String,
                        width: 15.w,
                        height: 15.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'description',
                      color: severityColor,
                      size: 6.w,
                    ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnostic['title'] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    diagnostic['date'] as String,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textMediumEmphasisLight,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      severity.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: severityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.textMediumEmphasisLight,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'description',
            color: AppTheme.textMediumEmphasisLight,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Recent Diagnostics',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Upload your first medical report to get started',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textMediumEmphasisLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'normal':
        return AppTheme.successLight;
      case 'mild':
        return AppTheme.warningLight;
      case 'moderate':
        return AppTheme.accentLight;
      case 'severe':
        return AppTheme.errorLight;
      default:
        return AppTheme.textMediumEmphasisLight;
    }
  }

  void _showQuickActions(Map<String, dynamic> diagnostic) {
    // Quick actions implementation would go here
    // For now, this is a placeholder for the long-press functionality
  }
}
