import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../core/theme/app_theme.dart';
import '../services/attendance_service.dart';
import '../models/subject.dart';
import '../widgets/subject_card.dart';
import 'subjects_list_screen.dart';
import 'timetable_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    final todaysSubjects = AttendanceService.getTodaysSubjects();
    final today = DateTime.now();
    final dayName = AppConstants.daysOfWeek[today.weekday - 1];
    final dateStr = DateFormat('EEEE, MMM dd').format(today);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UIConstants.spacingL,
                    UIConstants.spacingL,
                    UIConstants.spacingL,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: UIConstants.primaryText,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              const SizedBox(height: UIConstants.spacingXS),
                              Text(
                                'Smart attendance tracking',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: UIConstants.secondaryText,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(UIConstants.radiusL),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.schedule_rounded,
                                    color: UIConstants.primaryText,
                                    size: UIConstants.iconM,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TimetableScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: UIConstants.spacingS),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(UIConstants.radiusL),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.list_rounded,
                                    color: UIConstants.primaryText,
                                    size: UIConstants.iconM,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SubjectsListScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: UIConstants.spacingXL),

                      // Date Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(UIConstants.spacingL),
                        decoration: BoxDecoration(
                          color: UIConstants.cardBlue,
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusXL),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(UIConstants.spacingM),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.circular(UIConstants.radiusL),
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: UIConstants.primaryText,
                                size: UIConstants.iconM,
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingM),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: UIConstants.primaryText,
                                      ),
                                ),
                                const SizedBox(height: UIConstants.spacingXS),
                                Text(
                                  dateStr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: UIConstants.secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Today's Classes Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UIConstants.spacingL,
                    UIConstants.spacingXL,
                    UIConstants.spacingL,
                    UIConstants.spacingM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Classes",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: UIConstants.primaryText,
                            ),
                      ),
                      if (todaysSubjects.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.spacingM,
                            vertical: UIConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: UIConstants.cardGreen,
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusL),
                          ),
                          child: Text(
                            '${todaysSubjects.length}',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: UIConstants.primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Classes List
              todaysSubjects.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState(context))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingL),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == todaysSubjects.length - 1
                                    ? UIConstants.spacingXXL
                                    : UIConstants.spacingM,
                              ),
                              child: SubjectCard(
                                subject: todaysSubjects[index],
                                onAttendanceMarked: () => setState(() {}),
                              ),
                            );
                          },
                          childCount: todaysSubjects.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
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
                builder: (context) => const SubjectsListScreen(),
              ),
            );
          },
          backgroundColor: UIConstants.primaryAccent,
          child: const Icon(
            Icons.add_rounded,
            color: UIConstants.primaryText,
            size: UIConstants.iconL,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: UIConstants.spacingXXL),
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingXL),
            decoration: const BoxDecoration(
              color: UIConstants.cardOrange,
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
            'No classes today! Hooray!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: UIConstants.primaryText,
                ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Enjoy your day off or add some subjects to get started.',
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
                  builder: (context) => const SubjectsListScreen(),
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
    );
  }
}