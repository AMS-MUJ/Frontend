import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../attendance/domain/attendance_record.dart';

final attendanceFilesProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  final dir = await getApplicationDocumentsDirectory();

  final pdfFiles = dir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.pdf'))
      .toList();

  pdfFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

  return pdfFiles.map((pdf) {
    final basePath = pdf.path.replaceAll('.pdf', '');
    final id = basePath.split('_').last;

    return AttendanceRecord(id: id, basePath: basePath);
  }).toList();
});
