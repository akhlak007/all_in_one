import 'package:flutter/material.dart';
import 'package:university_companion/models/building.dart';
import 'dart:math' as math;

class ARService {
  Future<bool> isARAvailable() async {
    try {
      // Simulated AR availability check
      // In a real app, this would check for ARCore/ARKit availability
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getARNavigationData({
    required Building building,
    required double userLatitude,
    required double userLongitude,
  }) async {
    // Calculate distance and direction to building
    final distance = _calculateDistance(
      userLatitude, userLongitude,
      building.latitude, building.longitude,
    );
    
    final bearing = _calculateBearing(
      userLatitude, userLongitude,
      building.latitude, building.longitude,
    );
    
    // Prepare AR navigation data
    return {
      'buildingId': building.id,
      'buildingName': building.name,
      'distance': distance,
      'bearing': bearing,
      'latitude': building.latitude,
      'longitude': building.longitude,
      'floorMap': building.floorMap,
    };
  }
  
  double _calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    // Haversine formula to calculate distance between two points
    const R = 6371e3; // Earth radius in meters
    final phi1 = lat1 * (math.pi / 180);
    final phi2 = lat2 * (math.pi / 180);
    final deltaPhi = (lat2 - lat1) * (math.pi / 180);
    final deltaLambda = (lon2 - lon1) * (math.pi / 180);
    
    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
              math.cos(phi1) * math.cos(phi2) *
              math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return R * c; // Distance in meters
  }
  
  double _calculateBearing(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    // Calculate initial bearing between two points
    final phi1 = lat1 * (math.pi / 180);
    final phi2 = lat2 * (math.pi / 180);
    final lambda1 = lon1 * (math.pi / 180);
    final lambda2 = lon2 * (math.pi / 180);
    
    final y = math.sin(lambda2 - lambda1) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
              math.sin(phi1) * math.cos(phi2) * math.cos(lambda2 - lambda1);
    
    final bearing = math.atan2(y, x) * (180 / math.pi);
    return (bearing + 360) % 360; // Normalize to 0-360
  }
}