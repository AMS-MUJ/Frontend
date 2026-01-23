import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/attendance_record.dart';

final attendanceRecordsProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  final dir = await getApplicationDocumentsDirectory();

  final pdfs = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.pdf'),
  );

  return pdfs.map((pdf) {
    final basePath = pdf.path.replaceAll('.pdf', '');
    final id = basePath.split('_').last;
    return AttendanceRecord(id: id, basePath: basePath);
  }).toList();
});
