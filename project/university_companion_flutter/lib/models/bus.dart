class BusStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String arrivalTime;

  BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.arrivalTime,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      arrivalTime: json['arrivalTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'arrivalTime': arrivalTime,
    };
  }
}

class Bus {
  final String id;
  final String busNumber;
  final String routeName;
  final double latitude;
  final double longitude;
  final String nextStop;
  final String estimatedArrival;
  final bool isDelayed;
  final List<BusStop> routeStops;

  Bus({
    required this.id,
    required this.busNumber,
    required this.routeName,
    required this.latitude,
    required this.longitude,
    required this.nextStop,
    required this.estimatedArrival,
    required this.isDelayed,
    required this.routeStops,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      busNumber: json['busNumber'],
      routeName: json['routeName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      nextStop: json['nextStop'],
      estimatedArrival: json['estimatedArrival'],
      isDelayed: json['isDelayed'],
      routeStops: (json['routeStops'] as List)
          .map((stop) => BusStop.fromJson(stop))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'routeName': routeName,
      'latitude': latitude,
      'longitude': longitude,
      'nextStop': nextStop,
      'estimatedArrival': estimatedArrival,
      'isDelayed': isDelayed,
      'routeStops': routeStops.map((stop) => stop.toJson()).toList(),
    };
  }
}