import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_range_selector.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/medical_report_card.dart';
import './widgets/progress_tracking_section.dart';

class MedicalHistory extends StatefulWidget {
  const MedicalHistory({Key? key}) : super(key: key);

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _currentFilters = {};
  bool _isSearchVisible = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock data for medical reports
  final List<Map<String, dynamic>> _allReports = [
    {
      "id": 1,
      "title": "Chest X-Ray Analysis",
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "diagnosis":
          "Normal chest X-ray with clear lung fields. No signs of pneumonia, pleural effusion, or other abnormalities detected.",
      "severity": "Normal",
      "confidence": 0.94,
      "thumbnail":
          "https://images.pexels.com/photos/7089020/pexels-photo-7089020.jpeg?auto=compress&cs=tinysrgb&w=400",
      "hasHeatmap": true,
      "documentType": "X-Ray",
      "analysisStatus": "Completed",
    },
    {
      "id": 2,
      "title": "Blood Test Results",
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "diagnosis":
          "Slightly elevated cholesterol levels (LDL: 145 mg/dL). Recommend dietary modifications and follow-up in 3 months.",
      "severity": "Mild",
      "confidence": 0.89,
      "thumbnail":
          "https://images.pexels.com/photos/6823568/pexels-photo-6823568.jpeg?auto=compress&cs=tinysrgb&w=400",
      "hasHeatmap": false,
      "documentType": "Blood Test",
      "analysisStatus": "Completed",
    },
    {
      "id": 3,
      "title": "MRI Brain Scan",
      "date": DateTime.now().subtract(const Duration(days: 12)),
      "diagnosis":
          "MRI shows mild age-related changes. Small vessel disease noted but within normal limits for patient age.",
      "severity": "Mild",
      "confidence": 0.92,
      "thumbnail":
          "https://images.pexels.com/photos/7089391/pexels-photo-7089391.jpeg?auto=compress&cs=tinysrgb&w=400",
      "hasHeatmap": true,
      "documentType": "MRI",
      "analysisStatus": "Completed",
    },
    {
      "id": 4,
      "title": "ECG Report",
      "date": DateTime.now().subtract(const Duration(days: 18)),
      "diagnosis":
          "Normal sinus rhythm with heart rate of 72 bpm. No arrhythmias or ST-segment changes detected.",
      "severity": "Normal",
      "confidence": 0.96,
      "thumbnail":
          "https://images.pexels.com/photos/7089020/pexels-photo-7089020.jpeg?auto=compress&cs=tinysrgb&w=400",
      "hasHeatmap": false,
      "documentType": "Lab Report",
      "analysisStatus": "Completed",
    },
    {
      "id": 5,
      "title": "CT Abdomen Scan",
      "date": DateTime.now().subtract(const Duration(days: 25)),
      "diagnosis":
          "Moderate hepatic steatosis (fatty liver) identified. Recommend lifestyle modifications and hepatology consultation.",
      "severity": "Moderate",
      "confidence": 0.87,
      "thumbnail":
          "https://images.pexels.com/photos/7089391/pexels-photo-7089391.jpeg?auto=compress&cs=tinysrgb&w=400",
      "hasHeatmap": true,
      "documentType": "CT Scan",
      "analysisStatus": "Completed",
    },
  ];

  // Mock health metrics data
  final List<Map<String, dynamic>> _healthMetrics = [
    {
      "metric": "Overall Health",
      "currentValue": 85,
      "trend": "improving",
      "change": 12,
    },
    {
      "metric": "Blood Pressure",
      "currentValue": 62,
      "trend": "stable",
      "change": -2,
    },
    {
      "metric": "Cholesterol",
      "currentValue": 70,
      "trend": "improving",
      "change": 15,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isSearchVisible) {
      setState(() => _isSearchVisible = true);
    } else if (_scrollController.offset <= 100 && _isSearchVisible) {
      setState(() => _isSearchVisible = false);
    }
  }

  List<Map<String, dynamic>> get _filteredReports {
    List<Map<String, dynamic>> filtered = List.from(_allReports);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((report) {
        return (report['title'] as String).toLowerCase().contains(searchTerm) ||
            (report['diagnosis'] as String).toLowerCase().contains(searchTerm);
      }).toList();
    }

