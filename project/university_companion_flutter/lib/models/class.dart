class Class {
  final String id;
  final String courseCode;
  final String courseName;
  final String instructor;
  final String location;
  final List<String> days;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String building;
  final String description;
  final List<String> prerequisites;

  Class({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.instructor,
    required this.location,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    required this.building,
    required this.description,
    required this.prerequisites,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      instructor: json['instructor'],
      location: json['location'],
      days: List<String>.from(json['days']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      roomNumber: json['roomNumber'],
      building: json['building'],
      description: json['description'],
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'instructor': instructor,
      'location': location,
      'days': days,
      'startTime': startTime,
      'endTime': endTime,
      'roomNumber': roomNumber,
      'building': building,
      'description': description,
      'prerequisites': prerequisites,
    };
  }
}

class Assignment {
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final DateTime dueDate;
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.dueDate,
    required this.isCompleted,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseCode: json['courseCode'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseCode': courseCode,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}

class Faculty {
  final String id;
  final String name;
  final String department;
  final String email;
  final String phone;
  final String office;
  final String imageUrl;
  final String bio;
  final List<String> officeHours;
  final List<String> courses;

  Faculty({
    required this.id,
    required this.name,
    required this.department,
    required this.email,
    required this.phone,
    required this.office,
    required this.imageUrl,
    required this.bio,
    required this.officeHours,
    required this.courses,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      email: json['email'],
      phone: json['phone'],
      office: json['office'],
      imageUrl: json['imageUrl'],
      bio: json['bio'],
      officeHours: List<String>.from(json['officeHours']),
      courses: List<String>.from(json['courses']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'email': email,
      'phone': phone,
      'office': office,
      'imageUrl': imageUrl,
      'bio': bio,
      'officeHours': officeHours,
      'courses': courses,
    };
  }
}