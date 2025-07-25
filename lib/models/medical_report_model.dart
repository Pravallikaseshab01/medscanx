class MedicalReportModel {
  final String id;
  final String patientId;
  final String? doctorId;
  final String title;
  final String reportType;
  final String status;
  final String severity;
  final String? originalFileUrl;
  final String? processedImageUrl;
  final Map<String, dynamic>? aiAnalysis;
  final String? doctorNotes;
  final String? diagnosis;
  final List<String>? recommendations;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalReportModel({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.title,
    required this.reportType,
    required this.status,
    required this.severity,
    this.originalFileUrl,
    this.processedImageUrl,
    this.aiAnalysis,
    this.doctorNotes,
    this.diagnosis,
    this.recommendations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalReportModel.fromJson(Map<String, dynamic> json) {
    return MedicalReportModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String?,
      title: json['title'] as String,
      reportType: json['report_type'] as String,
      status: json['status'] as String,
      severity: json['severity'] as String,
      originalFileUrl: json['original_file_url'] as String?,
      processedImageUrl: json['processed_image_url'] as String?,
      aiAnalysis: json['ai_analysis'] as Map<String, dynamic>?,
      doctorNotes: json['doctor_notes'] as String?,
      diagnosis: json['diagnosis'] as String?,
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'title': title,
      'report_type': reportType,
      'status': status,
      'severity': severity,
      'original_file_url': originalFileUrl,
      'processed_image_url': processedImageUrl,
      'ai_analysis': aiAnalysis,
      'doctor_notes': doctorNotes,
      'diagnosis': diagnosis,
      'recommendations': recommendations,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MedicalReportModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? title,
    String? reportType,
    String? status,
    String? severity,
    String? originalFileUrl,
    String? processedImageUrl,
    Map<String, dynamic>? aiAnalysis,
    String? doctorNotes,
    String? diagnosis,
    List<String>? recommendations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalReportModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      title: title ?? this.title,
      reportType: reportType ?? this.reportType,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      originalFileUrl: originalFileUrl ?? this.originalFileUrl,
      processedImageUrl: processedImageUrl ?? this.processedImageUrl,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      diagnosis: diagnosis ?? this.diagnosis,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  bool get isNormal => severity == 'normal';
  bool get isMild => severity == 'mild';
  bool get isModerate => severity == 'moderate';
  bool get isSevere => severity == 'severe';
  bool get isCritical => severity == 'critical';

  String get displayReportType {
    switch (reportType) {
      case 'xray':
        return 'X-Ray';
      case 'mri':
        return 'MRI Scan';
      case 'ct_scan':
        return 'CT Scan';
      case 'lab_report':
        return 'Lab Report';
      case 'ultrasound':
        return 'Ultrasound';
      default:
        return reportType.toUpperCase();
    }
  }

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending Analysis';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Analysis Failed';
      default:
        return status.toUpperCase();
    }
  }

  String get displaySeverity {
    switch (severity) {
      case 'normal':
        return 'Normal';
      case 'mild':
        return 'Mild';
      case 'moderate':
        return 'Moderate';
      case 'severe':
        return 'Severe';
      case 'critical':
        return 'Critical';
      default:
        return severity.toUpperCase();
    }
  }

  @override
  String toString() {
    return 'MedicalReportModel(id: $id, title: $title, status: $status, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicalReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
