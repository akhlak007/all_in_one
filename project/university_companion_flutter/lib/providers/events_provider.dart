import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/event.dart';
import 'package:university_companion/services/firestore_service.dart';
import 'package:university_companion/services/ai_service.dart';

final firestoreService = FirestoreService();
final aiService = AIService();

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  try {
    final snapshot = await firestoreService.getEvents();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Event.fromJson({...data, 'id': doc.id});
    }).toList();
  } catch (e) {
    throw Exception('Failed to load events: $e');
  }
});

final eventCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'Academic',
    'Social',
    'Sports',
    'Career',
    'Workshop',
    'Conference',
  ];
});

final recommendedEventsProvider = FutureProvider<List<Event>>((ref) async {
  try {
    // Get user preferences from user profile
    final userPreferences = await firestoreService.getUserPreferences();
    
    // Get all events
    final eventsAsync = await ref.watch(eventsProvider.future);
    
    // Use AI service to recommend events based on user preferences
    final recommendedEvents = await aiService.getRecommendedEvents(
      events: eventsAsync,
      userPreferences: userPreferences,
    );
    
    return recommendedEvents;
  } catch (e) {
    // If recommendation fails, return upcoming events as fallback
    final eventsAsync = await ref.watch(eventsProvider.future);
    final now = DateTime.now();
    return eventsAsync
        .where((event) => event.date.isAfter(now))
        .take(5)
        .toList();
  }
});

final clubsProvider = FutureProvider<List<Club>>((ref) async {
  try {
    final snapshot = await firestoreService.getClubs();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Club.fromJson({...data, 'id': doc.id});
    }).toList();
  } catch (e) {
    throw Exception('Failed to load clubs: $e');
  }
});

final clubCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'Academic',
    'Cultural',
    'Sports',
    'Technology',
    'Arts',
    'Community Service',
    'Professional',
  ];
});

final clubsByCategory = Provider.family<List<Club>, String>((ref, category) {
  final clubsAsync = ref.watch(clubsProvider);
  return clubsAsync.when(
    data: (clubs) {
      if (category == 'All') {
        return clubs;
      }
      return clubs.where((club) => club.category == category).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});