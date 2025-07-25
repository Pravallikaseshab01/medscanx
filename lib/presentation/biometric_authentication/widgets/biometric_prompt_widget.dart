import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricPromptWidget extends StatefulWidget {
  final VoidCallback onBiometricSuccess;
  final VoidCallback onBiometricFailed;
  final VoidCallback onUsePasscode;

  const BiometricPromptWidget({
    super.key,
    required this.onBiometricSuccess,
    required this.onBiometricFailed,
    required this.onUsePasscode,
  });

  @override
  State<BiometricPromptWidget> createState() => _BiometricPromptWidgetState();
}

class _BiometricPromptWidgetState extends State<BiometricPromptWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Authenticating...';
    });

    _animationController.forward();

    try {
      // Simulate biometric authentication process
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful authentication (90% success rate)
      final isSuccess = DateTime.now().millisecond % 10 != 0;

      if (isSuccess) {
        HapticFeedback.lightImpact();
        setState(() {
          _statusMessage = 'Authentication successful';
        });
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onBiometricSuccess();
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _statusMessage = 'Authentication failed. Please try again.';
        });
        await Future.delayed(const Duration(seconds: 1));
        widget.onBiometricFailed();
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Biometric sensor unavailable';
      });
      await Future.delayed(const Duration(seconds: 1));
      widget.onBiometricFailed();
    } finally {
      _animationController.reverse();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: _isProcessing ? null : _authenticateWithBiometrics,
                child: Container(
                  width: 80.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.lightTheme.primaryColor,
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Center(
                    child: _isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Authenticating...',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'fingerprint',
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                size: 6.w,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Use Biometric Authentication',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
        if (_statusMessage.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _statusMessage.contains('successful')
                  ? AppTheme.successLight.withValues(alpha: 0.1)
                  : AppTheme.errorLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              border: Border.all(
                color: _statusMessage.contains('successful')
                    ? AppTheme.successLight
                    : AppTheme.errorLight,
                width: 1,
              ),
            ),
            child: Text(
              _statusMessage,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: _statusMessage.contains('successful')
                    ? AppTheme.successLight
                    : AppTheme.errorLight,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        SizedBox(height: 3.h),
        TextButton(
          onPressed: _isProcessing ? null : widget.onUsePasscode,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
          ),
          child: Text(
            'Use Passcode Instead',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
