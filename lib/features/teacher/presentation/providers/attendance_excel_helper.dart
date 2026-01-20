import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/attendance.dart';

Future<File> generateAttendanceExcel(Attendance attendance) async {
  final excel = Excel.createExcel();
  final sheet = excel['Attendance'];

  /// ✅ Header row
  sheet.appendRow([TextCellValue('Registration No'), TextCellValue('Status')]);

  /// ✅ Data rows
  for (final row in attendance.attendance) {
    sheet.appendRow([TextCellValue(row.regNo), TextCellValue(row.status)]);
  }

  final dir = await getApplicationDocumentsDirectory();

  final file = File(
    '${dir.path}/${attendance.fileName.replaceAll('.pdf', '.xlsx')}',
  );

  await file.writeAsBytes(excel.encode()!);
  return file;
}
