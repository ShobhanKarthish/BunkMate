import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  static Box<Subject> get _subjectsBox =>
      Hive.box<Subject>(AppConstants.subjectsBox);
  static Box<AttendanceRecord> get _attendanceBox =>
      Hive.box<AttendanceRecord>(AppConstants.attendanceBox);

  // Calculate attendance percentage for a subject
  static double calculateAttendancePercentage(String subjectId,
      {DateTime? forMonth}) {
    final subject = _subjectsBox.values.firstWhere((s) => s.id == subjectId);
    final now = DateTime.now();
    final targetMonth = forMonth ?? now;

    List<AttendanceRecord> records;

    if (subject.isMonthlyCalculation) {
      // Filter records for the specific month
      records = _attendanceBox.values.where((record) {
        return record.subjectId == subjectId &&
            record.date.year == targetMonth.year &&
            record.date.month == targetMonth.month &&
            record.status != AppConstants.canceled;
      }).toList();
    } else {
      // Get all records for cumulative calculation
      records = _attendanceBox.values.where((record) {
        return record.subjectId == subjectId &&
            record.status != AppConstants.canceled;
      }).toList();
    }

    if (records.isEmpty) return 0.0;

    final attendedCount =
        records.where((r) => r.status == AppConstants.attended).length;
    final totalCount = records.length;

    return (attendedCount / totalCount) * 100;
  }

  // Calculate how many classes can still be bunked
  static int calculateBunksAvailable(String subjectId, {DateTime? forMonth}) {
    final subject = _subjectsBox.values.firstWhere((s) => s.id == subjectId);
    final now = DateTime.now();
    final targetMonth = forMonth ?? now;

    List<AttendanceRecord> records;

    if (subject.isMonthlyCalculation) {
      records = _attendanceBox.values.where((record) {
        return record.subjectId == subjectId &&
            record.date.year == targetMonth.year &&
            record.date.month == targetMonth.month &&
            record.status != AppConstants.canceled;
      }).toList();
    } else {
      records = _attendanceBox.values.where((record) {
        return record.subjectId == subjectId &&
            record.status != AppConstants.canceled;
      }).toList();
    }

    if (records.isEmpty) return 0;

    final attendedCount =
        records.where((r) => r.status == AppConstants.attended).length;
    final totalCount = records.length;
    final requiredAttended = (totalCount * subject.minAttendance / 100).ceil();

    return attendedCount - requiredAttended;
  }

  // Get attendance breakdown for a subject
  static Map<String, int> getAttendanceBreakdown(String subjectId,
      {DateTime? forMonth}) {
    final subject = _subjectsBox.values.firstWhere((s) => s.id == subjectId);
    final now = DateTime.now();
    final targetMonth = forMonth ?? now;

    List<AttendanceRecord> records;

    if (subject.isMonthlyCalculation) {
      records = _attendanceBox.values.where((record) {
        return record.subjectId == subjectId &&
            record.date.year == targetMonth.year &&
            record.date.month == targetMonth.month;
      }).toList();
    } else {
      records = _attendanceBox.values.where((record) {
        return record.subjectId == subjectId;
      }).toList();
    }

    final attended =
        records.where((r) => r.status == AppConstants.attended).length;
    final missed = records.where((r) => r.status == AppConstants.missed).length;
    final canceled =
        records.where((r) => r.status == AppConstants.canceled).length;

    return {
      'attended': attended,
      'missed': missed,
      'canceled': canceled,
      'total': attended + missed, // Canceled classes don't count in total
    };
  }

  // Get subjects scheduled for a specific day
  static List<Subject> getSubjectsForDay(int dayOfWeek) {
    return _subjectsBox.values.where((subject) {
      return subject.schedule
          .any((schedule) => schedule.dayOfWeek == dayOfWeek);
    }).toList();
  }

  // Get today's subjects
  static List<Subject> getTodaysSubjects() {
    final today = DateTime.now().weekday;
    return getSubjectsForDay(today);
  }
}
