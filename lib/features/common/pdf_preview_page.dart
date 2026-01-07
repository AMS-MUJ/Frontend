import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final File file;

  const PdfPreviewPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Preview')),
      body: PdfPreview(
        build: (format) async {
          return await file.readAsBytes();
        },
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
