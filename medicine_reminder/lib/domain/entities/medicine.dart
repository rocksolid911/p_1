/// Enum for medicine form types
enum MedicineForm {
  tablet,
  capsule,
  syrup,
  injection,
  drops,
  inhaler,
  cream,
  ointment,
  other;

  String get displayName {
    switch (this) {
      case MedicineForm.tablet:
        return 'Tablet';
      case MedicineForm.capsule:
        return 'Capsule';
      case MedicineForm.syrup:
        return 'Syrup';
      case MedicineForm.injection:
        return 'Injection';
      case MedicineForm.drops:
        return 'Drops';
      case MedicineForm.inhaler:
        return 'Inhaler';
      case MedicineForm.cream:
        return 'Cream';
      case MedicineForm.ointment:
        return 'Ointment';
      case MedicineForm.other:
        return 'Other';
    }
  }
}

/// Enum for schedule types
enum ScheduleType {
  fixedTimes, // Specific times of day (e.g., 8:00, 14:00, 20:00)
  interval, // Every X hours
  weeklyDays; // Specific days of the week

  String get displayName {
    switch (this) {
      case ScheduleType.fixedTimes:
        return 'Fixed Times';
      case ScheduleType.interval:
        return 'Interval';
      case ScheduleType.weeklyDays:
        return 'Specific Days';
    }
  }
}

/// Enum for time of day
enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night;

  String get emoji {
    switch (this) {
      case TimeOfDay.morning:
        return '🌅';
      case TimeOfDay.afternoon:
        return '☀️';
      case TimeOfDay.evening:
        return '🌇';
      case TimeOfDay.night:
        return '🌙';
    }
  }

  String get displayName {
    switch (this) {
      case TimeOfDay.morning:
        return 'Morning';
      case TimeOfDay.afternoon:
        return 'Afternoon';
      case TimeOfDay.evening:
        return 'Evening';
      case TimeOfDay.night:
        return 'Night';
    }
  }
}

/// Domain entity representing a medicine
class Medicine {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final MedicineForm form;
  final ScheduleType scheduleType;
  final List<DateTime> times; // For fixed times schedule
  final int? intervalHours; // For interval-based schedule
  final List<int>? daysOfWeek; // For weekly schedule (1=Monday, 7=Sunday)
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes; // e.g., "with food", "after meals"
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.form,
    required this.scheduleType,
    required this.times,
    this.intervalHours,
    this.daysOfWeek,
    required this.startDate,
    this.endDate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Medicine copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    MedicineForm? form,
    ScheduleType? scheduleType,
    List<DateTime>? times,
    int? intervalHours,
    List<int>? daysOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      scheduleType: scheduleType ?? this.scheduleType,
      times: times ?? this.times,
      intervalHours: intervalHours ?? this.intervalHours,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
