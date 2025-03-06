import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:university_companion/models/bus.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cafeteria
  Future<QuerySnapshot> getMeals() {
    return _firestore.collection('meals').get();
  }
  
  // Bus Tracking
  Future<QuerySnapshot> getBuses() {
    return _firestore.collection('buses').get();
  }
  
  Stream<DocumentSnapshot> getBusLocationStream(String busId) {
    return _firestore.collection('buses').doc(busId).snapshots();
  }
  
  Future<void> cacheBusData(List<Bus> buses) async {
    final prefs = await SharedPreferences.getInstance();
    final busesJson = buses.map((bus) => bus.toJson()).toList();
    await prefs.setString('cached_buses', jsonEncode(busesJson));
    await prefs.setString('cached_buses_timestamp', DateTime.now().toIso8601String());
  }
  
  Future<List<Bus>> getCachedBusData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_buses');
    
    if (cachedData != null) {
      final List<dynamic> busesJson = jsonDecode(cachedData);
      return busesJson.map((json) => Bus.fromJson(json)).toList();
    }
    
    return [];
  }
  
  // Class Schedule
  Future<QuerySnapshot> getClasses() {
    final userId = _auth.currentUser?.uid;
    return _firestore.collection('classes')
        .where('studentIds', arrayContains: userId)
        .get();
  }
  
  Future<QuerySnapshot> getAssignments() {
    final userId = _auth.currentUser?.uid;
    return _firestore.collection('assignments')
        .where('studentId', isEqualTo: userId)
        .get();
  }
  
  Future<QuerySnapshot> getFaculty() {
    return _firestore.collection('faculty').get();
  }
  
  Future<DocumentSnapshot> getFacultyById(String id) {
    return _firestore.collection('faculty').doc(id).get();
  }
  
  // Events
  Future<QuerySnapshot> getEvents() {
    return _firestore.collection('events').get();
  }
  
  Future<QuerySnapshot> getClubs() {
    return _firestore.collection('clubs').get();
  }
  
  // Campus Map
  Future<QuerySnapshot> getBuildings() {
    return _firestore.collection('buildings').get();
  }
  
  Future<DocumentSnapshot> getBuildingById(String id) {
    return _firestore.collection('buildings').doc(id).get();
  }
  
  // User Preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    final userId = _auth.currentUser?.uid;
    
    if (userId != null) {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['preferences'] ?? {};
      }
    }
    
    return {};
  }
  
  // Orders
  Future<void> placeOrder(Map<String, dynamic> orderData) {
    final userId = _auth.currentUser?.uid;
    orderData['userId'] = userId;
    orderData['timestamp'] = FieldValue.serverTimestamp();
    
    return _firestore.collection('orders').add(orderData);
  }
  
  // Event RSVPs
  Future<void> rsvpToEvent(String eventId) {
    final userId = _auth.currentUser?.uid;
    
    return _firestore.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayUnion([userId]),
      'registeredCount': FieldValue.increment(1),
    });
  }
  
  // Club Memberships
  Future<void> joinClub(String clubId) {
    final userId = _auth.currentUser?.uid;
    
    return _firestore.collection('clubs').doc(clubId).update({
      'members': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(1),
    });
  }
}