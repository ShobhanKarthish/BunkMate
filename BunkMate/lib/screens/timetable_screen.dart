import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../models/subject.dart';
import '../services/attendance_service.dart';
import '../widgets/subject_card.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDay = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
  late Box<Subject> _subjectsBox;

  @override
  void initState() {
    super.initState();
    _subjectsBox = Hive.box<Subject>(AppConstants.subjectsBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Selection Row
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final dayIndex = index + 1; // 1 = Monday, 7 = Sunday
                final dayName = AppConstants.daysOfWeek[index];
                final isSelected = _selectedDay == dayIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = dayIndex;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? UIConstants.primaryAccent 
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dayName[0], // First letter of the day
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : UIConstants.secondaryText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: UIConstants.fontL,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: UIConstants.spacingL),
          
          // Timetable for selected day
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _subjectsBox.listenable(),
              builder: (context, Box<Subject> box, _) {
                final subjectsForDay = AttendanceService.getSubjectsForDay(_selectedDay);
                
                if (subjectsForDay.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                // Sort subjects by time
                subjectsForDay.sort((a, b) {
                  final timeA = _getEarliestTime(a);
                  final timeB = _getEarliestTime(b);
                  return timeA.compareTo(timeB);
                });
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingL,
                  ),
                  itemCount: subjectsForDay.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == subjectsForDay.length - 1
                            ? UIConstants.spacingXXL
                            : UIConstants.spacingM,
                      ),
                      child: SubjectCard(
                        subject: subjectsForDay[index],
                        onAttendanceMarked: () => setState(() {}),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getEarliestTime(Subject subject) {
    final scheduleItems = subject.schedule.where((s) => s.dayOfWeek == _selectedDay).toList();
    if (scheduleItems.isEmpty) return '23:59'; // Put subjects without schedule at the end
    
    // Sort by time and return the earliest
    scheduleItems.sort((a, b) => a.time.compareTo(b.time));
    return scheduleItems.first.time;
  }

  Widget _buildEmptyState(BuildContext context) {
    final dayName = AppConstants.daysOfWeek[_selectedDay - 1];
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingXL),
              decoration: const BoxDecoration(
                color: UIConstants.cardBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_outlined,
                size: UIConstants.iconXL,
                color: UIConstants.primaryText,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            Text(
              'No classes on $dayName!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: UIConstants.primaryText,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              'Enjoy your day off!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UIConstants.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
