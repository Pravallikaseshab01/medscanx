import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                _buildHeader(),
                SizedBox(height: 6.h),
                _buildEmailField(),
                SizedBox(height: 3.h),
                _buildPasswordField(),
                SizedBox(height: 2.h),
                _buildForgotPasswordButton(),
                SizedBox(height: 4.h),
                _buildLoginButton(),
                SizedBox(height: 3.h),
                _buildSignUpPrompt(),
                SizedBox(height: 4.h),
                _buildDemoCredentials(),
              ])))));
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge)),
            child: CustomIconWidget(
              iconName: 'medical_services',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 10.w))),
        SizedBox(height: 3.h),
        Center(
          child: Text(
            'MedScanX',
            style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary))),
        SizedBox(height: 1.h),
        Center(
          child: Text(
            'AI Health Diagnostic Assistant',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textMediumEmphasisLight))),
        SizedBox(height: 4.h),
        Text(
          'Sign In',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600)),
        SizedBox(height: 1.h),
        Text(
          'Access your medical dashboard',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: AppTheme.textMediumEmphasisLight)),
      ]);
  }

  Widget _buildEmailField() {
    return Column
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500)),
        SizedBox(height: 1.h),
        TextFormField
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppTheme.textMediumEmphasisLight,
              size: 5.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              borderSide: BorderSide(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              borderSide: BorderSide(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary))),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          }),
      ]);
  }

  Widget _buildPasswordField() {
    return Column
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500)),
        SizedBox(height: 1.h),
        TextFormField
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppTheme.textMediumEmphasisLight,
              size: 5.w),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textMediumEmphasisLight,
                size: 5.w),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              }),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              borderSide: BorderSide(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              borderSide: BorderSide(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary))),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          }),
      ]);
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500))));
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
          elevation: 0),
        child: _isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.onPrimary)))
            : Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600))));
  }

  Widget _buildSignUpPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textMediumEmphasisLight)),
          TextButton(
            onPressed: _handleSignUp,
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600))),
        ]));
  }

  Widget _buildDemoCredentials() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w),
              SizedBox(width: 2.w),
              Text(
                'Demo Credentials',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary)),
            ]),
          SizedBox(height: 2.h),
          _buildCredentialRow('Patient:', 'patient@example.com', 'password123'),
          SizedBox(height: 1.h),
          _buildCredentialRow('Doctor:', 'dr.johnson@example.com', 'password123'),
          SizedBox(height: 1.h),
          _buildCredentialRow('Admin:', 'admin@medscanx.com', 'password123'),
        ]));
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600)),
        SizedBox(height: 0.5.h),
        Text(
          'Email: $email',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            color: AppTheme.textMediumEmphasisLight)),
        Text(
          'Password: $password',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            color: AppTheme.textMediumEmphasisLight)),
      ]);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text);

      if (response.user != null) {
        await AuthService.updateLastLogin();
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.medicalDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorLight));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to receive password reset instructions.'),
            SizedBox(height: 2.h),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)))),
          ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset instructions sent to your email')));
            },
            child: Text('Send Reset Email')),
        ]));
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, AppRoutes.signupScreen);
  }
}