import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'prescription_review_screen.dart';
import '../../../infrastructure/ocr/ml_kit_ocr_service.dart';
import '../../../infrastructure/ocr/prescription_parser.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() => _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  final _imagePicker = ImagePicker();
  final _ocrService = MLKitOCRService();
  final _prescriptionParser = PrescriptionParser();

  bool _isProcessing = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return;

      await _processImage(File(photo.path));
    } catch (e) {
      _showError('Failed to capture photo: ${e.toString()}');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      await _processImage(File(image.path));
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      await _processPDF(file);
    } catch (e) {
      _showError('Failed to pick PDF: ${e.toString()}');
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => _isProcessing = true);

    try {
      // Extract text from image
      final text = await _ocrService.extractTextFromImage(imageFile);

      // Parse prescription
      final prescription = await _prescriptionParser.parse(text);

      if (!mounted) return;

      // Navigate to review screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PrescriptionReviewScreen(
            prescription: prescription,
            sourceImage: imageFile,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to process image: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processPDF(File pdfFile) async {
    setState(() => _isProcessing = true);

    try {
      // Extract text from PDF
      final text = await _ocrService.extractTextFromPDF(pdfFile);

      // Parse prescription
      final prescription = await _prescriptionParser.parse(text);

      if (!mounted) return;

      // Navigate to review screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PrescriptionReviewScreen(
            prescription: prescription,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to process PDF: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Prescription'),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing prescription...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few moments',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.document_scanner,
                    size: 100,
                    color: Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Upload Your Prescription',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We\'ll automatically extract medicine details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Camera option
                  ElevatedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gallery option
                  OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // PDF option
                  OutlinedButton.icon(
                    onPressed: _pickPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Upload PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
