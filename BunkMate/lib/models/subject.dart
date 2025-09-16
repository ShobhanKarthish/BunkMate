import 'package:hive/hive.dart';
import 'schedule_item.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // Lecture, Lab, OPD

  @HiveField(3)
  double minAttendance; // Required percentage (e.g., 75.0)

  @HiveField(4)
  List<ScheduleItem> schedule;

  @HiveField(5)
  bool isMonthlyCalculation; // true for monthly, false for cumulative

  Subject({
    required this.id,
    required this.name,
    required this.type,
    required this.minAttendance,
    required this.schedule,
    this.isMonthlyCalculation = true,
  });

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, type: $type, minAttendance: $minAttendance)';
  }
}
