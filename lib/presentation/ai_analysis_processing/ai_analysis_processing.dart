import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/background_processing_toggle_widget.dart';
import './widgets/document_thumbnail_widget.dart';
import './widgets/processing_steps_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/time_estimate_widget.dart';

class AiAnalysisProcessing extends StatefulWidget {
  const AiAnalysisProcessing({Key? key}) : super(key: key);

  @override
  State<AiAnalysisProcessing> createState() => _AiAnalysisProcessingState();
}

class _AiAnalysisProcessingState extends State<AiAnalysisProcessing>
    with TickerProviderStateMixin {
  // Mock data for the uploaded document
  final Map<String, dynamic> uploadedDocument = {
    "fileName": "chest_xray_report.pdf",
    "imageUrl":
        "https://images.pexels.com/photos/4386466/pexels-photo-4386466.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "uploadTime": DateTime.now().subtract(Duration(minutes: 2)),
    "fileSize": "2.4 MB",
    "documentType": "Medical Report"
  };

  // Processing state variables
  double _progress = 0.0;
  int _currentStep = 0;
  bool _isProcessing = true;
  bool _backgroundProcessing = false;
  int _estimatedMinutes = 3;
  int _estimatedSeconds = 45;

  // Processing steps
  final List<String> _processingSteps = [
    'Extracting Text (OCR)',
    'Analyzing Content (NLP)',
    'Generating Insights (Classification)',
    'Creating Visualizations (Grad-CAM)'
  ];

  late AnimationController _progressController;
  late AnimationController _stepController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startProcessingSimulation();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _startProcessingSimulation() {
    // Simulate real-time processing with dynamic updates
    Future.delayed(Duration(seconds: 1), () {
      _updateProgress(25.0, 0, 3, 20);
    });

    Future.delayed(Duration(seconds: 3), () {
      _updateProgress(50.0, 1, 2, 45);
    });

    Future.delayed(Duration(seconds: 6), () {
      _updateProgress(75.0, 2, 1, 30);
    });

    Future.delayed(Duration(seconds: 9), () {
      _updateProgress(90.0, 3, 0, 45);
    });

    Future.delayed(Duration(seconds: 12), () {
      _completeProcessing();
    });
  }

  void _updateProgress(double progress, int step, int minutes, int seconds) {
    if (mounted && _isProcessing) {
      setState(() {
        _progress = progress;
        _currentStep = step;
        _estimatedMinutes = minutes;
        _estimatedSeconds = seconds;
      });
      _progressController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _completeProcessing() {
    if (mounted && _isProcessing) {
      setState(() {
        _progress = 100.0;
        _currentStep = _processingSteps.length;
        _isProcessing = false;
        _estimatedMinutes = 0;
        _estimatedSeconds = 0;
      });

      HapticFeedback.mediumImpact();

      // Navigate to diagnostic results after celebration
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/diagnostic-results');
        }
      });
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warningLight,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Cancel Analysis?',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Your analysis progress will be lost and you\'ll need to upload the document again. Are you sure you want to cancel?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Processing',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelProcessing();
              },
              child: Text(
                'Cancel Analysis',
                style: TextStyle(
                  color: AppTheme.errorLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cancelProcessing() {
    setState(() {
      _isProcessing = false;
    });
    Navigator.pushReplacementNamed(context, '/document-upload');
  }

  void _toggleBackgroundProcessing(bool value) {
    setState(() {
      _backgroundProcessing = value;
    });

    if (value) {
      // Show background processing notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'You\'ll receive a notification when analysis is complete',
                  style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to dashboard for background processing
      Navigator.pushReplacementNamed(context, '/medical-dashboard');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isProcessing) {
          _showCancelDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'AI Analysis',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: AppTheme.lightTheme.appBarTheme.elevation,
          leading: _isProcessing
              ? null
              : IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
          automaticallyImplyLeading: !_isProcessing,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Document thumbnail with status
                DocumentThumbnailWidget(
                  fileName: uploadedDocument["fileName"],
                  imageUrl: uploadedDocument["imageUrl"],
                  processingStatus: _isProcessing ? 'Processing' : 'Completed',
                ),

                SizedBox(height: 4.h),

                // Large progress indicator with medical pulse effect
                ProgressIndicatorWidget(
                  progress: _progress,
                  isProcessing: _isProcessing,
                ),

                SizedBox(height: 4.h),

                // Processing steps list
                ProcessingStepsWidget(
                  currentStep: _currentStep,
                  steps: _processingSteps,
                ),

                SizedBox(height: 3.h),

                // Time estimate
                if (_isProcessing)
                  TimeEstimateWidget(
                    estimatedMinutes: _estimatedMinutes,
                    estimatedSeconds: _estimatedSeconds,
                  ),

                SizedBox(height: 2.h),

                // Background processing toggle
                if (_isProcessing)
                  BackgroundProcessingToggleWidget(
                    isEnabled: _backgroundProcessing,
                    onToggle: _toggleBackgroundProcessing,
                  ),

                SizedBox(height: 4.h),

                // Action buttons
                ActionButtonsWidget(
                  onCancel: _showCancelDialog,
                  isProcessing: _isProcessing,
                ),

                SizedBox(height: 4.h),

                // Processing info card
                if (_isProcessing)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.05),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Processing Information',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Our AI is analyzing your medical document using advanced machine learning algorithms. The process includes text extraction, content analysis, and generating visual explanations to help you understand the results.',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
