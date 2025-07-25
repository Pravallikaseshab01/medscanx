import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DateRangeSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final List<DateTime> availableDates;

  const DateRangeSelector({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.availableDates,
  }) : super(key: key);

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  late ScrollController _scrollController;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();
    _currentPage = _getCurrentPageIndex();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  int _getCurrentPageIndex() {
    final now = DateTime.now();
    final currentYear = now.year;
    final selectedYear = widget.selectedDate.year;
    return (selectedYear - currentYear + 2).clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildYearSelector(),
          _buildMonthSelector(),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Text(
            'Timeline',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _previousYear,
                  child: CustomIconWidget(
                    iconName: 'chevron_left',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  widget.selectedDate.year.toString(),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: _nextYear,
                  child: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final monthDate = DateTime(widget.selectedDate.year, month);
          final isSelected = widget.selectedDate.month == month;
          final hasReports = _hasReportsInMonth(monthDate);

          return GestureDetector(
            onTap: () => _selectMonth(month),
            child: Container(
              width: 20.w,
              margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : hasReports
                        ? AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : hasReports
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getMonthName(month),
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : hasReports
                              ? AppTheme.lightTheme.colorScheme.secondary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (hasReports) ...[
                    SizedBox(height: 0.5.h),
                    Container(
                      width: 1.5.w,
                      height: 1.5.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _hasReportsInMonth(DateTime monthDate) {
    return widget.availableDates.any(
        (date) => date.year == monthDate.year && date.month == monthDate.month);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _selectMonth(int month) {
    final newDate =
        DateTime(widget.selectedDate.year, month, widget.selectedDate.day);
    widget.onDateChanged(newDate);
  }

  void _previousYear() {
    final newDate = DateTime(widget.selectedDate.year - 1,
        widget.selectedDate.month, widget.selectedDate.day);
    widget.onDateChanged(newDate);
  }

  void _nextYear() {
    final newDate = DateTime(widget.selectedDate.year + 1,
        widget.selectedDate.month, widget.selectedDate.day);
    widget.onDateChanged(newDate);
  }
}
