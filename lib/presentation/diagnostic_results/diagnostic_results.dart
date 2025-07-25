import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/chat_explanation_widget.dart';
import './widgets/diagnosis_card_widget.dart';
import './widgets/expandable_section_widget.dart';
import './widgets/medical_image_viewer_widget.dart';
import './widgets/severity_indicator_widget.dart';

class DiagnosticResults extends StatefulWidget {
  const DiagnosticResults({Key? key}) : super(key: key);

  @override
  State<DiagnosticResults> createState() => _DiagnosticResultsState();
}

class _DiagnosticResultsState extends State<DiagnosticResults> {
  final ScrollController _scrollController = ScrollController();

  // Mock diagnostic data
  final Map<String, dynamic> _diagnosticData = {
    "patientId": "P-2025-001",
    "scanDate": "2025-01-25",
    "scanType": "Chest X-Ray",
    "originalImage":
        "https://images.pexels.com/photos/7089020/pexels-photo-7089020.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "severity": "Normal",
    "classification": "No abnormalities detected",
    "confidence": 0.94,
    "primaryDiagnosis": "Healthy Lung Tissue",
    "explanation":
        "The AI analysis of your chest X-ray shows clear, healthy lung fields with no signs of infection, inflammation, or structural abnormalities. Your heart size appears normal, and the lung tissue demonstrates good expansion and clarity.",
    "detailedAnalysis": [
      "Lung fields are clear bilaterally with no consolidation or infiltrates",
      "Cardiac silhouette is within normal limits",
      "No pleural effusion or pneumothorax detected",
      "Bone structures appear intact with no fractures visible",
      "Diaphragm positioning is normal and well-defined"
    ],
    "recommendations": [
      "Continue regular preventive care and annual check-ups",
      "Maintain healthy lifestyle with regular exercise",
      "Avoid smoking and limit exposure to air pollutants",
      "Consider annual chest X-rays if you have risk factors",
      "Consult your physician if you develop respiratory symptoms"
    ],
    "symptoms": [
      "No concerning symptoms identified in current analysis",
      "Monitor for persistent cough, shortness of breath, or chest pain",
      "Watch for fever or unexplained weight loss",
      "Report any changes in breathing patterns to your doctor"
    ],
    "analysisTimestamp": "2025-01-25T07:38:41.333528",
    "aiModel": "MedScanX-Vision-v2.1",
    "processingTime": "2.3 seconds"
  };

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: '$label copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void _showEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'emergency',
              color: AppTheme.errorLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Emergency Contact'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('For urgent medical concerns, contact:'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    'Emergency Services: 911',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'MedCenter Hospital: (555) 123-4567',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Calling emergency contact...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            icon: CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 16,
            ),
            label: Text('Call Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Diagnostic Results'),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textHighEmphasisLight,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _copyToClipboard(
              '${_diagnosticData["primaryDiagnosis"]}\n${_diagnosticData["explanation"]}',
              'Results summary',
            ),
            icon: CustomIconWidget(
              iconName: 'content_copy',
              color: AppTheme.textHighEmphasisLight,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {
              // Navigate to medical history
              Navigator.pushNamed(context, '/medical-history');
            },
            icon: CustomIconWidget(
              iconName: 'history',
              color: AppTheme.textHighEmphasisLight,
              size: 20,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'emergency':
                  _showEmergencyContact();
                  break;
                case 'dashboard':
                  Navigator.pushNamed(context, '/medical-dashboard');
                  break;
                case 'upload':
                  Navigator.pushNamed(context, '/document-upload');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'emergency',
                      color: AppTheme.errorLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text('Emergency Contact'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'dashboard',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'dashboard',
                      color: AppTheme.textMediumEmphasisLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text('Dashboard'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'upload',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'upload_file',
                      color: AppTheme.textMediumEmphasisLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text('New Upload'),
                  ],
                ),
              ),
            ],
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.textHighEmphasisLight,
              size: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scan Information Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'medical_information',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _diagnosticData["scanType"] as String,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Analyzed on ${_diagnosticData["scanDate"]}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasisLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Text(
                        'AI Analyzed',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Medical Image Viewer with Heatmap Toggle
              MedicalImageViewerWidget(
                imageUrl: _diagnosticData["originalImage"] as String,
                hasHeatmap: true,
              ),

              SizedBox(height: 3.h),

              // Severity Indicator
              SeverityIndicatorWidget(
                severity: _diagnosticData["severity"] as String,
                classification: _diagnosticData["classification"] as String,
                confidence: _diagnosticData["confidence"] as double,
              ),

              SizedBox(height: 3.h),

              // Primary Diagnosis Card
              GestureDetector(
                onLongPress: () => _copyToClipboard(
                  '${_diagnosticData["primaryDiagnosis"]}\n${_diagnosticData["explanation"]}',
                  'Diagnosis',
                ),
                child: DiagnosisCardWidget(
                  primaryDiagnosis:
                      _diagnosticData["primaryDiagnosis"] as String,
                  explanation: _diagnosticData["explanation"] as String,
                  confidence: _diagnosticData["confidence"] as double,
                ),
              ),

              SizedBox(height: 3.h),

              // Expandable Sections
              GestureDetector(
                onLongPress: () => _copyToClipboard(
                  (_diagnosticData["detailedAnalysis"] as List<String>)
                      .join('\n'),
                  'Detailed analysis',
                ),
                child: ExpandableSectionWidget(
                  title: 'Detailed Analysis',
                  iconName: 'analytics',
                  content: _diagnosticData["detailedAnalysis"] as List<String>,
                  isInitiallyExpanded: false,
                ),
              ),

              GestureDetector(
                onLongPress: () => _copyToClipboard(
                  (_diagnosticData["recommendations"] as List<String>)
                      .join('\n'),
                  'Recommendations',
                ),
                child: ExpandableSectionWidget(
                  title: 'Recommendations',
                  iconName: 'recommend',
                  content: _diagnosticData["recommendations"] as List<String>,
                  isInitiallyExpanded: false,
                ),
              ),

              GestureDetector(
                onLongPress: () => _copyToClipboard(
                  (_diagnosticData["symptoms"] as List<String>).join('\n'),
                  'Symptoms information',
                ),
                child: ExpandableSectionWidget(
                  title: 'Symptoms Information',
                  iconName: 'health_and_safety',
                  content: _diagnosticData["symptoms"] as List<String>,
                  isInitiallyExpanded: false,
                ),
              ),

              SizedBox(height: 3.h),

              // Chat-style Explanation Interface
              const ChatExplanationWidget(),

              SizedBox(height: 3.h),

              // Technical Information
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: Border.all(color: AppTheme.dividerLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Details',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'AI Model: ${_diagnosticData["aiModel"]}',
                            style: AppTheme.dataTextStyle(
                                isLight: true, fontSize: 12),
                          ),
                        ),
                        Text(
                          'Processing: ${_diagnosticData["processingTime"]}',
                          style: AppTheme.dataTextStyle(
                              isLight: true, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),

      // Floating Action Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "biometric",
            onPressed: () {
              Navigator.pushNamed(context, '/biometric-authentication');
            },
            backgroundColor: AppTheme.lightTheme.primaryColor,
            child: CustomIconWidget(
              iconName: 'fingerprint',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          SizedBox(height: 2.h),
          FloatingActionButton(
            heroTag: "emergency",
            onPressed: _showEmergencyContact,
            backgroundColor: AppTheme.errorLight,
            child: CustomIconWidget(
              iconName: 'emergency',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomNavigationBar: ActionButtonsWidget(
        onDownloadPdf: () {
          Fluttertoast.showToast(
            msg: 'Downloading diagnostic report as PDF...',
            toastLength: Toast.LENGTH_LONG,
          );
        },
        onShareSecurely: null, // Uses default implementation
        onScheduleAppointment: () {
          Fluttertoast.showToast(
            msg: 'Opening appointment scheduler...',
            toastLength: Toast.LENGTH_SHORT,
          );
        },
      ),
    );
  }
}
