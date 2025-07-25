
import '../core/supabase_config.dart';
import '../models/medical_report_model.dart';
import './auth_service.dart';

class MedicalReportService {
  static final _client = SupabaseConfig.client;

  // Get all medical reports for current user
  static Future<List<MedicalReportModel>> getUserReports({
    String? patientId,
    String? status,
    String? reportType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      String userId = patientId ?? AuthService.currentUserId!;

      var query =
          _client.from('medical_reports').select().eq('patient_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => MedicalReportModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get recent diagnostics (last 10)
  static Future<List<MedicalReportModel>> getRecentDiagnostics() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return [];

      final response = await _client
          .from('medical_reports')
          .select()
          .eq('patient_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      return response.map((json) => MedicalReportModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get single report by ID
  static Future<MedicalReportModel?> getReportById(String reportId) async {
    try {
      final response = await _client
          .from('medical_reports')
          .select()
          .eq('id', reportId)
          .maybeSingle();

      if (response == null) return null;
      return MedicalReportModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Create new medical report
  static Future<MedicalReportModel> createReport({
    required String title,
    required String reportType,
    String? doctorId,
    String? originalFileUrl,
    Map<String, dynamic>? aiAnalysis,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final reportData = {
        'patient_id': userId,
        'doctor_id': doctorId,
        'title': title,
        'report_type': reportType,
        'status': 'pending',
        'severity': 'normal',
        'original_file_url': originalFileUrl,
        'ai_analysis': aiAnalysis,
      };

      final response = await _client
          .from('medical_reports')
          .insert(reportData)
          .select()
          .single();

      return MedicalReportModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update report
  static Future<MedicalReportModel> updateReport({
    required String reportId,
    String? status,
    String? severity,
    String? processedImageUrl,
    Map<String, dynamic>? aiAnalysis,
    String? doctorNotes,
    String? diagnosis,
    List<String>? recommendations,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (status != null) updateData['status'] = status;
      if (severity != null) updateData['severity'] = severity;
      if (processedImageUrl != null)
        updateData['processed_image_url'] = processedImageUrl;
      if (aiAnalysis != null) updateData['ai_analysis'] = aiAnalysis;
      if (doctorNotes != null) updateData['doctor_notes'] = doctorNotes;
      if (diagnosis != null) updateData['diagnosis'] = diagnosis;
      if (recommendations != null)
        updateData['recommendations'] = recommendations;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('medical_reports')
          .update(updateData)
          .eq('id', reportId)
          .select()
          .single();

      return MedicalReportModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete report
  static Future<void> deleteReport(String reportId) async {
    try {
      await _client.from('medical_reports').delete().eq('id', reportId);
    } catch (e) {
      rethrow;
    }
  }

  // Get reports statistics
  static Future<Map<String, int>> getReportsStats({String? patientId}) async {
    try {
      String userId = patientId ?? AuthService.currentUserId!;

      final response = await _client
          .from('medical_reports')
          .select('status, severity')
          .eq('patient_id', userId);

      final stats = <String, int>{
        'total': 0,
        'pending': 0,
        'processing': 0,
        'completed': 0,
        'failed': 0,
        'normal': 0,
        'mild': 0,
        'moderate': 0,
        'severe': 0,
        'critical': 0,
      };

      for (final report in response) {
        stats['total'] = (stats['total'] ?? 0) + 1;
        final status = report['status'] as String;
        final severity = report['severity'] as String;

        stats[status] = (stats[status] ?? 0) + 1;
        stats[severity] = (stats[severity] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      rethrow;
    }
  }

  // Search reports
  static Future<List<MedicalReportModel>> searchReports({
    required String searchTerm,
    String? reportType,
    String? status,
    String? severity,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return [];

      var query = _client
          .from('medical_reports')
          .select()
          .eq('patient_id', userId)
          .or('title.ilike.%$searchTerm%,diagnosis.ilike.%$searchTerm%,doctor_notes.ilike.%$searchTerm%');

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (severity != null) {
        query = query.eq('severity', severity);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((json) => MedicalReportModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get health score calculation
  static Future<double> calculateHealthScore({String? patientId}) async {
    try {
      String userId = patientId ?? AuthService.currentUserId!;

      final response = await _client
          .from('medical_reports')
          .select('severity, created_at')
          .eq('patient_id', userId)
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(10);

      if (response.isEmpty) return 100.0;

      double totalScore = 0;
      int reportCount = 0;

      for (final report in response) {
        final severity = report['severity'] as String;
        double severityScore;

        switch (severity) {
          case 'normal':
            severityScore = 100;
            break;
          case 'mild':
            severityScore = 80;
            break;
          case 'moderate':
            severityScore = 60;
            break;
          case 'severe':
            severityScore = 40;
            break;
          case 'critical':
            severityScore = 20;
            break;
          default:
            severityScore = 100;
        }

        totalScore += severityScore;
        reportCount++;
      }

      return reportCount > 0 ? totalScore / reportCount : 100.0;
    } catch (e) {
      return 100.0; // Default to perfect health score on error
    }
  }

  // Listen to real-time changes
  static Stream<List<MedicalReportModel>> watchUserReports() {
    final userId = AuthService.currentUserId;
    if (userId == null) return Stream.empty();

    return _client
        .from('medical_reports')
        .stream(primaryKey: ['id'])
        .eq('patient_id', userId)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((json) => MedicalReportModel.fromJson(json)).toList());
  }
}
