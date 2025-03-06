import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/building.dart';
import 'package:university_companion/services/firestore_service.dart';
import 'package:university_companion/services/ar_service.dart';

final firestoreService = FirestoreService();
final arService = ARService();

final buildingsProvider = FutureProvider<List<Building>>((ref) async {
  try {
    final snapshot = await firestoreService.getBuildings();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Building.fromJson({...data, 'id': doc.id});
    }).toList();
  } catch (e) {
    throw Exception('Failed to load buildings: $e');
  }
});

final buildingByIdProvider = FutureProvider.family<Building, String>((ref, id) async {
  try {
    final doc = await firestoreService.getBuildingById(id);
    final data = doc.data() as Map<String, dynamic>;
    return Building.fromJson({...data, 'id': doc.id});
  } catch (e) {
    throw Exception('Failed to load building: $e');
  }
});

final buildingsByTypeProvider = Provider.family<List<Building>, String>((ref, type) {
  final buildingsAsync = ref.watch(buildingsProvider);
  return buildingsAsync.when(
    data: (buildings) {
      if (type == 'All') {
        return buildings;
      }
      return buildings.where((building) => building.type == type).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final arAvailabilityProvider = FutureProvider<bool>((ref) async {
  return await arService.isARAvailable();
});

final arNavigationProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final Building? building = params['building'];
  final double? userLatitude = params['userLatitude'];
  final double? userLongitude = params['userLongitude'];
  
  if (building == null || userLatitude == null || userLongitude == null) {
    throw Exception('Missing required parameters for AR navigation');
  }
  
  return await arService.getARNavigationData(
    building: building,
    userLatitude: userLatitude,
    userLongitude: userLongitude,
  );
});