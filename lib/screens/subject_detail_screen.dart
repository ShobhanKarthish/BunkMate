import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';
import 'add_edit_subject_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  late Box<AttendanceRecord> attendanceBox;

  @override
  void initState() {
    super.initState();
    attendanceBox = Hive.box<AttendanceRecord>(AppConstants.attendanceBox);
  }

  @override
  Widget build(BuildContext context) {
    final attendancePercentage =
        AttendanceService.calculateAttendancePercentage(widget.subject.id);
    final bunksAvailable =
        AttendanceService.calculateBunksAvailable(widget.subject.id);
    final breakdown =
        AttendanceService.getAttendanceBreakdown(widget.subject.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditSubjectScreen(subject: widget.subject),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: attendanceBox.listenable(),
        builder: (context, box, _) {
          return ListView(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            children: [
              // Summary Card
              _buildSummaryCard(
                  attendancePercentage, bunksAvailable, breakdown),
              const SizedBox(height: UIConstants.spacingL),

              // Schedule Card
              _buildScheduleCard(),
              const SizedBox(height: UIConstants.spacingL),

              // Attendance History
              _buildAttendanceHistory(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      double percentage, int bunksAvailable, Map<String, int> breakdown) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  UIConstants.classTypeIcons[widget.subject.type] ??
                      Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: UIConstants.spacingS),
                Text(
                  'Attendance Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),

            // Attendance Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Attendance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingM,
                    vertical: UIConstants.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(
                        percentage, widget.subject.minAttendance),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: UIConstants.fontL,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),

            // Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Attended', breakdown['attended']!, Colors.green),
                _buildStatItem('Missed', breakdown['missed']!, Colors.red),
                _buildStatItem('Total', breakdown['total']!, Colors.blue),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),

            // Bunks Available
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UIConstants.spacingM),
              decoration: BoxDecoration(
                color: bunksAvailable >= 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
                border: Border.all(
                  color: bunksAvailable >= 0 ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                bunksAvailable >= 0
                    ? 'You can bunk $bunksAvailable more class${bunksAvailable != 1 ? 'es' : ''}'
                    : 'Attend ${-bunksAvailable} more class${-bunksAvailable != 1 ? 'es' : ''} to reach ${widget.subject.minAttendance}%',
                style: TextStyle(
                  color: bunksAvailable >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: UIConstants.fontXXL,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            ...widget.subject.schedule.map((schedule) {
              final dayName = AppConstants.daysOfWeek[schedule.dayOfWeek - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: UIConstants.iconS,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: UIConstants.spacingS),
                    Text('$dayName at ${schedule.time}'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    final records = attendanceBox.values
        .where((record) => record.subjectId == widget.subject.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.all(UIConstants.spacingL),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      Text(
                        'No attendance records yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...records.take(10).map((record) => _buildAttendanceItem(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(AttendanceRecord record) {
    final dateStr = DateFormat('MMM dd, yyyy').format(record.date);
    final dayName = AppConstants.daysOfWeek[record.date.weekday - 1];

    Color statusColor;
    IconData statusIcon;

    switch (record.status) {
      case AppConstants.attended:
        statusColor = UIConstants.attendedColor;
        statusIcon = Icons.check_circle;
        break;
      case AppConstants.missed:
        statusColor = UIConstants.missedColor;
        statusIcon = Icons.cancel;
        break;
      case AppConstants.canceled:
        statusColor = UIConstants.canceledColor;
        statusIcon = Icons.event_busy;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: Text('$dayName, $dateStr'),
      trailing: Chip(
        label: Text(
          record.status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: UIConstants.fontS,
          ),
        ),
        backgroundColor: statusColor,
      ),
      onTap: () => _editAttendanceRecord(record),
    );
  }

  void _editAttendanceRecord(AttendanceRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Edit Attendance - ${DateFormat('MMM dd').format(record.date)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle,
                  color: UIConstants.attendedColor),
              title: const Text('Present'),
              onTap: () =>
                  _updateAttendanceRecord(record, AppConstants.attended),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: UIConstants.missedColor),
              title: const Text('Absent'),
              onTap: () => _updateAttendanceRecord(record, AppConstants.missed),
            ),
            ListTile(
              leading: const Icon(Icons.event_busy,
                  color: UIConstants.canceledColor),
              title: const Text('Canceled'),
              onTap: () =>
                  _updateAttendanceRecord(record, AppConstants.canceled),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateAttendanceRecord(AttendanceRecord record, String newStatus) {
    record.status = newStatus;
    record.save();
    Navigator.pop(context);
    setState(() {});
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
}
