import 'package:flutter/material.dart';
import '../presentation/biometric_authentication/biometric_authentication.dart';
import '../presentation/ai_analysis_processing/ai_analysis_processing.dart';
import '../presentation/document_upload/document_upload.dart';
import '../presentation/medical_dashboard/medical_dashboard.dart';
import '../presentation/diagnostic_results/diagnostic_results.dart';
import '../presentation/medical_history/medical_history.dart';
import '../presentation/authentication/login_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String loginScreen = '/login';
  static const String signupScreen = '/signup';
  static const String biometricAuthentication = '/biometric-authentication';
  static const String aiAnalysisProcessing = '/ai-analysis-processing';
  static const String documentUpload = '/document-upload';
  static const String medicalDashboard = '/medical-dashboard';
  static const String diagnosticResults = '/diagnostic-results';
  static const String medicalHistory = '/medical-history';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    loginScreen: (context) => const LoginScreen(),
    biometricAuthentication: (context) => const BiometricAuthentication(),
    aiAnalysisProcessing: (context) => const AiAnalysisProcessing(),
    documentUpload: (context) => const DocumentUpload(),
    medicalDashboard: (context) => const MedicalDashboard(),
    diagnosticResults: (context) => const DiagnosticResults(),
    medicalHistory: (context) => const MedicalHistory(),
    // TODO: Add your other routes here
  };
}
