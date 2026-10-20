class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.approved,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role; // 'student' | 'instructor' | 'admin'
  final bool approved;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';
  bool get isInstructor => role == 'instructor';
  bool get isStudent => role == 'student';

  factory UserProfile.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return UserProfile(
      id: documentId,
      name: (data['name'] as String?) ?? 'Learner',
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'student',
      approved: (data['approved'] as bool?) ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is DateTime
              ? data['createdAt'] as DateTime
              : DateTime.tryParse(data['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'approved': approved,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? role,
    bool? approved,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      approved: approved ?? this.approved,
      createdAt: createdAt,
    );
  }
}
