class ApiRoutes {
  // ================= AUTH =================
  static const String login = '/login';
  static const String logout = '/logout';

  // ================= DASHBOARDS =================
  static const String teacherDashboard = '/dashboard/teacher';
  static const String studentDashboard = '/dashboard/student';

  // ================= CREATE CLASS =================
  static const String getSubjects = '/course/courses';

  // GET ?year=&branch=

  static const String getSections = '/section/sections';

  // GET ?courseName=&branch=

  static const String createPermanentClass = '/class/permanent';
  static const String createTemporaryClass = '/class/temporary';

  // ================= ATTENDANCE =================
  static const String markAttendance = '/attendance/mark-face';
  static const String isMarked = '/attendance/is-marked';

  // (Optional – if you add more later)
  static const String attendanceHistory = '/attendance/history';
}
