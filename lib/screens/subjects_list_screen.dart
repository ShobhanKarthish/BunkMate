import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../models/subject.dart';
import '../services/attendance_service.dart';
import 'add_edit_subject_screen.dart';
import 'subject_detail_screen.dart';

class SubjectsListScreen extends StatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> {
  late Box<Subject> subjectsBox;

  @override
  void initState() {
    super.initState();
    subjectsBox = Hive.box<Subject>(AppConstants.subjectsBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Subjects'),
      ),
      body: ValueListenableBuilder(
        valueListenable: subjectsBox.listenable(),
        builder: (context, box, _) {
          final subjects = box.values.toList();

          if (subjects.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
                child: _buildSubjectListItem(context, subject),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditSubjectScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubjectListItem(BuildContext context, Subject subject) {
    final attendancePercentage =
        AttendanceService.calculateAttendancePercentage(subject.id);
    final breakdown = AttendanceService.getAttendanceBreakdown(subject.id);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            UIConstants.classTypeIcons[subject.type] ?? Icons.school,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${subject.type} • Min: ${subject.minAttendance}%'),
            const SizedBox(height: UIConstants.spacingXS),
            Text(
              'Attended: ${breakdown['attended']} / ${breakdown['total']}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: UIConstants.fontS,
              ),
            ),
          ],
        ),
        trailing: Container(
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: UIConstants.fontS,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectDetailScreen(subject: subject),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: UIConstants.spacingM),
          Text(
            'No subjects added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Add your first subject to start tracking attendance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            icon: const Icon(Icons.add),
            label: const Text('Add Subject'),
          ),
        ],
      ),
    );
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
