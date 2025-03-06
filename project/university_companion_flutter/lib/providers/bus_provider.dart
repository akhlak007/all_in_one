import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:university_companion/models/bus.dart';
import 'package:university_companion/services/firestore_service.dart';

final firestoreService = FirestoreService();

final connectivityProvider = FutureProvider<bool>((ref) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
});

final busesProvider = FutureProvider<List<Bus>>((ref) async {
  try {
    final isOnline = await ref.watch(connectivityProvider.future);
    
    if (isOnline) {
      // Get real-time data from Firebase
      final snapshot = await firestoreService.getBuses();
      final buses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Bus.fromJson({...data, 'id': doc.id});
      }).toList();
      
      // Cache the data for offline use
      await firestoreService.cacheBusData(buses);
      
      return buses;
    } else {
      // Use cached data when offline
      return await firestoreService.getCachedBusData();
    }
  } catch (e) {
    throw Exception('Failed to load bus data: $e');
  }
});

final routesProvider = Provider<List<String>>((ref) {
  return [
    'North Campus',
    'South Campus',
    'East Campus',
    'West Campus',
    'Downtown',
  ];
});

final busLocationStreamProvider = StreamProvider.family<Bus, String>((ref, busId) {
  return firestoreService.getBusLocationStream(busId).map((snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Bus.fromJson({...data, 'id': snapshot.id});
  });
});