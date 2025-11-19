import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/user.dart';

/// Firestore data model for User
class UserModel {
  final String uid;
  final String email;
  final String? name;
  final int? age;
  final String? timezone;
  final String? medicalNotes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.age,
    this.timezone,
    this.medicalNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from domain entity to Firestore model
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.name,
      age: user.age,
      timezone: user.timezone,
      medicalNotes: user.medicalNotes,
      createdAt: Timestamp.fromDate(user.createdAt),
      updatedAt: Timestamp.fromDate(user.updatedAt),
    );
  }

  /// Convert from Firestore model to domain entity
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      name: name,
      age: age,
      timezone: timezone,
      medicalNotes: medicalNotes,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }

  /// Convert from Firestore document snapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      name: data['name'] as String?,
      age: data['age'] as int?,
      timezone: data['timezone'] as String?,
      medicalNotes: data['medicalNotes'] as String?,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'timezone': timezone,
      'medicalNotes': medicalNotes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
