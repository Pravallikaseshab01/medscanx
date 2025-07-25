import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onShareSecurely;
  final VoidCallback? onScheduleAppointment;

  const ActionButtonsWidget({
    Key? key,
    this.onDownloadPdf,
    this.onShareSecurely,
    this.onScheduleAppointment,
  }) : super(key: key);

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusXLarge),
          ),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Secure Sharing Options',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textHighEmphasisLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: AppTheme.warningLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.warningLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Medical data will be encrypted and protected with OTP verification',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            _buildShareOption(
              context,
              'Email with OTP',
              'Send encrypted report via email',
              'email',
              () {
                Navigator.pop(context);
                _showOTPDialog(context, 'Email');
              },
            ),
            SizedBox(height: 2.h),
            _buildShareOption(
              context,
              'Healthcare Provider',
              'Share directly with your doctor',
              'local_hospital',
              () {
                Navigator.pop(context);
                _showProviderDialog(context);
              },
            ),
            SizedBox(height: 2.h),
            _buildShareOption(
              context,
              'Emergency Contact',
              'Share with designated emergency contact',
              'emergency',
              () {
                Navigator.pop(context);
                _showEmergencyShareDialog(context);
              },
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
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
                      color: AppTheme.textHighEmphasisLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasisLight,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.textMediumEmphasisLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showOTPDialog(BuildContext context, String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Secure Sharing - $method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter recipient\'s email address:'),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                hintText: 'doctor@hospital.com',
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Secure sharing initiated. OTP sent to recipient.',
                toastLength: Toast.LENGTH_LONG,
              );
            },
            child: Text('Send Securely'),
          ),
        ],
      ),
    );
  }

  void _showProviderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share with Healthcare Provider'),
        content: Text(
            'Share this diagnostic report with Dr. Sarah Johnson at MedCenter Hospital?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Report shared securely with healthcare provider.',
                toastLength: Toast.LENGTH_LONG,
              );
            },
            child: Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Contact Sharing'),
        content: Text(
            'Share this report with your emergency contact: John Doe (+1-555-0123)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Report shared with emergency contact.',
                toastLength: Toast.LENGTH_LONG,
              );
            },
            child: Text('Share'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onDownloadPdf ??
                  () {
                    Fluttertoast.showToast(
                      msg: 'PDF report downloaded successfully',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  },
              icon: CustomIconWidget(
                iconName: 'download',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 18,
              ),
              label: Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  onShareSecurely ?? () => _showShareBottomSheet(context),
              icon: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.primaryColor,
                size: 18,
              ),
              label: Text('Share'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.successLight,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: IconButton(
              onPressed: onScheduleAppointment ??
                  () {
                    Fluttertoast.showToast(
                      msg: 'Redirecting to appointment scheduling...',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  },
              icon: CustomIconWidget(
                iconName: 'calendar_today',
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
