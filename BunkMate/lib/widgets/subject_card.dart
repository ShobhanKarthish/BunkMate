import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';
import 'progress_ring.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final VoidCallback onAttendanceMarked;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onAttendanceMarked,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendancePercentage =
        AttendanceService.calculateAttendancePercentage(widget.subject.id);
    final bunksAvailable =
        AttendanceService.calculateBunksAvailable(widget.subject.id);
    final scheduleForToday = _getTodaysSchedule();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: UIConstants.subjectCardHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(UIConstants.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.spacingL),
              child: Row(
                children: [
                  // Progress Ring
                  ProgressRing(
                    percentage: attendancePercentage,
                    minRequired: widget.subject.minAttendance,
                    size: 64,
                    strokeWidth: 5,
                  ),

                  const SizedBox(width: UIConstants.spacingL),

                  // Subject Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Subject Name & Type
                        Row(
                          children: [
                            Icon(
                              UIConstants.classTypeIcons[widget.subject.type] ??
                                  Icons.school_outlined,
                              color: UIConstants.primaryAccent,
                              size: UIConstants.iconS,
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            Expanded(
                              child: Text(
                                widget.subject.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: UIConstants.primaryText,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: UIConstants.spacingXS),

                        // Time & Type
                        Text(
                          '${scheduleForToday ?? 'No time set'} • ${widget.subject.type}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: UIConstants.secondaryText,
                                    fontSize: UIConstants.fontS,
                                  ),
                        ),

                        const SizedBox(height: UIConstants.spacingS),

                        // Bunks Available Info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.spacingS,
                            vertical: UIConstants.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: _getBunksStatusColor(bunksAvailable)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusS),
                          ),
                          child: Text(
                            _getBunksStatusText(bunksAvailable),
                            style: TextStyle(
                              fontSize: UIConstants.fontXS,
                              fontWeight: FontWeight.w600,
                              color: _getBunksStatusColor(bunksAvailable),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: UIConstants.spacingM),

                  // Action Buttons
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.check_rounded,
                        color: AppTheme.attendanceGreen,
                        onPressed: () => _markAttendance(AppConstants.attended),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      _buildActionButton(
                        icon: Icons.close_rounded,
                        color: AppTheme.alertRed,
                        onPressed: () => _markAttendance(AppConstants.missed),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: UIConstants.iconM,
        ),
      ),
    );
  }

  String? _getTodaysSchedule() {
    final today = DateTime.now().weekday;
    final todaysSchedule =
        widget.subject.schedule.where((s) => s.dayOfWeek == today).toList();

    if (todaysSchedule.isEmpty) return null;

    return todaysSchedule.first.time;
  }

  Color _getBunksStatusColor(int bunksAvailable) {
    if (bunksAvailable >= 0) {
      return AppTheme.attendanceGreen;
    } else {
      return AppTheme.alertRed;
    }
  }

  String _getBunksStatusText(int bunksAvailable) {
    if (bunksAvailable >= 0) {
      return 'Can bunk $bunksAvailable more';
    } else {
      return 'Need ${-bunksAvailable} more';
    }
  }

  void _markAttendance(String status) {
    final attendanceBox =
        Hive.box<AttendanceRecord>(AppConstants.attendanceBox);
    final today = DateTime.now();

    // Check if attendance already marked for today
    final existingRecord = attendanceBox.values.firstWhere(
      (record) =>
          record.subjectId == widget.subject.id &&
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
        subjectId: widget.subject.id,
        date: today,
        status: status,
      );
      attendanceBox.add(newRecord);
    }

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Marked as ${status.toLowerCase()}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: status == AppConstants.attended
            ? AppTheme.attendanceGreen
            : AppTheme.alertRed,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
      ),
    );

    widget.onAttendanceMarked();
  }
}