import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicalReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const MedicalReportCard({
    Key? key,
    required this.report,
    this.onTap,
    this.onShare,
    this.onDownload,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final severity = report['severity'] as String? ?? 'Normal';
    final severityColor = _getSeverityColor(severity);
    
    return Dismissible(
      key: Key(report['id'].toString()),
      background: _buildSwipeBackground(isLeft: false),
      secondaryBackground: _buildSwipeBackground(isLeft: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart && onDelete != null) {
          onDelete!();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Show share/download options
          _showActionBottomSheet(context);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // Show delete confirmation
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(severityColor),
              _buildCardContent(),
              _buildCardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Color severityColor) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusMedium),
          topRight: Radius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: report['thumbnail'] != null
                  ? CustomImageWidget(
                      imageUrl: report['thumbnail'] as String,
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: CustomIconWidget(
                        iconName: 'description',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title'] as String? ?? 'Medical Report',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatDate(report['date'] as DateTime?),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Text(
              report['severity'] as String? ?? 'Normal',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnosis Summary',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            report['diagnosis'] as String? ?? 'No diagnosis available',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (report['confidence'] != null) ...[
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Text(
                  'Confidence: ',
                  style: AppTheme.lightTheme.textTheme.labelMedium,
                ),
                Text(
                  '${((report['confidence'] as double) * 100).toStringAsFixed(1)}%',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardFooter() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.borderRadiusMedium),
          bottomRight: Radius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'access_time',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 4.w,
          ),
          SizedBox(width: 1.w),
          Text(
            _getTimeAgo(report['date'] as DateTime?),
            style: AppTheme.lightTheme.textTheme.labelSmall,
          ),
          const Spacer(),
          if (report['hasHeatmap'] == true) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'visibility',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 3.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Heatmap',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
          ],
          CustomIconWidget(
            iconName: 'more_vert',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 4.w,
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? AppTheme.lightTheme.colorScheme.error : AppTheme.lightTheme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLeft) ...[
                CustomIconWidget(
                  iconName: 'share',
                  color: Colors.white,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'download',
                  color: Colors.white,
                  size: 6.w,
                ),
              ] else ...[
                CustomIconWidget(
                  iconName: 'delete',
                  color: Colors.white,
                  size: 6.w,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'moderate':
        return AppTheme.warningLight;
      case 'mild':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusXLarge),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                'Share Report',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                if (onShare != null) onShare!();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              title: Text(
                'Download PDF',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                if (onDownload != null) onDownload!();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusXLarge),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                'View Details',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                if (onTap != null) onTap!();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              title: Text(
                'Add to Favorites',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              title: Text(
                'Export Data',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                if (onDownload != null) onDownload!();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.warningLight,
                size: 6.w,
              ),
              title: Text(
                'Set Reminder',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Delete Report',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete this medical report? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}