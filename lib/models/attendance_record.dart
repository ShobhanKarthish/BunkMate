import 'package:hive/hive.dart';

part 'attendance_record.g.dart';

@HiveType(typeId: 2)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String status; // Attended, Missed, Canceled

  AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, subjectId: $subjectId, date: $date, status: $status)';
  }
}
