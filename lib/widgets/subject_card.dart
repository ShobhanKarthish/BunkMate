import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onAttendanceMarked;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onAttendanceMarked,
  });

  @override
  Widget build(BuildContext context) {
    final attendancePercentage =
        AttendanceService.calculateAttendancePercentage(subject.id);
    final bunksAvailable =
        AttendanceService.calculateBunksAvailable(subject.id);
    final scheduleForToday = _getTodaysSchedule();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Icon(
                  UIConstants.classTypeIcons[subject.type] ?? Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                  size: UIConstants.iconM,
                ),
                const SizedBox(width: UIConstants.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        '${subject.type} • ${scheduleForToday ?? 'No time set'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Attendance Percentage
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingS,
                    vertical: UIConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(
                        attendancePercentage, subject.minAttendance),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: Text(
                    '${attendancePercentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),

            // Bunks Available Info
            if (bunksAvailable >= 0)
              Text(
                'You can bunk $bunksAvailable more class${bunksAvailable != 1 ? 'es' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
              )
            else
              Text(
                'Attend ${-bunksAvailable} more class${-bunksAvailable != 1 ? 'es' : ''} to reach ${subject.minAttendance}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
              ),

            const SizedBox(height: UIConstants.spacingM),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markAttendance(AppConstants.attended),
                    icon: const Icon(Icons.check, size: UIConstants.iconS),
                    label: const Text('Present'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.attendedColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingS),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markAttendance(AppConstants.missed),
                    icon: const Icon(Icons.close, size: UIConstants.iconS),
                    label: const Text('Absent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.missedColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _getTodaysSchedule() {
    final today = DateTime.now().weekday;
    final todaysSchedule =
        subject.schedule.where((s) => s.dayOfWeek == today).toList();

    if (todaysSchedule.isEmpty) return null;

    // Return the first scheduled time for today
    return todaysSchedule.first.time;
  }

  Color _getAttendanceColor(double percentage, double minRequired) {
    if (percentage >= minRequired) {
      return Colors.green;
    } else if (percentage >= minRequired - 10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _markAttendance(String status) {
    final attendanceBox =
        Hive.box<AttendanceRecord>(AppConstants.attendanceBox);
    final today = DateTime.now();

    // Check if attendance already marked for today
    final existingRecord = attendanceBox.values.firstWhere(
      (record) =>
          record.subjectId == subject.id &&
          record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day,
      orElse: () => AttendanceRecord(
          id: '', subjectId: '', date: DateTime.now(), status: ''),
    );

    if (existingRecord.id.isNotEmpty) {
      // Update existing record
      existingRecord.status = status;
      existingRecord.save();
    } else {
      // Create new record
      final newRecord = AttendanceRecord(
        id: const Uuid().v4(),
        subjectId: subject.id,
        date: today,
        status: status,
      );
      attendanceBox.add(newRecord);
    }

    onAttendanceMarked();
  }
}
