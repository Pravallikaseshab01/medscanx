
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/document_type_selector.dart';
import './widgets/drag_drop_zone.dart';
import './widgets/ocr_processing_indicator.dart';
import './widgets/selected_file_chip.dart';
import './widgets/upload_method_card.dart';

class DocumentUpload extends StatefulWidget {
  const DocumentUpload({super.key});

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;

  List<Map<String, dynamic>> _selectedFiles = [];
  String _selectedDocumentType = 'X-Ray';
  bool _isOcrProcessing = false;
  double _ocrProgress = 0.0;
  String _currentProcessingFile = '';
  bool _isDragDropActive = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await _requestCameraPermission();
        if (!hasPermission) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first)
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

        await _cameraController!.initialize();
        await _applySettings();
      }
    } catch (e) {
      // Silent fail - camera not available
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      // Settings not supported on this platform
    }
  }

  Future<void> _captureFromCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _initializeCamera();
    }

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile photo = await _cameraController!.takePicture();
        await _processSelectedFile(photo.path, photo.name);
      } catch (e) {
        _showErrorMessage('Failed to capture photo. Please try again.');
      }
    } else {
      _showErrorMessage(
          'Camera not available. Please use photo library instead.');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _processSelectedFile(image.path, image.name);
      }
    } catch (e) {
      _showErrorMessage('Failed to select image. Please try again.');
    }
  }

  Future<void> _selectFromFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          final filePath = kIsWeb ? file.name : file.path!;
          await _processSelectedFile(filePath, file.name);
        }
      }
    } catch (e) {
      _showErrorMessage('Failed to select files. Please try again.');
    }
  }

  Future<void> _processSelectedFile(String filePath, String fileName) async {
    // Check file size (mock implementation for demo)
    final fileSize = _getFileSizeString(fileName);
    final fileExtension = fileName.split('.').last.toLowerCase();

    if (_selectedFiles.length >= 5) {
      _showErrorMessage('Maximum 5 files allowed');
      return;
    }

    final fileData = {
      'name': fileName,
      'path': filePath,
      'size': fileSize,
      'type': fileExtension,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    setState(() {
      _selectedFiles.add(fileData);
    });

    // Start OCR processing simulation
    await _startOcrProcessing(fileName);
  }

  String _getFileSizeString(String fileName) {
    // Mock file size calculation
    final random = DateTime.now().millisecondsSinceEpoch % 5000 + 500;
    if (random < 1024) {
      return '${random}KB';
    } else {
      return '${(random / 1024).toStringAsFixed(1)}MB';
    }
  }

  Future<void> _startOcrProcessing(String fileName) async {
    setState(() {
      _isOcrProcessing = true;
      _currentProcessingFile = fileName;
      _ocrProgress = 0.0;
    });

    // Simulate OCR processing with real progress updates
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _ocrProgress = i / 100.0;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isOcrProcessing = false;
        _ocrProgress = 0.0;
        _currentProcessingFile = '';
      });
    }
  }

  void _removeFile(String fileId) {
    setState(() {
      _selectedFiles.removeWhere((file) => file['id'] == fileId);
    });
  }

  void _onDocumentTypeSelected(String type) {
    setState(() {
      _selectedDocumentType = type;
    });
  }

  void _onFilesDropped(List<String> files) {
    for (String file in files) {
      _processSelectedFile(file, file.split('/').last);
    }
  }

  void _analyzeDocuments() {
    if (_selectedFiles.isEmpty) {
      _showErrorMessage('Please select at least one document to analyze');
      return;
    }

    // Navigate to AI analysis processing screen
    Navigator.pushNamed(context, '/ai-analysis-processing');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Upload',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Methods Section
              Text(
                'Choose Upload Method',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 3.h),

              // Upload Method Cards
              Row(
                children: [
                  Expanded(
                    child: UploadMethodCard(
                      title: 'Camera Scan',
                      iconName: 'camera_alt',
                      supportedFormats: const ['.jpg', '.png'],
                      sizeLimit: '10MB',
                      onTap: _captureFromCamera,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: UploadMethodCard(
                      title: 'Photo Library',
                      iconName: 'photo_library',
                      supportedFormats: const ['.jpg', '.png'],
                      sizeLimit: '10MB',
                      onTap: _selectFromGallery,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              UploadMethodCard(
                title: 'Files',
                iconName: 'folder',
                supportedFormats: const ['.pdf', '.docx'],
                sizeLimit: '25MB',
                onTap: _selectFromFiles,
              ),

              SizedBox(height: 4.h),

              // Drag and Drop Zone
              GestureDetector(
                onTap: _selectFromFiles,
                child: DragDropZone(
                  onFilesDropped: _onFilesDropped,
                  isActive: _isDragDropActive,
                ),
              ),

              SizedBox(height: 3.h),

              // OCR Processing Indicator
              OcrProcessingIndicator(
                isProcessing: _isOcrProcessing,
                progress: _ocrProgress,
                currentFile: _currentProcessingFile,
              ),

              if (_isOcrProcessing) SizedBox(height: 3.h),

              // Selected Files
              if (_selectedFiles.isNotEmpty) ...[
                Text(
                  'Selected Files (${_selectedFiles.length})',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Wrap(
                  children: _selectedFiles.map((file) {
                    return SelectedFileChip(
                      fileName: file['name'],
                      fileSize: file['size'],
                      fileType: file['type'],
                      onRemove: () => _removeFile(file['id']),
                    );
                  }).toList(),
                ),
                SizedBox(height: 4.h),
              ],

              // Document Type Selector
              DocumentTypeSelector(
                selectedType: _selectedDocumentType,
                onTypeSelected: _onDocumentTypeSelected,
              ),

              SizedBox(height: 4.h),

              // Add Notes Section
              Text(
                'Add Notes (Optional)',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),

              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add any relevant medical context or symptoms...',
                  hintStyle: AppTheme.lightTheme.inputDecorationTheme.hintStyle,
                  border: AppTheme.lightTheme.inputDecorationTheme.border,
                  enabledBorder:
                      AppTheme.lightTheme.inputDecorationTheme.enabledBorder,
                  focusedBorder:
                      AppTheme.lightTheme.inputDecorationTheme.focusedBorder,
                  filled: true,
                  fillColor: AppTheme.lightTheme.inputDecorationTheme.fillColor,
                  contentPadding: EdgeInsets.all(4.w),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),

              SizedBox(height: 6.h),

              // Analyze Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _selectedFiles.isNotEmpty && !_isOcrProcessing
                      ? _analyzeDocuments
                      : null,
                  style:
                      AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3);
                      }
                      return AppTheme.lightTheme.colorScheme.primary;
                    }),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isOcrProcessing) ...[
                        SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Processing...',
                          style: AppTheme
                              .lightTheme.elevatedButtonTheme.style?.textStyle
                              ?.resolve({})?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      ] else ...[
                        CustomIconWidget(
                          iconName: 'analytics',
                          color: _selectedFiles.isNotEmpty
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Analyze Documents',
                          style: AppTheme
                              .lightTheme.elevatedButtonTheme.style?.textStyle
                              ?.resolve({})?.copyWith(
                            color: _selectedFiles.isNotEmpty
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
