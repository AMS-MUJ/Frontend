import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../../teacher/domain/entities/attendance.dart';

class AttendanceFileService {
  static Future<void> generateFiles({required Attendance attendance}) async {
    final dir = await getApplicationDocumentsDirectory();

    // ---------------------------------------------
    // FILE NAME (Sanitized to avoid FileSystemException on invalid characters)
    // ---------------------------------------------
    final sanitizedSection = attendance.sectionId.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final sanitizedDate = attendance.date.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final fileName = '${sanitizedSection}_$sanitizedDate.xlsx';

    final excelFile = File('${dir.path}/$fileName');

    final bytes = _buildExcel(attendance);

    await excelFile.writeAsBytes(bytes);
  }

  static List<int> _buildExcel(Attendance attendance) {
    final excel = Excel.createExcel();

    final sheet = excel['Sheet1'];

    // ---------------------------------------------
    // METADATA
    // ---------------------------------------------
    sheet.appendRow([
      TextCellValue('Section'),
      TextCellValue(attendance.sectionId),
    ]);

    sheet.appendRow([TextCellValue('Date'), TextCellValue(attendance.date)]);

    sheet.appendRow([
      TextCellValue('Marked By'),
      TextCellValue(attendance.markedBy),
    ]);

    sheet.appendRow([
      TextCellValue('Present'),
      IntCellValue(attendance.present),
    ]);

    sheet.appendRow([TextCellValue('Absent'), IntCellValue(attendance.absent)]);

    sheet.appendRow([TextCellValue('Total'), IntCellValue(attendance.total)]);

    // Empty spacer row
    sheet.appendRow([]);

    // ---------------------------------------------
    // TABLE HEADER
    // ---------------------------------------------
    sheet.appendRow([
      TextCellValue('Reg No'),
      TextCellValue('Name'),
      TextCellValue('Status'),
    ]);

    // ---------------------------------------------
    // ROWS
    // ---------------------------------------------
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
