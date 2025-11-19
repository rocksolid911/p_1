import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/reminder_log.dart';

/// Firestore data model for ReminderLog
class ReminderLogModel {
  final String id;
  final String userId;
  final String medicineId;
  final Timestamp scheduledTime;
  final Timestamp? actualTakenTime;
  final String status;
  final String? notes;
  final Timestamp createdAt;

  const ReminderLogModel({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.scheduledTime,
    this.actualTakenTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  /// Convert from domain entity to Firestore model
  factory ReminderLogModel.fromEntity(ReminderLog log) {
    return ReminderLogModel(
      id: log.id,
      userId: log.userId,
      medicineId: log.medicineId,
      scheduledTime: Timestamp.fromDate(log.scheduledTime),
      actualTakenTime: log.actualTakenTime != null
          ? Timestamp.fromDate(log.actualTakenTime!)
          : null,
      status: log.status.name,
      notes: log.notes,
      createdAt: Timestamp.fromDate(log.createdAt),
    );
  }

  /// Convert from Firestore model to domain entity
  ReminderLog toEntity() {
    return ReminderLog(
      id: id,
      userId: userId,
      medicineId: medicineId,
      scheduledTime: scheduledTime.toDate(),
      actualTakenTime: actualTakenTime?.toDate(),
      status: ReminderStatus.values.firstWhere((e) => e.name == status),
      notes: notes,
      createdAt: createdAt.toDate(),
    );
  }

  /// Convert from Firestore document snapshot
  factory ReminderLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReminderLogModel(
      id: doc.id,
      userId: data['userId'] as String,
      medicineId: data['medicineId'] as String,
      scheduledTime: data['scheduledTime'] as Timestamp,
      actualTakenTime: data['actualTakenTime'] as Timestamp?,
      status: data['status'] as String,
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'medicineId': medicineId,
      'scheduledTime': scheduledTime,
      'actualTakenTime': actualTakenTime,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}
