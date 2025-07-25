import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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

  // Mock data
  final List<Map<String, dynamic>> _recentDiagnostics = [
    {
      "id": 1,
      "title": "Chest X-Ray Analysis",
      "date": "July 24, 2025",
      "severity": "Normal",
      "thumbnail":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=300&ixlib=rb-4.0.3",
      "type": "X-Ray"
    },
    {
      "id": 2,
      "title": "Blood Test Report",
      "date": "July 22, 2025",
      "severity": "Mild",
      "thumbnail": null,
      "type": "Lab Report"
    },
    {
      "id": 3,
      "title": "MRI Brain Scan",
      "date": "July 20, 2025",
      "severity": "Moderate",
      "thumbnail":
          "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?fm=jpg&q=60&w=300&ixlib=rb-4.0.3",
      "type": "MRI"
    }
  ];

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
                userName: "Dr. Sarah Johnson",
                userRole: "Doctor",
              ),
            ),
            SizedBox(height: 2.h),
            QuickStatsWidget(
              recentAnalysesCount: _recentDiagnostics.length,
              pendingResults: 2,
              healthScore: 88.5,
            ),
            SizedBox(height: 1.h),
            QuickActionsWidget(
              onCameraScan: _onCameraScan,
              onUploadFiles: _onUploadFiles,
              onEmergencyContacts: _onEmergencyContacts,
            ),
            SizedBox(height: 1.h),
            RecentDiagnosticsWidget(
              diagnostics: _recentDiagnostics,
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

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

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
    Navigator.pushNamed(context, '/diagnostic-results');
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
