import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/class.dart';
import 'package:university_companion/providers/schedule_provider.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';

class FacultyListScreen extends ConsumerWidget {
  const FacultyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultyAsync = ref.watch(facultyProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Directory'),
      ),
      body: facultyAsync.when(
        data: (faculty) {
          if (faculty.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No faculty members found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          
          // Group faculty by department
          final Map<String, List<Faculty>> facultyByDepartment = {};
          
          for (final member in faculty) {
            if (!facultyByDepartment.containsKey(member.department)) {
              facultyByDepartment[member.department] = [];
            }
            
            facultyByDepartment[member.department]!.add(member);
          }
          
          // Sort departments alphabetically
          final departments = facultyByDepartment.keys.toList()..sort();
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final department = departments[index];
              final departmentFaculty = facultyByDepartment[department]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      department,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...departmentFaculty.map((member) => _buildFacultyCard(context, member)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorView(
          message: 'Failed to load faculty directory',
          onRetry: () => ref.refresh(facultyProvider),
        ),
      ),
    );
  }
  
  Widget _buildFacultyCard(BuildContext context, Faculty member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to faculty detail screen
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Faculty Image
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(member.imageUrl),
                onBackgroundImageError: (_, __) {},
                child: member.imageUrl.isEmpty
                    ? Text(
                        member.name.substring(0, 1),
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Faculty Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.department,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16),
                        const SizedBox(width: 4),
                        Text(member.email),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text('Office: ${member.office}'),
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
  }
}