import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class HealthInsightsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> healthData;
  final List<String> recommendations;

  const HealthInsightsWidget({
    Key? key,
    required this.healthData,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Insights',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Progress',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  height: 25.h,
                  child: Semantics(
                    label: "Health Progress Line Chart",
                    child: LineChart(
                      _buildLineChartData(),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Recommendations',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                ...recommendations
                    .take(3)
                    .map((recommendation) =>
                        _buildRecommendationItem(recommendation))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            width: 1.5.w,
            height: 1.5.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              recommendation,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textMediumEmphasisLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text('Jan', style: style);
                  break;
                case 1:
                  text = const Text('Feb', style: style);
                  break;
                case 2:
                  text = const Text('Mar', style: style);
                  break;
                case 3:
                  text = const Text('Apr', style: style);
                  break;
                case 4:
                  text = const Text('May', style: style);
                  break;
                case 5:
                  text = const Text('Jun', style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: text,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      minX: 0,
      maxX: 5,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: healthData.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              (entry.value['value'] as num).toDouble(),
            );
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.secondary,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppTheme.lightTheme.colorScheme.primary,
                strokeWidth: 2,
                strokeColor: AppTheme.lightTheme.colorScheme.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
