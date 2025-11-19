import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/medicine.dart';

/// Firestore data model for Medicine
class MedicineModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String form;
  final String scheduleType;
  final List<String> times; // Store as ISO8601 time strings (e.g., "08:00:00")
  final int? intervalHours;
  final List<int>? daysOfWeek;
  final Timestamp startDate;
  final Timestamp? endDate;
  final String? notes;
  final bool isActive;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const MedicineModel({
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
  });

  /// Convert from domain entity to Firestore model
  factory MedicineModel.fromEntity(Medicine medicine) {
    return MedicineModel(
      id: medicine.id,
      userId: medicine.userId,
      name: medicine.name,
      dosage: medicine.dosage,
      form: medicine.form.name,
      scheduleType: medicine.scheduleType.name,
      times: medicine.times.map((t) => _timeToString(t)).toList(),
      intervalHours: medicine.intervalHours,
      daysOfWeek: medicine.daysOfWeek,
      startDate: Timestamp.fromDate(medicine.startDate),
      endDate: medicine.endDate != null
          ? Timestamp.fromDate(medicine.endDate!)
          : null,
      notes: medicine.notes,
      isActive: medicine.isActive,
      createdAt: Timestamp.fromDate(medicine.createdAt),
      updatedAt: Timestamp.fromDate(medicine.updatedAt),
    );
  }

  /// Convert from Firestore model to domain entity
  Medicine toEntity() {
    return Medicine(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      form: MedicineForm.values.firstWhere((e) => e.name == form),
      scheduleType: ScheduleType.values.firstWhere((e) => e.name == scheduleType),
      times: times.map((t) => _stringToTime(t)).toList(),
      intervalHours: intervalHours,
      daysOfWeek: daysOfWeek,
      startDate: startDate.toDate(),
      endDate: endDate?.toDate(),
      notes: notes,
      isActive: isActive,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }

  /// Convert from Firestore document snapshot
  factory MedicineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicineModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      dosage: data['dosage'] as String,
      form: data['form'] as String,
      scheduleType: data['scheduleType'] as String,
      times: (data['times'] as List<dynamic>).map((e) => e as String).toList(),
      intervalHours: data['intervalHours'] as int?,
      daysOfWeek: data['daysOfWeek'] != null
          ? (data['daysOfWeek'] as List<dynamic>).map((e) => e as int).toList()
          : null,
      startDate: data['startDate'] as Timestamp,
      endDate: data['endDate'] as Timestamp?,
      notes: data['notes'] as String?,
      isActive: data['isActive'] as bool,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
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
    };
  }

  /// Convert DateTime to time string (HH:mm:ss)
  static String _timeToString(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Convert time string to DateTime (today with specified time)
  static DateTime _stringToTime(String timeString) {
    final parts = timeString.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }
}
