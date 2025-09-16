import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/subject.dart';
import '../services/attendance_service.dart';
import '../widgets/progress_ring.dart';
import 'add_edit_subject_screen.dart';
import 'subject_detail_screen.dart';
import 'timetable_screen.dart';

class SubjectsListScreen extends StatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen>
    with TickerProviderStateMixin {
  late Box<Subject> subjectsBox;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    subjectsBox = Hive.box<Subject>(AppConstants.subjectsBox);
    _fadeController = AnimationController(
      duration: UIConstants.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimetableScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ValueListenableBuilder(
          valueListenable: subjectsBox.listenable(),
          builder: (context, Box<Subject> box, _) {
            final subjects = box.values.toList();

            if (subjects.isEmpty) {
              return _buildEmptyState(context);
            }

            return CustomScrollView(
              slivers: [
                // Stats Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.spacingL),
                    child: Container(
                      padding: const EdgeInsets.all(UIConstants.spacingL),
                      decoration: BoxDecoration(
                        color: UIConstants.cardOrange,
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusXL),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total Subjects',
                            '${subjects.length}',
                            UIConstants.primaryAccent,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color:
                                UIConstants.secondaryText.withOpacity(0.5),
                          ),
                          _buildStatItem(
                            'Above 75%',
                            '${_getSubjectsAboveThreshold(subjects)}',
                            AppTheme.attendanceGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Subjects List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingL),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == subjects.length - 1
                                ? UIConstants.spacingXXL
                                : UIConstants.spacingM,
                          ),
                          child: _buildSubjectCard(context, subjects[index]),
                        );
                      },
                      childCount: subjects.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: UIConstants.primaryAccent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditSubjectScreen(),
              ),
            );
          },
          backgroundColor: UIConstants.primaryAccent,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: UIConstants.iconM,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    final attendancePercentage =
        AttendanceService.calculateAttendancePercentage(subject.id);
    final breakdown = AttendanceService.getAttendanceBreakdown(subject.id);
    final bunksAvailable =
        AttendanceService.calculateBunksAvailable(subject.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(subject: subject),
          ),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            // Progress Ring
            ProgressRing(
              percentage: attendancePercentage,
              minRequired: subject.minAttendance,
              size: 56,
              strokeWidth: 4,
            ),

            const SizedBox(width: UIConstants.spacingL),

            // Subject Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Name & Type
                  Row(
                    children: [
                      Icon(
                        UIConstants.classTypeIcons[subject.type] ??
                            Icons.school_outlined,
                        color: UIConstants.primaryAccent,
                        size: UIConstants.iconS,
                      ),
                      const SizedBox(width: UIConstants.spacingS),
                      Expanded(
                        child: Text(
                          subject.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: UIConstants.primaryText,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConstants.spacingXS),

                  // Type & Min Attendance
                  Text(
                    '${subject.type} • Min: ${subject.minAttendance}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: UIConstants.secondaryText,
                          fontSize: UIConstants.fontS,
                        ),
                  ),

                  const SizedBox(height: UIConstants.spacingS),

                  // Attendance Stats
                  Row(
                    children: [
                      Text(
                        'Attended: ${breakdown['attended']} / ${breakdown['total']}',
                        style: const TextStyle(
                          color: UIConstants.secondaryText,
                          fontSize: UIConstants.fontS,
                        ),
                      ),
                      const Spacer(),
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
                          border: Border.all(
                            color: _getBunksStatusColor(bunksAvailable)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          bunksAvailable >= 0
                              ? '+$bunksAvailable'
                              : '$bunksAvailable',
                          style: TextStyle(
                            fontSize: UIConstants.fontXS,
                            fontWeight: FontWeight.w600,
                            color: _getBunksStatusColor(bunksAvailable),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: UIConstants.spacingM),

            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: UIConstants.secondaryText,
              size: UIConstants.iconS,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingXL),
              decoration: const BoxDecoration(
                color: UIConstants.cardGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: UIConstants.iconXL,
                color: UIConstants.primaryText,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            Text(
              'No subjects yet!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: UIConstants.primaryText,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              'Add your first subject to start your journey.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UIConstants.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingL),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditSubjectScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: UIConstants.iconS),
              label: const Text('Add a Subject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryAccent,
                foregroundColor: UIConstants.primaryText,
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingL,
                  vertical: UIConstants.spacingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getSubjectsAboveThreshold(List<Subject> subjects) {
    return subjects.where((subject) {
      final percentage =
          AttendanceService.calculateAttendancePercentage(subject.id);
      return percentage >= 75.0;
    }).length;
  }

  Color _getBunksStatusColor(int bunksAvailable) {
    if (bunksAvailable >= 0) {
      return AppTheme.attendanceGreen;
    } else {
      return AppTheme.alertRed;
    }
  }
}