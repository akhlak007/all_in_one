import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:university_companion/models/class.dart';
import 'package:university_companion/providers/schedule_provider.dart';
import 'package:university_companion/screens/schedule/class_detail_screen.dart';
import 'package:university_companion/screens/schedule/faculty_list_screen.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesProvider);
    final assignmentsAsync = ref.watch(assignmentsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Schedule'),
            Tab(text: 'Assignments'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FacultyListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Schedule Tab
          Column(
            children: [
              // Calendar
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                ),
              ),
              
              // Classes for selected day
              Expanded(
                child: classesAsync.when(
                  data: (classes) {
                    // Filter classes for the selected day
                    final dayClasses = classes.where((cls) {
                      final classDay = DateFormat('EEEE').format(_selectedDay).toLowerCase();
                      return cls.days.contains(classDay);
                    }).toList();
                    
                    if (dayClasses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No classes scheduled for ${DateFormat('EEEE, MMMM d').format(_selectedDay)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Sort classes by start time
                    dayClasses.sort((a, b) => a.startTime.compareTo(b.startTime));
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayClasses.length,
                      itemBuilder: (context, index) {
                        final cls = dayClasses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassDetailScreen(classItem: cls),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time Column
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _getClassColor(cls.courseCode).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getClassColor(cls.courseCode),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          cls.startTime,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _getClassColor(cls.courseCode),
                                          ),
                                        ),
                                        const Text('to'),
                                        Text(
                                          cls.endTime,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _getClassColor(cls.courseCode),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Class Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cls.courseName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cls.courseCode,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 16),
                                            const SizedBox(width: 4),
                                            Text(cls.location),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 16),
                                            const SizedBox(width: 4),
                                            Text(cls.instructor),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (error, stackTrace) => ErrorView(
                    message: 'Failed to load class schedule',
                    onRetry: () => ref.refresh(classesProvider),
                  ),
                ),
              ),
            ],
          ),
          
          // Assignments Tab
          assignmentsAsync.when(
            data: (assignments) {
              if (assignments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No assignments due',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Group assignments by due date
              final Map<String, List<dynamic>> groupedAssignments = {};
              
              for (final assignment in assignments) {
                final dueDate = DateFormat('MMMM d, yyyy').format(assignment.dueDate);
                
                if (!groupedAssignments.containsKey(dueDate)) {
                  groupedAssignments[dueDate] = [];
                }
                
                groupedAssignments[dueDate]!.add(assignment);
              }
              
              // Sort dates
              final sortedDates = groupedAssignments.keys.toList()
                ..sort((a, b) {
                  final dateA = DateFormat('MMMM d, yyyy').parse(a);
                  final dateB = DateFormat('MMMM d, yyyy').parse(b);
                  return dateA.compareTo(dateB);
                });
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedDates.length,
                itemBuilder: (context, dateIndex) {
                  final date = sortedDates[dateIndex];
                  final dateAssignments = groupedAssignments[date]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          date,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...dateAssignments.map((assignment) {
                        final isOverdue = assignment.dueDate.isBefore(DateTime.now());
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        assignment.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isOverdue)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Overdue',
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  assignment.courseCode,
                                  style: TextStyle(
                                    color: _getClassColor(assignment.courseCode),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(assignment.description),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Due: ${DateFormat('h:mm a').format(assignment.dueDate)}',
                                      style: TextStyle(
                                        color: isOverdue ? Colors.red : Colors.grey.shade600,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // TODO: Mark as completed
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        foregroundColor: Colors.black,
                                      ),
                                      child: const Text('Mark as Done'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              );
            },
            loading: () => const LoadingView(),
            error: (error, stackTrace) => ErrorView(
              message: 'Failed to load assignments',
              onRetry: () => ref.refresh(assignmentsProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add reminder or assignment
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Color _getClassColor(String courseCode) {
    // Generate a color based on the course code
    final colorMap = {
      'CS': Colors.blue,
      'MATH': Colors.red,
      'ENG': Colors.green,
      'PHYS': Colors.orange,
      'CHEM': Colors.purple,
      'BIO': Colors.teal,
    };
    
    for (final prefix in colorMap.keys) {
      if (courseCode.startsWith(prefix)) {
        return colorMap[prefix]!;
      }
    }
    
    return Colors.blue;
  }
}