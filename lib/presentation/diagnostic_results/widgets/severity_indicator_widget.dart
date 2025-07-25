import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SeverityIndicatorWidget extends StatelessWidget {
  final String severity;
  final String classification;
  final double confidence;

  const SeverityIndicatorWidget({
    Key? key,
    required this.severity,
    required this.classification,
    required this.confidence,
  }) : super(key: key);

  Color _getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'normal':
        return AppTheme.successLight;
      case 'abnormal':
        return AppTheme.warningLight;
      case 'requires attention':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  IconData _getSeverityIcon() {
    switch (severity.toLowerCase()) {
      case 'normal':
        return Icons.check_circle;
      case 'abnormal':
        return Icons.warning;
      case 'requires attention':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(
                  _getSeverityIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      severity.toUpperCase(),
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      classification,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textHighEmphasisLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                'Confidence: ',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: AppTheme.medicalValueStyle(
                  isLight: true,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: severityColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(severityColor),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
