/// Domain entity representing a user
class User {
  final String uid;
  final String email;
  final String? name;
  final int? age;
  final String? timezone;
  final String? medicalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.uid,
    required this.email,
    this.name,
    this.age,
    this.timezone,
    this.medicalNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? uid,
    String? email,
    String? name,
    int? age,
    String? timezone,
    String? medicalNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      timezone: timezone ?? this.timezone,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
