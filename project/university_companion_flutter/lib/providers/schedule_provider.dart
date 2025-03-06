import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/class.dart';
import 'package:university_companion/services/firestore_service.dart';

final firestoreService = FirestoreService();

final classesProvider = FutureProvider<List<Class>>((ref) async {
  try {
    final snapshot = await firestoreService.getClasses();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Class.fromJson({...data, 'id': doc.id});
    }).toList();
  } catch (e) {
    throw Exception('Failed to load classes: $e');
  }
});

final assignmentsProvider = FutureProvider<List<Assignment>>((ref) async {
  try {
    final snapshot = await firestoreService.getAssignments();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Assignment.fromJson({...data, 'id': doc.id});
    }).toList();
  } catch (e) {
    throw Exception('Failed to load assignments: $e');
  }
});

final facultyProvider = FutureProvider<List<Faculty>>((ref) async {
  try {
    final snapshot = await firestoreService.getFaculty();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Faculty.fromJson({...data, 'id': doc.id});
    }).toList();
  } catch (e) {
    throw Exception('Failed to load faculty: $e');
  }
});

final facultyByIdProvider = FutureProvider.family<Faculty, String>((ref, id) async {
  try {
    final doc = await firestoreService.getFacultyById(id);
    final data = doc.data() as Map<String, dynamic>;
    return Faculty.fromJson({...data, 'id': doc.id});
  } catch (e) {
    throw Exception('Failed to load faculty member: $e');
  }
});

final classesByDayProvider = Provider.family<List<Class>, String>((ref, day) {
  final classesAsync = ref.watch(classesProvider);
  return classesAsync.when(
    data: (classes) {
      return classes.where((cls) => cls.days.contains(day.toLowerCase())).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final assignmentsByCourseProvider = Provider.family<List<Assignment>, String>((ref, courseCode) {
  final assignmentsAsync = ref.watch(assignmentsProvider);
  return assignmentsAsync.when(
    data: (assignments) {
      return assignments.where((assignment) => assignment.courseCode == courseCode).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});