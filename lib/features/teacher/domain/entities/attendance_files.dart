class AttendanceFile {
  final String fileName;
  final String lectureId;
  final String date;

  AttendanceFile({
    required this.fileName,
    required this.lectureId,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'lectureId': lectureId,
    'date': date,
  };

  factory AttendanceFile.fromJson(Map<String, dynamic> json) {
    return AttendanceFile(
      fileName: json['fileName'],
      lectureId: json['lectureId'],
      date: json['date'],
    );
  }
}
