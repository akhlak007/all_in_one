class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imageUrl;
  final String category;
  final String organizer;
  final bool requiresRegistration;
  final int capacity;
  final int registeredCount;
  final List<String> tags;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.category,
    required this.organizer,
    required this.requiresRegistration,
    required this.capacity,
    required this.registeredCount,
    required this.tags,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      organizer: json['organizer'],
      requiresRegistration: json['requiresRegistration'],
      capacity: json['capacity'],
      registeredCount: json['registeredCount'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'category': category,
      'organizer': organizer,
      'requiresRegistration': requiresRegistration,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'tags': tags,
    };
  }
}

class Club {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final String president;
  final String email;
  final String meetingSchedule;
  final String location;
  final List<String> socialMedia;
  final int memberCount;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.president,
    required this.email,
    required this.meetingSchedule,
    required this.location,
    required this.socialMedia,
    required this.memberCount,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      president: json['president'],
      email: json['email'],
      meetingSchedule: json['meetingSchedule'],
      location: json['location'],
      socialMedia: List<String>.from(json['socialMedia']),
      memberCount: json['memberCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'president': president,
      'email': email,
      'meetingSchedule': meetingSchedule,
      'location': location,
      'socialMedia': socialMedia,
      'memberCount': memberCount,
    };
  }
}