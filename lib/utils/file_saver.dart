// lib/utils/file_saver.dart
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;

class FileSaver {
  // Single file download (PDF/ZIP/etc.)
  static void downloadFile(Uint8List bytes, String fileName, {String mimeType = 'application/pdf'}) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;

    html.document.body?.children.add(anchor);
    anchor.click();

    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Multiple files ko ZIP bana kar download karne ke liye
  static void downloadZip(List<Uint8List> files, String zipFileName, {String filePrefix = 'page'}) {
    final archive = Archive();

    for (int i = 0; i < files.length; i++) {
      final fileName = '${filePrefix}_${i + 1}.pdf';
      final fileData = files[i];
      // ZIP archive mein har file add karein
      archive.addFile(ArchiveFile(fileName, fileData.length, fileData));
    }

    // Archive ko ZIP bytes mein encode karein
    final zipData = ZipEncoder().encode(archive);
    if (zipData != null) {
      downloadFile(
        Uint8List.fromList(zipData),
        zipFileName,
        mimeType: 'application/zip',
      );
    }
  }
}