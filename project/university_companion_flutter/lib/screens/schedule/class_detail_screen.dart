/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/class.dart';
import 'package:university_companion/providers/schedule_provider.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';

class ClassDetailScreen extends ConsumerWidget {
  final Class classItem;

  const ClassDetailScreen({
    Key? key,
    required this.classItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsByCourseProvider(classItem.courseCode));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(classItem.courseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem.courseCode,
                      style: TextStyle(
                        color: _getClassColor(classItem.courseCode),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      classItem.courseName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.person, 'Instructor', classItem.instructor),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, 'Location', '${classItem.building}, Room ${classItem.roomNumber}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, 'Time', '${classItem.startTime} - ${classItem.endTime}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, 'Days', classItem.days.join(', ')),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Class Description
            Text(
              'Course Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(classItem.description),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Prerequisites
            if (classItem.prerequisites.isNotEmpty) ...[
              Text(
                'Prerequisites',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: classItem.prerequisites.map((prerequisite) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16),
                            const SizedBox(width: 8),
                            Text(prerequisite),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Assignments
            Text(
              'Assignments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            assignmentsAsync.when(
              data: (assignments) {
                if (assignments.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('No assignments for this course yet'),
                      ),
                    ),
                  );
                }
                
                return Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: assignments.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      final isOverdue = assignment.dueDate.isBefore(DateTime.now()) && !assignment.isCompleted;
                      
                      return ListTile(
                        title: Text(
                          assignment.title,
                          style: TextStyle(
                            decoration: assignment.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          'Due: ${_formatDate(assignment.dueDate)}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : null,
                          ),
                        ),
                        trailing: Checkbox(
                          value: assignment.isCompleted,
                          onChanged: (value) {
                            // TODO: Update assignment completion status
                          },
                        ),
                        onTap: () {
                          // TODO: Show assignment details
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingView(),
              error: (error, stackTrace) => ErrorView(
                message: 'Failed to load assignments',
                onRetry: () => ref.refresh(assignmentsByCourseProvider(classItem.courseCode)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add reminder or note
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(value),
          ],
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else {
      return '${date.month}/${date.day}/${date.year}, ${_formatTime(date)}';
    }
  }
  
  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
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
}*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/class.dart';
import 'package:university_companion/providers/schedule_provider.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';

class ClassDetailScreen extends ConsumerWidget {
  final Class classItem;

  const ClassDetailScreen({
    Key? key,
    required this.classItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsByCourseProvider(classItem.courseCode));

    return Scaffold(
      appBar: AppBar(
        title: Text(classItem.courseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassInfoCard(classItem, context),

            const SizedBox(height: 24),

            _buildSectionTitle(context, 'Course Description'),
            _buildCardContent(classItem.description),

            const SizedBox(height: 24),

            if (classItem.prerequisites.isNotEmpty) _buildPrerequisitesSection(classItem.prerequisites),

            const SizedBox(height: 24),

            _buildSectionTitle(context, 'Assignments'),
            _buildAssignmentsSection(assignmentsAsync as AsyncValue<List<Assignment>>, ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add reminder or note
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClassInfoCard(Class classItem, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classItem.courseCode,
              style: TextStyle(
                color: _getClassColor(classItem.courseCode),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              classItem.courseName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Instructor', classItem.instructor),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Location', '${classItem.building}, Room ${classItem.roomNumber}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Time', '${classItem.startTime} - ${classItem.endTime}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Days', classItem.days.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildCardContent(String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(content),
      ),
    );
  }

  Widget _buildPrerequisitesSection(List<String> prerequisites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prerequisites',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: prerequisites.map((prerequisite) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 8),
                      Text(prerequisite),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsSection(AsyncValue<List<Assignment>> assignmentsAsync, WidgetRef ref) {
    return assignmentsAsync.when(
      data: (assignments) {
        if (assignments.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No assignments for this course yet')),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignments.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              final isOverdue = assignment.dueDate.isBefore(DateTime.now()) && !assignment.isCompleted;

              return ListTile(
                title: Text(
                  assignment.title,
                  style: TextStyle(
                    decoration: assignment.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  'Due: ${_formatDate(assignment.dueDate)}',
                  style: TextStyle(color: isOverdue ? Colors.red : null),
                ),
                trailing: Checkbox(
                  value: assignment.isCompleted,
                  onChanged: (value) {
                    // TODO: Update assignment completion status
                  },
                ),
                onTap: () {
                  // TODO: Show assignment details
                },
              );
            },
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorView(
        message: 'Failed to load assignments',
        onRetry: () => ref.refresh(assignmentsByCourseProvider(classItem.courseCode)),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(value),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else {
      return '${date.month}/${date.day}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Color _getClassColor(String courseCode) {
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
