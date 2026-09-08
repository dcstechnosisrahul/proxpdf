import 'dart:typed_data';
import 'dart:ui'; // <--- ADD THIS IMPORT for Offset, Size, and Rect
import 'package:pdf/pdf.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart';
class PDFService {
  // ============ 1. MERGE PDF ============
  static Future<Uint8List> mergePDFs(List<Uint8List> pdfFiles) async {
    try {
      final PdfDocument outputPdf = PdfDocument();

      for (final fileData in pdfFiles) {
        final PdfDocument inputPdf = PdfDocument(inputBytes: fileData);
        for (int i = 0; i < inputPdf.pages.count; i++) {
          final PdfTemplate template = inputPdf.pages[i].createTemplate();
          final PdfPage page = outputPdf.pages.add();
          page.graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
            page.getClientSize(),
          );
        }
        inputPdf.dispose();
      }

      final List<int> bytes = outputPdf.saveSync();
      outputPdf.dispose();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to merge PDFs: $e');
    }
  }

  // ============ 2. SPLIT PDF ============
  static Future<List<Uint8List>> splitPDF(Uint8List pdfFile) async {
    try {
      final PdfDocument inputPdf = PdfDocument(inputBytes: pdfFile);
      final List<Uint8List> splitFiles = [];

      for (int i = 0; i < inputPdf.pages.count; i++) {
        final PdfDocument singlePagePdf = PdfDocument();
        final PdfTemplate template = inputPdf.pages[i].createTemplate();
        final PdfPage page = singlePagePdf.pages.add();
        page.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          page.getClientSize(),
        );

        splitFiles.add(Uint8List.fromList(singlePagePdf.saveSync()));
        singlePagePdf.dispose();
      }

      inputPdf.dispose();
      return splitFiles;
    } catch (e) {
      throw Exception('Failed to split PDF: $e');
    }
  }

  // ============ 3. COMPRESS PDF ============
  static Future<Uint8List> compressPDF(Uint8List pdfFile) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfFile);

      // Apply compression settings
      document.compressionLevel = PdfCompressionLevel.best;

      final List<int> bytes = document.saveSync();
      document.dispose();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to compress PDF: $e');
    }
  }

  // ============ 4. CONVERT IMAGE TO PDF ============
  static Future<Uint8List> convertToPDF(Uint8List imageData) async {
    try {
      final pdf = pw.Document();
      final image = pw.MemoryImage(imageData);

      pdf.addPage(
        pw.Page(
          pageFormat: p.PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Image(image),
          ),
        ),
      );

      return await pdf.save();
    } catch (e) {
      throw Exception('Failed to convert to PDF: $e');
    }
  }

  // ============ 5. ROTATE PDF ============
  static Future<Uint8List> rotatePDF(Uint8List pdfFile, int degrees) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfFile);

      PdfPageRotateAngle angle;
      switch (degrees % 360) {
        case 90:
          angle = PdfPageRotateAngle.rotateAngle90;
          break;
        case 180:
          angle = PdfPageRotateAngle.rotateAngle180;
          break;
        case 270:
          angle = PdfPageRotateAngle.rotateAngle270;
          break;
        default:
          angle = PdfPageRotateAngle.rotateAngle0;
      }

      for (int i = 0; i < document.pages.count; i++) {
        document.pages[i].rotation = angle;
      }

      final List<int> bytes = document.saveSync();
      document.dispose();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to rotate PDF: $e');
    }
  }

  // ============ 6. UNLOCK PDF ============
  static Future<Uint8List> unlockPDF(Uint8List pdfFile, String password) async {
    try {
      // Opening with password decrypts the document
      final PdfDocument document = PdfDocument(
        inputBytes: pdfFile,
        password: password,
      );

      // Remove encryption permissions for output
      document.security.permissions.clear();

      final List<int> bytes = document.saveSync();
      document.dispose();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to unlock PDF: $e');
    }
  }

  // ============ 7. ADD WATERMARK ============
  static Future<Uint8List> addWatermark(
    Uint8List pdfFile,
    String text, {
    double opacity = 0.3,
  }) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfFile);

      final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 48);
      final PdfBrush brush = PdfSolidBrush(
        PdfColor(150, 150, 150, (opacity * 255).round()),
      );

      for (int i = 0; i < document.pages.count; i++) {
        final PdfPage page = document.pages[i];
        final Size pageSize = page.getClientSize();

        // Measure text to center watermark
        final Size textSize = font.measureString(text);

        page.graphics.save();
        page.graphics.translateTransform(pageSize.width / 2, pageSize.height / 2);
        page.graphics.rotateTransform(-45);
        page.graphics.drawString(
          text,
          font,
          brush: brush,
          bounds: Rect.fromLTWH(
            -textSize.width / 2,
            -textSize.height / 2,
            textSize.width,
            textSize.height,
          ),
        );
        page.graphics.restore();
      }

      final List<int> bytes = document.saveSync();
      document.dispose();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to add watermark: $e');
    }
  }

  // ============ 8. ORGANIZE PAGES ============
  static Future<Uint8List> organizePages(
    Uint8List pdfFile,
    List<int> newOrder,
  ) async {
    try {
      final PdfDocument inputPdf = PdfDocument(inputBytes: pdfFile);
      final PdfDocument outputPdf = PdfDocument();

      for (final index in newOrder) {
        if (index >= 0 && index < inputPdf.pages.count) {
          final PdfTemplate template = inputPdf.pages[index].createTemplate();
          final PdfPage page = outputPdf.pages.add();
          page.graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
            page.getClientSize(),
          );
        }
      }

      inputPdf.dispose();
      final List<int> bytes = outputPdf.saveSync();
      outputPdf.dispose();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to organize pages: $e');
    }
  }

  // ============ Helper: Get PDF Info ============
  static Future<Map<String, dynamic>> getPDFInfo(Uint8List pdfFile) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfFile);
      final count = document.pages.count;
      document.dispose();

      return {
        'pages': count,
        'size': (pdfFile.length / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      return {'pages': 0, 'size': '0'};
    }
  }
}