    // Apply date range filter
    if (_currentFilters['dateRange'] != null) {
      final dateRange = _currentFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((report) {
        final reportDate = report['date'] as DateTime;
        return reportDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            reportDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply document type filter
    if (_currentFilters['documentType'] != null &&
        _currentFilters['documentType'] != 'All') {
      filtered = filtered
          .where((report) =>
              report['documentType'] == _currentFilters['documentType'])
          .toList();
    }

    // Apply severity filter
    if (_currentFilters['severity'] != null &&
        _currentFilters['severity'] != 'All') {
      filtered = filtered
          .where((report) => report['severity'] == _currentFilters['severity'])
          .toList();
    }

    // Apply analysis status filter
    if (_currentFilters['analysisStatus'] != null &&
        _currentFilters['analysisStatus'] != 'All') {
      filtered = filtered
          .where((report) =>
              report['analysisStatus'] == _currentFilters['analysisStatus'])
          .toList();
    }

    return filtered;
  }

  List<DateTime> get _availableDates {
    return _allReports.map((report) => report['date'] as DateTime).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            if (_isSearchVisible) _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildHistoryTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical History',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_filteredReports.length} reports available',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isSearchVisible = !_isSearchVisible),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _isSearchVisible
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: CustomIconWidget(
                iconName: 'search',
                color: _isSearchVisible
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _currentFilters.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: CustomIconWidget(
                iconName: 'filter_list',
                color: _currentFilters.isNotEmpty
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'History'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search reports and diagnoses...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'clear',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.lightTheme.colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(),
          SizedBox(height: 3.h),
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final filteredReports = _filteredReports;

    return Column(
      children: [
        DateRangeSelector(
          selectedDate: _selectedDate,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          availableDates: _availableDates,
        ),
        Expanded(
          child: filteredReports.isEmpty
              ? EmptyStateWidget(
                  onUploadPressed: () =>
                      Navigator.pushNamed(context, '/document-upload'),
                )
              : RefreshIndicator(
                  onRefresh: _refreshReports,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 2.h, bottom: 4.h),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return MedicalReportCard(
                        report: report,
                        onTap: () => _navigateToReportDetails(report),
                        onShare: () => _shareReport(report),
                        onDownload: () => _downloadReport(report),
                        onDelete: () => _deleteReport(report),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 2.h, bottom: 4.h),
      child: Column(
        children: [
          ProgressTrackingSection(healthMetrics: _healthMetrics),
          SizedBox(height: 3.h),
          _buildHealthInsights(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Reports',
            _allReports.length.toString(),
            'description',
            AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            'This Month',
            _allReports
                .where((r) {
                  final date = r['date'] as DateTime;
                  final now = DateTime.now();
                  return date.month == now.month && date.year == now.year;
                })
                .length
                .toString(),
            'calendar_today',
            AppTheme.lightTheme.colorScheme.secondary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            'Abnormal',
            _allReports
                .where((r) => r['severity'] != 'Normal')
                .length
                .toString(),
            'warning',
            AppTheme.warningLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 8.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    final recentReports = _allReports.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Reports',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ...recentReports.map((report) => MedicalReportCard(
              report: report,
              onTap: () => _navigateToReportDetails(report),
              onShare: () => _shareReport(report),
              onDownload: () => _downloadReport(report),
              onDelete: () => _deleteReport(report),
            )),
      ],
    );
  }

  Widget _buildHealthInsights() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'insights',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Health Insights',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildInsightItem(
            'Improvement Trend',
            'Your overall health metrics show a positive trend over the last 6 months.',
            'trending_up',
            AppTheme.lightTheme.colorScheme.secondary,
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            'Risk Factors',
            'Cholesterol levels require monitoring. Consider dietary adjustments.',
            'warning',
            AppTheme.warningLight,
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            'Next Steps',
            'Schedule follow-up appointments for blood work in 3 months.',
            'schedule',
            AppTheme.lightTheme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
      String title, String description, String iconName, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() => _currentFilters = filters);
        },
      ),
    );
  }

  Future<void> _refreshReports() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  void _navigateToReportDetails(Map<String, dynamic> report) {
    Navigator.pushNamed(context, '/diagnostic-results');
  }

  void _shareReport(Map<String, dynamic> report) {
    // Implement secure sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${report['title']}...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _downloadReport(Map<String, dynamic> report) {
    // Implement PDF download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${report['title']}...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _deleteReport(Map<String, dynamic> report) {
    setState(() {
      _allReports.removeWhere((r) => r['id'] == report['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${report['title']} deleted'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allReports.add(report);
            });
          },
        ),
      ),
    );
  }
}
