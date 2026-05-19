class Teacher {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String> subjects;
  final String? advisoryClass;
  final bool isSuspended;
  final String? warning;

  Teacher({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.subjects = const [],
    this.advisoryClass,
    this.isSuspended = false,
    this.warning,
  });

  factory Teacher.fromMap(Map<String, dynamic> map, String uid) {
    return Teacher(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? map['profile_image_url'] ?? map['photoURL'] ?? map['profilePhotoUrl'],
      subjects: (map['subjects'] as List?)?.map((e) => e.toString()).toList() ?? [],
      advisoryClass: map['advisoryClass']?.toString() ?? map['advisory_class']?.toString(),
      isSuspended: (map['is_suspended'] == true) || (map['isSuspended'] == true),
      warning: map['warning']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'subjects': subjects,
      'advisoryClass': advisoryClass,
      'is_suspended': isSuspended,
      'isSuspended': isSuspended,
      'warning': warning,
    };
  }
}
