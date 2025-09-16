class AppConstants {
  // App Info
  static const String appName = 'BunkMate';
  static const String appVersion = '1.0.0';

  // Attendance
  static const double defaultMinAttendance = 75.0;
  static const int daysInWeek = 7;

  // Class Types
  static const String lecture = 'Lecture';
  static const String lab = 'Lab';
  static const String opd = 'OPD';

  static const List<String> classTypes = [lecture, lab, opd];

  // Attendance Status
  static const String attended = 'Attended';
  static const String missed = 'Missed';
  static const String canceled = 'Canceled';

  // Days of Week
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Hive Box Names
  static const String subjectsBox = 'subjects';
  static const String attendanceBox = 'attendance';
}
