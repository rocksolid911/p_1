import '../entities/reminder_log.dart';

/// Repository interface for reminder log operations
abstract class ReminderLogRepository {
  /// Add a reminder log entry
  Future<ReminderLog> addLog(ReminderLog log);

  /// Get logs for a specific medicine
  Future<List<ReminderLog>> getLogsForMedicine(
    String userId,
    String medicineId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get all logs for a user within a date range
  Future<List<ReminderLog>> getLogsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get logs for a specific day
  Future<List<ReminderLog>> getLogsForDay(String userId, DateTime day);

  /// Calculate adherence percentage for a medicine
  Future<double> calculateAdherence(
    String userId,
    String medicineId,
    int days,
  );

  /// Update a log entry
  Future<void> updateLog(ReminderLog log);

  /// Stream of logs for a user
  Stream<List<ReminderLog>> watchLogs(String userId);

  /// Sync local logs with remote
  Future<void> syncLogs(String userId);
}
