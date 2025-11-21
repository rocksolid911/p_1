import '../entities/medicine.dart';

/// Repository interface for native alarm operations
abstract class AlarmRepository {
  /// Schedule a reminder alarm for a medicine
  Future<void> scheduleAlarm({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required DateTime scheduledTime,
    String? notes,
  });

  /// Schedule all alarms for a medicine based on its schedule
  Future<void> scheduleMedicineAlarms(Medicine medicine);

  /// Cancel a specific alarm
  Future<void> cancelAlarm(String medicineId, DateTime scheduledTime);

  /// Cancel all alarms for a medicine
  Future<void> cancelMedicineAlarms(String medicineId);

  /// Cancel all alarms
  Future<void> cancelAllAlarms();

  /// Reschedule all alarms (e.g., after device reboot)
  Future<void> rescheduleAllAlarms(List<Medicine> medicines);

  /// Check if alarm permissions are granted
  Future<bool> hasAlarmPermissions();

  /// Request alarm permissions
  Future<bool> requestAlarmPermissions();
}
