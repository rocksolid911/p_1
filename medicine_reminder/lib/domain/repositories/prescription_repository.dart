import 'dart:io';
import '../entities/prescription.dart';

/// Repository interface for prescription operations
abstract class PrescriptionRepository {
  /// Extract text from an image file
  Future<String> extractTextFromImage(File imageFile);

  /// Extract text from a PDF file
  Future<String> extractTextFromPDF(File pdfFile);

  /// Parse prescription text into structured data
  Future<ParsedPrescription> parsePrescriptionText(String text);

  /// Process an image prescription
  Future<ParsedPrescription> processImagePrescription(File imageFile);

  /// Process a PDF prescription
  Future<ParsedPrescription> processPDFPrescription(File pdfFile);
}
