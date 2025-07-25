import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/emergency_access_widget.dart';
import './widgets/security_background_widget.dart';
import './widgets/security_shield_widget.dart';

class BiometricAuthentication extends StatefulWidget {
  const BiometricAuthentication({super.key});

  @override
  State<BiometricAuthentication> createState() =>
      _BiometricAuthenticationState();
}

class _BiometricAuthenticationState extends State<BiometricAuthentication>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _showFailedAttempts = false;
  int _failedAttempts = 0;
  final int _maxFailedAttempts = 3;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: AppTheme.animationDurationMedium,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: AppTheme.animationDurationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _handleBiometricSuccess() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/medical-dashboard');
  }

  void _handleBiometricFailed() {
    setState(() {
      _failedAttempts++;
      _showFailedAttempts = true;
    });

    HapticFeedback.heavyImpact();

    if (_failedAttempts >= _maxFailedAttempts) {
      _showMaxAttemptsDialog();
    }
  }

  void _handleUsePasscode() {
    _showPasscodeDialog();
  }

  void _handleEmergencyAccess() {
    Navigator.pushReplacementNamed(context, '/medical-dashboard');
  }

  void _showPasscodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _PasscodeDialog(
          onSuccess: () {
            Navigator.of(context).pop();
            _handleBiometricSuccess();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showMaxAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: AppTheme.errorLight,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Too Many Attempts',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.errorLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Multiple authentication attempts have failed. For security reasons, please wait before trying again or use emergency access if this is a medical emergency.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: Text(
                'Exit App',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _failedAttempts = 0;
                  _showFailedAttempts = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
              ),
              child: Text(
                'Try Again',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SecurityBackgroundWidget(
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        children: [
                          SizedBox(height: 8.h),

                          // Security Shield Icon
                          const SecurityShieldWidget(),

                          SizedBox(height: 4.h),

                          // Main Heading
                          Text(
                            'Secure Medical Access',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              color:
                                  AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 2.h),

                          // Subtitle with HIPAA compliance
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusSmall),
                              border: Border.all(
                                color: AppTheme.lightTheme.primaryColor
                                    .withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'verified_user',
                                  color: AppTheme.lightTheme.primaryColor,
                                  size: 4.w,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    'HIPAA-compliant protection for your sensitive medical data',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 6.h),

                          // Failed attempts indicator
                          if (_showFailedAttempts) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 1.5.h),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.errorLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusSmall),
                                border: Border.all(
                                  color: AppTheme.errorLight
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'warning',
                                    color: AppTheme.errorLight,
                                    size: 4.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Failed attempts: $_failedAttempts/$_maxFailedAttempts',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme.errorLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                          ],

                          // Biometric Prompt
                          BiometricPromptWidget(
                            onBiometricSuccess: _handleBiometricSuccess,
                            onBiometricFailed: _handleBiometricFailed,
                            onUsePasscode: _handleUsePasscode,
                          ),

                          const Spacer(),

                          // Emergency Access
                          EmergencyAccessWidget(
                            onEmergencyAccess: _handleEmergencyAccess,
                          ),

                          SizedBox(height: 4.h),

                          // Security footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'lock',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Your medical data is encrypted and secure',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PasscodeDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _PasscodeDialog({
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_PasscodeDialog> createState() => _PasscodeDialogState();
}

class _PasscodeDialogState extends State<_PasscodeDialog> {
  final TextEditingController _passcodeController = TextEditingController();
  final FocusNode _passcodeFocus = FocusNode();
  bool _isProcessing = false;
  String _errorMessage = '';

  // Mock passcode for demonstration
  final String _correctPasscode = '123456';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _passcodeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    _passcodeFocus.dispose();
    super.dispose();
  }

  Future<void> _verifyPasscode() async {
    if (_passcodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your passcode';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    // Simulate passcode verification
    await Future.delayed(const Duration(seconds: 1));

    if (_passcodeController.text == _correctPasscode) {
      HapticFeedback.lightImpact();
      widget.onSuccess();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'Incorrect passcode. Please try again.';
        _isProcessing = false;
      });
      _passcodeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'lock',
            color: AppTheme.lightTheme.primaryColor,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Enter Passcode',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your 6-digit security passcode to access your medical data.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          TextField(
            controller: _passcodeController,
            focusNode: _passcodeFocus,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !_isProcessing,
            decoration: InputDecoration(
              labelText: 'Passcode',
              hintText: 'Enter 6-digit passcode',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'pin',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
              ),
              counterText: '',
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
            onSubmitted: (_) => _verifyPasscode(),
          ),
          if (_errorMessage.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                border: Border.all(
                  color: AppTheme.errorLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Demo passcode: $_correctPasscode',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : widget.onCancel,
          child: Text(
            'Cancel',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _verifyPasscode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.primaryColor,
          ),
          child: _isProcessing
              ? SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                )
              : Text(
                  'Verify',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
