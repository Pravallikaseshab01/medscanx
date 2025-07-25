import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class StorageService {
  static final _client = SupabaseConfig.client;
  static final _storage = _client.storage;

  // Storage buckets
  static const String medicalScansbucket = 'medical-scans';
  static const String labReportsucket = 'lab-reports';
  static const String processedImagesucket = 'processed-images';
  static const String documentsucket = 'documents';

  // Upload file from File object
  static Future<String> uploadFile({
    required File file,
    required String bucket,
    required String filePath,
    Map<String, String>? metadata,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      return await uploadBytes(
        bytes: bytes,
        bucket: bucket,
        filePath: filePath,
        metadata: metadata,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload file from bytes
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String bucket,
    required String filePath,
    Map<String, String>? metadata,
  }) async {
    try {
      await _storage.from(bucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              metadata: metadata,
              upsert: true,
            ),
          );

      return getPublicUrl(bucket: bucket, filePath: filePath);
    } catch (e) {
      rethrow;
    }
  }

  // Upload medical scan
  static Future<String> uploadMedicalScan({
    required File file,
    required String userId,
    required String reportId,
    String? customFileName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last.toLowerCase();
      final fileName = customFileName ?? 'scan_${timestamp}.$extension';
      final filePath = '$userId/$reportId/$fileName';

      return await uploadFile(
        file: file,
        bucket: medicalScansucket,
        filePath: filePath,
        metadata: {
          'user_id': userId,
          'report_id': reportId,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload lab report
  static Future<String> uploadLabReport({
    required File file,
    required String userId,
    required String reportId,
    String? customFileName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last.toLowerCase();
      final fileName = customFileName ?? 'lab_report_${timestamp}.$extension';
      final filePath = '$userId/$reportId/$fileName';

      return await uploadFile(
        file: file,
        bucket: labReportsucket,
        filePath: filePath,
        metadata: {
          'user_id': userId,
          'report_id': reportId,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload processed image (AI analysis result)
  static Future<String> uploadProcessedImage({
    required Uint8List bytes,
    required String userId,
    required String reportId,
    String? customFileName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = customFileName ?? 'processed_${timestamp}.jpg';
      final filePath = '$userId/$reportId/$fileName';

      return await uploadBytes(
        bytes: bytes,
        bucket: processedImagesucket,
        filePath: filePath,
        metadata: {
          'user_id': userId,
          'report_id': reportId,
          'processed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get public URL for file
  static String getPublicUrl({
    required String bucket,
    required String filePath,
  }) {
    return _storage.from(bucket).getPublicUrl(filePath);
  }

  // Download file as bytes
  static Future<Uint8List> downloadFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final bytes = await _storage.from(bucket).download(filePath);
      return bytes;
    } catch (e) {
      rethrow;
    }
  }

  // Delete file
  static Future<void> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await _storage.from(bucket).remove([filePath]);
    } catch (e) {
      rethrow;
    }
  }

  // List files in a folder
  static Future<List<FileObject>> listFiles({
    required String bucket,
    String? folder,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _storage.from(bucket).list(
            path: folder,
            searchOptions: SearchOptions(
              limit: limit,
              offset: offset,
            ),
          );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Delete multiple files
  static Future<void> deleteFiles({
    required String bucket,
    required List<String> filePaths,
  }) async {
    try {
      await _storage.from(bucket).remove(filePaths);
    } catch (e) {
      rethrow;
    }
  }

  // Move file to different location
  static Future<void> moveFile({
    required String bucket,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await _storage.from(bucket).move(fromPath, toPath);
    } catch (e) {
      rethrow;
    }
  }

  // Get file metadata
  static Future<Map<String, dynamic>?> getFileMetadata({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final files = await _storage.from(bucket).list(
            path: filePath
                .split('/')
                .sublist(0, filePath.split('/').length - 1)
                .join('/'),
          );

      final fileName = filePath.split('/').last;
      final file = files.firstWhere(
        (f) => f.name == fileName,
        orElse: () => throw Exception('File not found'),
      );

      return file.metadata;
    } catch (e) {
      rethrow;
    }
  }

  // Generate signed URL (temporary access)
  static Future<String> createSignedUrl({
    required String bucket,
    required String filePath,
    int expiresInSeconds = 3600, // 1 hour default
  }) async {
    try {
      final signedUrl = await _storage.from(bucket).createSignedUrl(
            filePath,
            expiresInSeconds,
          );
      return signedUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to get appropriate bucket for file type
  static String getBucketForFileType(String fileType) {
    final lowerType = fileType.toLowerCase();

    if (lowerType.contains('image') ||
        lowerType.contains('dicom') ||
        lowerType.contains('dcm')) {
      return medicalScansucket;
    }

    if (lowerType.contains('pdf') ||
        lowerType.contains('lab') ||
        lowerType.contains('report')) {
      return labReportsucket;
    }

    return documentsucket;
  }

  // Validate file size and type
  static bool validateFile({
    required File file,
    int maxSizeInMB = 50,
    List<String>? allowedExtensions,
  }) {
    try {
      // Check file size
      final fileSizeInMB = file.lengthSync() / (1024 * 1024);
      if (fileSizeInMB > maxSizeInMB) {
        return false;
      }

      // Check file extension if provided
      if (allowedExtensions != null) {
        final extension = file.path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get file size in a readable format
  static String getReadableFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
