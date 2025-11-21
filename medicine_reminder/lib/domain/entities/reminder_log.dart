/// Enum for reminder status
enum ReminderStatus {
  taken,
  skipped,
  missed;

  String get displayName {
    switch (this) {
      case ReminderStatus.taken:
        return 'Taken';
      case ReminderStatus.skipped:
        return 'Skipped';
      case ReminderStatus.missed:
        return 'Missed';
    }
  }
}

/// Domain entity representing a reminder log entry
class ReminderLog {
  final String id;
  final String userId;
  final String medicineId;
  final DateTime scheduledTime;
  final DateTime? actualTakenTime;
  final ReminderStatus status;
  final String? notes;
  final DateTime createdAt;

  const ReminderLog({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.scheduledTime,
    this.actualTakenTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  ReminderLog copyWith({
    String? id,
    String? userId,
    String? medicineId,
    DateTime? scheduledTime,
    DateTime? actualTakenTime,
    ReminderStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return ReminderLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicineId: medicineId ?? this.medicineId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTakenTime: actualTakenTime ?? this.actualTakenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
