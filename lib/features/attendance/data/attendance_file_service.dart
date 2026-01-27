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
    final baseName = 'attendance_${attendance.lectureId}_$timestamp';

    // 🔹 PDF
    final pdfFile = File('${dir.path}/$baseName.pdf');
    await pdfFile.writeAsBytes(_buildPdf(attendance));

    // 🔹 Excel
    final excelFile = File('${dir.path}/$baseName.xlsx');
    await excelFile.writeAsBytes(_buildExcel(attendance));
  }

  // ---------------- PDF ----------------
  static List<int> _buildPdf(Attendance attendance) {
    // your existing PDF logic here
    return <int>[]; // replace with real bytes
  }

  // ---------------- EXCEL ----------------
  static List<int> _buildExcel(Attendance attendance) {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];

    // ✅ Header row
    sheet.appendRow([
      TextCellValue('Reg No'),
      TextCellValue('Name'),
      TextCellValue('Status'),
    ]);

    // ✅ Data rows
    for (final row in attendance.attendance) {
      sheet.appendRow([
        TextCellValue(row.regNo),
        TextCellValue(row.name),
        TextCellValue(row.status),
      ]);
    }

    // Convert to bytes
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to generate Excel');
    }

    return bytes;
  }
}
