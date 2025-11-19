import 'dart:convert';
import '../../../domain/entities/medicine.dart';

/// Local database model for Medicine
class MedicineLocalModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String form;
  final String scheduleType;
  final String times; // JSON string
  final int? intervalHours;
  final String? daysOfWeek; // JSON string
  final int startDate; // Unix timestamp
  final int? endDate; // Unix timestamp
  final String? notes;
  final int isActive; // 1 or 0
  final int createdAt; // Unix timestamp
  final int updatedAt; // Unix timestamp
  final int syncStatus; // 0 = not synced, 1 = synced

  const MedicineLocalModel({
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
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 0,
  });

  /// Convert from domain entity to local model
  factory MedicineLocalModel.fromEntity(Medicine medicine) {
    return MedicineLocalModel(
      id: medicine.id,
      userId: medicine.userId,
      name: medicine.name,
      dosage: medicine.dosage,
      form: medicine.form.name,
      scheduleType: medicine.scheduleType.name,
      times: jsonEncode(
        medicine.times.map((t) => t.millisecondsSinceEpoch).toList(),
      ),
      intervalHours: medicine.intervalHours,
      daysOfWeek: medicine.daysOfWeek != null
          ? jsonEncode(medicine.daysOfWeek)
          : null,
      startDate: medicine.startDate.millisecondsSinceEpoch,
      endDate: medicine.endDate?.millisecondsSinceEpoch,
      notes: medicine.notes,
      isActive: medicine.isActive ? 1 : 0,
      createdAt: medicine.createdAt.millisecondsSinceEpoch,
      updatedAt: medicine.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Convert from local model to domain entity
  Medicine toEntity() {
    final List<dynamic> timesJson = jsonDecode(times);
    final times = timesJson
        .map((t) => DateTime.fromMillisecondsSinceEpoch(t as int))
        .toList();

    List<int>? daysOfWeekList;
    if (daysOfWeek != null) {
      final List<dynamic> daysJson = jsonDecode(daysOfWeek!);
      daysOfWeekList = daysJson.map((d) => d as int).toList();
    }

    return Medicine(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      form: MedicineForm.values.firstWhere((e) => e.name == form),
      scheduleType: ScheduleType.values.firstWhere((e) => e.name == scheduleType),
      times: times,
      intervalHours: intervalHours,
      daysOfWeek: daysOfWeekList,
      startDate: DateTime.fromMillisecondsSinceEpoch(startDate),
      endDate: endDate != null
          ? DateTime.fromMillisecondsSinceEpoch(endDate!)
          : null,
      notes: notes,
      isActive: isActive == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  /// Convert from database map
  factory MedicineLocalModel.fromMap(Map<String, dynamic> map) {
    return MedicineLocalModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      form: map['form'] as String,
      scheduleType: map['scheduleType'] as String,
      times: map['times'] as String,
      intervalHours: map['intervalHours'] as int?,
      daysOfWeek: map['daysOfWeek'] as String?,
      startDate: map['startDate'] as int,
      endDate: map['endDate'] as int?,
      notes: map['notes'] as String?,
      isActive: map['isActive'] as int,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      syncStatus: map['syncStatus'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'form': form,
      'scheduleType': scheduleType,
      'times': times,
      'intervalHours': intervalHours,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'syncStatus': syncStatus,
    };
  }
}
