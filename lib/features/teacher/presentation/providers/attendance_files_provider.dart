import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../attendance/domain/attendance_record.dart';

final attendanceFilesProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  try {
    final dir = await getApplicationDocumentsDirectory();

    final excelFiles = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.xlsx'))
        .toList();

    excelFiles.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );

    return excelFiles.map((file) {
      final basePath = file.path.replaceAll(
        RegExp(r'\.xlsx$', caseSensitive: false),
        '',
      );
      final id = basePath.split('_').last;

      return AttendanceRecord(id: id, basePath: basePath);
    }).toList();
  } catch (_) {
    return [];
  }
});
