import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'models/subject.dart';
import 'models/schedule_item.dart';
import 'models/attendance_record.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(ScheduleItemAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());

  // Open boxes
  await Hive.openBox<Subject>(AppConstants.subjectsBox);
  await Hive.openBox<AttendanceRecord>(AppConstants.attendanceBox);

  runApp(const BunkMateApp());
}

class BunkMateApp extends StatelessWidget {
  const BunkMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
