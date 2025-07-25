import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DocumentThumbnailWidget extends StatelessWidget {
  final String fileName;
  final String? imageUrl;
  final String processingStatus;

  const DocumentThumbnailWidget({
    Key? key,
    required this.fileName,
    this.imageUrl,
    required this.processingStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Document thumbnail
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                    child: CustomImageWidget(
                      imageUrl: imageUrl!,
                      width: 15.w,
                      height: 15.w,
                      fit: BoxFit.cover,
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'description',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 8.w,
                  ),
          ),
          SizedBox(width: 3.w),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Text(
                    processingStatus,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (processingStatus.toLowerCase()) {
      case 'processing':
        return AppTheme.warningLight;
      case 'analyzing':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'completed':
        return AppTheme.successLight;
      case 'error':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
