import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart' as pdf_render;

/// On-device OCR service using ML Kit
class MLKitOCRService {
  final TextRecognizer _textRecognizer;

  MLKitOCRService({TextRecognizer? textRecognizer})
      : _textRecognizer = textRecognizer ?? TextRecognizer();

  /// Extract text from an image file
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text from image: ${e.toString()}');
    }
  }

  /// Extract text from a PDF file
  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      final doc = await pdf_render.PdfDocument.openFile(pdfFile.path);
      final pageCount = doc.pages.length;
      final buffer = StringBuffer();

      for (var i = 1; i <= pageCount; i++) {
        final page = doc.pages[i];

        // Render PDF page to image at higher resolution for better OCR
        final pageImage = await page.render(
          width: (page.width * 2).toInt(),
          height: (page.height * 2).toInt(),
        );

        // Convert to temporary file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_page_$i.png');

        // Write the rendered image bytes to file
        final renderedImage = await pageImage?.createImage();
        if (renderedImage != null) {
          final pngBytes = img.encodePng(renderedImage as img.Image);
          await tempFile.writeAsBytes(pngBytes);
        }

        // Extract text from the rendered image
        if (await tempFile.exists()) {
          final text = await extractTextFromImage(tempFile);
          buffer.writeln(text);

          // Clean up
          await tempFile.delete();
        }
      }

      await doc.dispose();

      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: ${e.toString()}');
    }
  }

  /// Process and enhance image before OCR (optional preprocessing)
  Future<File> preprocessImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Apply preprocessing
      // 1. Convert to grayscale
      final grayscale = img.grayscale(image);

      // 2. Increase contrast
      final contrasted = img.adjustColor(
        grayscale,
        contrast: 1.2,
        brightness: 1.1,
      );

      // Save processed image
      final tempDir = await getTemporaryDirectory();
      final processedFile = File('${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png');
      await processedFile.writeAsBytes(img.encodePng(contrasted));

      return processedFile;
    } catch (e) {
      // If preprocessing fails, return original image
      return imageFile;
    }
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
