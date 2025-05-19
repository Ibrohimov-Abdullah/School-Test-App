enum UserRole {
  student,
  teacher,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
          (role) => role.toString() == 'UserRole.$value',
      orElse: () => UserRole.student,
    );
  }
}

class User {
  String id;
  String name;
  String email;
  String? phoneNumber;
  String? photoUrl;
  UserRole role;
  String? schoolId;
  String? classId; // For students
  String? grade; // For students (e.g., "9th", "10th")
  List<String>? subjects; // For teachers
  DateTime createdAt;
  DateTime lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    this.schoolId,
    this.classId,
    this.grade,
    this.subjects,
    required this.createdAt,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: UserRoleExtension.fromString(json['role'] as String),
      schoolId: json['schoolId'] as String?,
      classId: json['classId'] as String?,
      grade: json['grade'] as String?,
      subjects: json['subjects'] != null ? List<String>.from(json['subjects']) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'schoolId': schoolId,
      'classId': classId,
      'grade': grade,
      'subjects': subjects,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
}