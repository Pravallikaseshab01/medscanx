import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/medical_report_model.dart';
import '../../services/auth_service.dart';
import '../../services/medical_report_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/custom_tab_bar_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/health_insights_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/recent_diagnostics_widget.dart';

class MedicalDashboard extends StatefulWidget {
  const MedicalDashboard({Key? key}) : super(key: key);

  @override
  State<MedicalDashboard> createState() => _MedicalDashboardState();
}

class _MedicalDashboardState extends State<MedicalDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;

  // Replace mock data with real Supabase data
  List<MedicalReportModel> _recentDiagnostics = [];
  UserProfileModel? _currentUser;
  double _healthScore = 0.0;
  Map<String, int> _reportStats = {};
  final List<Map<String, dynamic>> _healthData = [
    {"month": "Jan", "value": 75},
    {"month": "Feb", "value": 80},
    {"month": "Mar", "value": 78},
    {"month": "Apr", "value": 85},
    {"month": "May", "value": 88},
    {"month": "Jun", "value": 92}
  ];

  final List<String> _recommendations = [
    "Maintain regular exercise routine for cardiovascular health",
    "Schedule follow-up blood work in 3 months",
    "Consider increasing daily water intake to 8 glasses",
    "Monitor blood pressure weekly and log readings"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load user profile
      _currentUser = await AuthService.getUserProfile();

      // Load recent diagnostics
      _recentDiagnostics = await MedicalReportService.getRecentDiagnostics();

      // Calculate health score
      _healthScore = await MedicalReportService.calculateHealthScore();

      // Get report statistics
      _reportStats = await MedicalReportService.getReportsStats();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomTabBarWidget(
              tabController: _tabController,
              tabs: const ['Dashboard', 'Upload', 'History', 'Profile'],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildPlaceholderTab('Upload'),
                  _buildPlaceholderTab('History'),
                  _buildPlaceholderTab('Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onQuickCameraScan,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'camera_alt',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 6.w,
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_currentUser == null) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GreetingHeaderWidget(
                userName: _currentUser?.fullName ?? "User",
                userRole: _currentUser?.displayRole ?? "Patient",
              ),
            ),
            SizedBox(height: 2.h),
            QuickStatsWidget(
              recentAnalysesCount: _reportStats['total'] ?? 0,
              pendingResults: _reportStats['pending'] ?? 0,
              healthScore: _healthScore,
            ),
            SizedBox(height: 1.h),
            QuickActionsWidget(
              onCameraScan: _onCameraScan,
              onUploadFiles: _onUploadFiles,
              onEmergencyContacts: _onEmergencyContacts,
            ),
            SizedBox(height: 1.h),
            RecentDiagnosticsWidget(
              diagnostics: _recentDiagnostics
                  .map((report) => {
                        "id": report.id,
                        "title": report.title,
                        "date": _formatDate(report.createdAt),
                        "severity": report.displaySeverity,
                        "thumbnail": report.processedImageUrl,
                        "type": report.displayReportType
                      })
                  .toList(),
              onDiagnosticTap: _onDiagnosticTap,
            ),
            SizedBox(height: 1.h),
            HealthInsightsWidget(
              healthData: _healthData,
              recommendations: _recommendations,
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'construction',
            color: AppTheme.textMediumEmphasisLight,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            '$tabName Coming Soon',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This feature is under development',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textMediumEmphasisLight,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadDashboardData();

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard refreshed successfully',
            style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
          ),
          backgroundColor: AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
      );
    }
  }

  void _onCameraScan() {
    Navigator.pushNamed(context, '/document-upload');
  }

  void _onUploadFiles() {
    Navigator.pushNamed(context, '/document-upload');
  }

  void _onEmergencyContacts() {
    _showEmergencyContactsDialog();
  }

  void _onQuickCameraScan() {
    Navigator.pushNamed(context, '/document-upload');
  }

  void _onDiagnosticTap(Map<String, dynamic> diagnostic) {
    Navigator.pushNamed(context, '/diagnostic-results',
        arguments: diagnostic['id']);
  }

  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'emergency',
                color: AppTheme.errorLight,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Emergency Contacts',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmergencyContact('Emergency Services', '911'),
              SizedBox(height: 2.h),
              _buildEmergencyContact('Poison Control', '1-800-222-1222'),
              SizedBox(height: 2.h),
              _buildEmergencyContact('Primary Care', '+1 (555) 123-4567'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmergencyContact(String name, String number) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.errorLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(
          color: AppTheme.errorLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  number,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textMediumEmphasisLight,
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'phone',
            color: AppTheme.errorLight,
            size: 5.w,
          ),
        ],
      ),
    );
  }
}
