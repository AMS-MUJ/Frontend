class AttendanceRecord {
  final String id;
  final String basePath;

  AttendanceRecord({required this.id, required this.basePath});

  String get pdfPath => '$basePath.pdf';
  String get excelPath => '$basePath.xlsx';
}
