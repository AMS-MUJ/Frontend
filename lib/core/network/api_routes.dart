class ApiRoutes {
  // ================= AUTH =================
  static const String login = '/auth/login'; //working
  static const String logout = '/logout';
  static const String refresh = '/auth/refresh';

  // ================= DASHBOARDS =================
  static const String teacherDashboard = '/teacher/schedule/today'; //working
  static const String studentDashboard = '/student/schedule/today'; //working

  // ================= CREATE CLASS =================
  static const String getSubjects = '/course/courses';

  // GET ?year=&branch=

  static const String getSections = '/course/sections';

  // GET ?courseName=&branch=

  static const String createPermanentClass = '/teacher/schedule/permanent';
  static const String createTemporaryClass = '/teacher/schedule/extra';

  // ================= ATTENDANCE =================
  static const String markAttendance = '/attendance/mark'; //working
  static const String isMarked = '/attendance/is-marked';

  // (Optional – if you add more later)
  // static const String attendanceHistory = '/attendance/history';
}
