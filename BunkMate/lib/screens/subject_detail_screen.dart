import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/subject.dart';
import '../services/attendance_service.dart';
import '../widgets/progress_ring.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UIConstants.spacingL),
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

              child: Column(
                children: [
                  // Progress Ring
                  ProgressRing(
                    percentage: attendancePercentage,
                    minRequired: widget.subject.minAttendance,
                    size: 120,
                    strokeWidth: 8,
                  ),

                  const SizedBox(height: UIConstants.spacingL),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Attended',
                        '${breakdown['attended']}',
                        AppTheme.attendanceGreen,
                      ),
                      _buildStatItem(
                        'Total',
                        '${breakdown['total']}',
                        UIConstants.secondaryText,
                      ),
                      _buildStatItem(
                        'Required',
                        '${widget.subject.minAttendance}%',
                        UIConstants.primaryAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: UIConstants.spacingL),

            // Bunks Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UIConstants.spacingL),
              decoration: BoxDecoration(
                color: bunksAvailable >= 0
                    ? UIConstants.cardGreen
                    : UIConstants.cardOrange,
                borderRadius: BorderRadius.circular(UIConstants.radiusXL),
              ),
              child: Row(
                children: [
                  Icon(
                    bunksAvailable >= 0
                        ? Icons.check_circle_outline
                        : Icons.warning_outlined,
                    color: bunksAvailable >= 0
                        ? AppTheme.attendanceGreen
                        : AppTheme.alertRed,
                    size: UIConstants.iconM,
                  ),
                  const SizedBox(width: UIConstants.spacingM),
                  Expanded(
                    child: Text(
                      bunksAvailable >= 0
                          ? 'You can bunk $bunksAvailable more class${bunksAvailable != 1 ? 'es' : ''}'
                          : 'Attend ${-bunksAvailable} more class${-bunksAvailable != 1 ? 'es' : ''} to reach ${widget.subject.minAttendance}%',
                      style: const TextStyle(
                        color: UIConstants.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: UIConstants.spacingL),

            // Subject Info
            Text(
              'Subject Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: UIConstants.primaryText,
                  ),
            ),

            const SizedBox(height: UIConstants.spacingM),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UIConstants.spacingL),
              decoration: BoxDecoration(
                color: UIConstants.cardBlue,
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
                border: Border.all(
                  color: UIConstants.cardBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Type', widget.subject.type),
                  const SizedBox(height: UIConstants.spacingM),
                  _buildDetailRow(
                      'Minimum Attendance', '${widget.subject.minAttendance}%'),
                  const SizedBox(height: UIConstants.spacingM),
                  _buildDetailRow(
                      'Calculation',
                      widget.subject.isMonthlyCalculation
                          ? 'Monthly'
                          : 'Cumulative'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: UIConstants.fontXXL,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: UIConstants.spacingXS),
        Text(
          label,
          style: const TextStyle(
            fontSize: UIConstants.fontS,
            color: UIConstants.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: UIConstants.secondaryText,
            fontSize: UIConstants.fontM,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: UIConstants.primaryText,
            fontSize: UIConstants.fontM,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}