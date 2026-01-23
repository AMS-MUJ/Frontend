import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/attendance_record.dart';

class AttendanceFileService {
  /// ALWAYS creates BOTH PDF + EXCEL
  static Future<AttendanceRecord> createAttendance({
    required List<List<String>> rows,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final basePath = '${dir.path}/attendance_$id';

    await _createPdf('$basePath.pdf', rows);
    await _createExcel('$basePath.xlsx', rows);

    return AttendanceRecord(id: id, basePath: basePath);
  }

  static Future<void> _createPdf(String path, List<List<String>> rows) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(build: (_) => pw.TableHelper.fromTextArray(data: rows)),
    );

    await File(path).writeAsBytes(await pdf.save());
  }

  static Future<void> _createExcel(String path, List<List<String>> rows) async {
    final excel = Excel.createExcel();

    // remove default sheet
    excel.delete('Sheet1');

    final sheet = excel['Attendance'];

    for (final row in rows) {
      sheet.appendRow(row.map((cell) => TextCellValue(cell)).toList());
    }

    await File(path).writeAsBytes(excel.encode()!);
  }
}
