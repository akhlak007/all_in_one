class Building {
  final String id;
  final String name;
  final String description;
  final String type;
  final double latitude;
  final double longitude;
  final String openingHours;
  final List<String> facilities;
  final List<String> departments;
  final String imageUrl;
  final int floors;
  final Map<String, dynamic> floorMap;

  Building({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
    required this.facilities,
    required this.departments,
    required this.imageUrl,
    required this.floors,
    required this.floorMap,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      openingHours: json['openingHours'],
      facilities: List<String>.from(json['facilities']),
      departments: List<String>.from(json['departments']),
      imageUrl: json['imageUrl'],
      floors: json['floors'],
      floorMap: json['floorMap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'openingHours': openingHours,
      'facilities': facilities,
      'departments': departments,
      'imageUrl': imageUrl,
      'floors': floors,
      'floorMap': floorMap,
    };
  }
}