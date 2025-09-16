import 'package:hive/hive.dart';

part 'schedule_item.g.dart';

@HiveType(typeId: 1)
class ScheduleItem extends HiveObject {
  @HiveField(0)
  int dayOfWeek; // 1 = Monday, 7 = Sunday

  @HiveField(1)
  String time; // Format: "HH:mm"

  ScheduleItem({
    required this.dayOfWeek,
    required this.time,
  });

  @override
  String toString() {
    return 'ScheduleItem(dayOfWeek: $dayOfWeek, time: $time)';
  }
}
