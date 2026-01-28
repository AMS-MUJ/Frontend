import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../../teacher/domain/entities/attendance.dart';

class AttendanceFileService {
  static Future<void> generateFiles({required Attendance attendance}) async {
    if (attendance.attendance.isEmpty) {
      throw Exception('No attendance rows to write');
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final fileName = '${attendance.lectureId}.xlsx';

    final excelFile = File('${dir.path}/$fileName');

    final bytes = _buildExcel(attendance);
    await excelFile.writeAsBytes(bytes);
  }

  static List<int> _buildExcel(Attendance attendance) {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Header
    sheet.appendRow([
      TextCellValue('Reg No'),
      TextCellValue('Name'),
      TextCellValue('Status'),
    ]);

    // Rows
    for (final row in attendance.attendance) {
      sheet.appendRow([
        TextCellValue(row.regNo),
        TextCellValue(row.name),
        TextCellValue(row.status),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to generate Excel');
    }

    return bytes;
  }
}
