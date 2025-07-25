import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickStatsWidget extends StatelessWidget {
  final int recentAnalysesCount;
  final int pendingResults;
  final double healthScore;

  const QuickStatsWidget({
    Key? key,
    required this.recentAnalysesCount,
    required this.pendingResults,
    required this.healthScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Recent Analyses',
              recentAnalysesCount.toString(),
              'analytics',
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildStatCard(
              'Pending Results',
              pendingResults.toString(),
              'pending',
              AppTheme.warningLight,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildStatCard(
              'Health Score',
              '${healthScore.toInt()}%',
              'favorite',
              _getHealthScoreColor(healthScore),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontSize: 10.sp,
                    color: AppTheme.textMediumEmphasisLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 4.w,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 80) return AppTheme.successLight;
    if (score >= 60) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }
}
