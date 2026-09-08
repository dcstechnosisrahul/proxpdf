import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:provider/provider.dart';
import 'package:proxpdf/providers/pdf_provider.dart';
import 'package:proxpdf/utils/responsive_utils.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class DropzoneWidget extends StatefulWidget {
  const DropzoneWidget({super.key});

  @override
  State<DropzoneWidget> createState() => _DropzoneWidgetState();
}

class _DropzoneWidgetState extends State<DropzoneWidget> {
  late DropzoneViewController controller;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final provider = Provider.of<PDFProvider>(context);

    return Container(
      height: isMobile ? 200 : 280,
      decoration: BoxDecoration(
        color: _isDragging ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDragging ? Colors.blue.shade400 : Colors.grey.shade300,
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          if (!isMobile)
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 10,
            ),
        ],
      ),
      child: isMobile ? _buildMobileUpload(context, provider) : _buildWebDropzone(context, provider),
    );
  }

  Widget _buildWebDropzone(BuildContext context, PDFProvider provider) {
    return DropzoneView(
      operation: DragOperation.copy,
      onCreated: (ctrl) => controller = ctrl,
      onDrop: (event) async {
        try {
          // New method for getting file data
          final data = await controller.getFileData(event);
          if (data != null) {
            provider.addFile(data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onHover: () => setState(() => _isDragging = true),
      onLeave: () => setState(() => _isDragging = false),
      cursor: CursorType.grab,
    );
  }

  Widget _buildMobileUpload(BuildContext context, PDFProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_file,
            size: 48,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                // For web file picker
                final input = html.FileUploadInputElement();
                input.accept = '.pdf';
                input.multiple = true;
                input.click();
                
                input.onChange.listen((e) {
                  final files = input.files;
                  if (files != null && files.isNotEmpty) {
                    for (var i = 0; i < files.length; i++) {
                      final file = files[i];
                      final reader = html.FileReader();
                      reader.readAsArrayBuffer(file);
                      reader.onLoadEnd.listen((event) {
                        final bytes = reader.result as Uint8List?;
                        if (bytes != null) {
                          provider.addFile(bytes);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File uploaded successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    }
                  }
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Choose Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          if (provider.uploadedFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${provider.uploadedFiles.length} file(s) uploaded',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}