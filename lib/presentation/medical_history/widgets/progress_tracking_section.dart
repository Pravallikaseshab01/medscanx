import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressTrackingSection extends StatefulWidget {
  final List<Map<String, dynamic>> healthMetrics;

  const ProgressTrackingSection({
    Key? key,
    required this.healthMetrics,
  }) : super(key: key);

  @override
  State<ProgressTrackingSection> createState() =>
      _ProgressTrackingSectionState();
}

class _ProgressTrackingSectionState extends State<ProgressTrackingSection> {
  String _selectedMetric = 'Overall Health';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildMetricSelector(),
          _buildChart(),
          _buildTrendIndicators(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'trending_up',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Text(
            'Progress Tracking',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Text(
              'Last 6 months',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    final metrics = [
      'Overall Health',
      'Blood Pressure',
      'Cholesterol',
      'Blood Sugar'
    ];

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          final isSelected = _selectedMetric == metric;

          return GestureDetector(
            onTap: () => setState(() => _selectedMetric = metric),
            child: Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Center(
                child: Text(
                  metric,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 25.h,
      padding: EdgeInsets.all(4.w),
      child: Semantics(
        label: "Health Progress Line Chart for $_selectedMetric",
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          months[value.toInt()],
                          style: AppTheme.lightTheme.textTheme.labelSmall,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  reservedSize: 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: AppTheme.lightTheme.textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            minX: 0,
            maxX: 5,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: _getChartData(),
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
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicators() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildTrendCard(
              'Improvement',
              '+12%',
              AppTheme.lightTheme.colorScheme.secondary,
              'trending_up',
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildTrendCard(
              'Risk Factors',
              '-8%',
              AppTheme.lightTheme.colorScheme.secondary,
              'trending_down',
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildTrendCard(
              'Stability',
              '94%',
              AppTheme.lightTheme.colorScheme.primary,
              'show_chart',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
      String title, String value, Color color, String iconName) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartData() {
    // Mock data based on selected metric
    switch (_selectedMetric) {
      case 'Blood Pressure':
        return [
          const FlSpot(0, 75),
          const FlSpot(1, 72),
          const FlSpot(2, 68),
          const FlSpot(3, 70),
          const FlSpot(4, 65),
          const FlSpot(5, 62),
        ];
      case 'Cholesterol':
        return [
          const FlSpot(0, 85),
          const FlSpot(1, 82),
          const FlSpot(2, 78),
          const FlSpot(3, 75),
          const FlSpot(4, 73),
          const FlSpot(5, 70),
        ];
      case 'Blood Sugar':
        return [
          const FlSpot(0, 90),
          const FlSpot(1, 88),
          const FlSpot(2, 85),
          const FlSpot(3, 87),
          const FlSpot(4, 83),
          const FlSpot(5, 80),
        ];
      default: // Overall Health
        return [
          const FlSpot(0, 65),
          const FlSpot(1, 70),
          const FlSpot(2, 75),
          const FlSpot(3, 78),
          const FlSpot(4, 82),
          const FlSpot(5, 85),
        ];
    }
  }
}
