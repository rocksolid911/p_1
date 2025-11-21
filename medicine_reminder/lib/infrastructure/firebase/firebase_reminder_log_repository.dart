import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reminder_log.dart';
import '../../domain/repositories/reminder_log_repository.dart';
import 'models/reminder_log_model.dart';

/// Firebase implementation of ReminderLogRepository
class FirebaseReminderLogRepository implements ReminderLogRepository {
  final FirebaseFirestore _firestore;

  FirebaseReminderLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getLogsCollection(String userId) {
    return _firestore.collection('reminder_logs').doc(userId).collection('logs');
  }

  @override
  Future<ReminderLog> addLog(ReminderLog log) async {
    try {
      final model = ReminderLogModel.fromEntity(log);
      final docRef = _getLogsCollection(log.userId).doc(log.id);
      await docRef.set(model.toFirestore());
      return log;
    } catch (e) {
      throw Exception('Failed to add log: $e');
    }
  }

  @override
  Future<List<ReminderLog>> getLogsForMedicine(
    String userId,
    String medicineId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _getLogsCollection(userId)
          .where('medicineId', isEqualTo: medicineId);

      if (startDate != null) {
        query = query.where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('scheduledTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReminderLogModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get logs for medicine: $e');
    }
  }

  @override
  Future<List<ReminderLog>> getLogsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _getLogsCollection(userId)
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('scheduledTime',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return snapshot.docs
          .map((doc) => ReminderLogModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get logs for date range: $e');
    }
  }

  @override
  Future<List<ReminderLog>> getLogsForDay(String userId, DateTime day) async {
    try {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

      return getLogsForDateRange(userId, startOfDay, endOfDay);
    } catch (e) {
      throw Exception('Failed to get logs for day: $e');
    }
  }

  @override
  Future<double> calculateAdherence(
    String userId,
    String medicineId,
    int days,
  ) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final logs = await getLogsForMedicine(
        userId,
        medicineId,
        startDate: startDate,
        endDate: endDate,
      );

      if (logs.isEmpty) return 0.0;

      final takenCount = logs.where((log) => log.status == ReminderStatus.taken).length;
      return (takenCount / logs.length) * 100;
    } catch (e) {
      throw Exception('Failed to calculate adherence: $e');
    }
  }

  @override
  Future<void> updateLog(ReminderLog log) async {
    try {
      final model = ReminderLogModel.fromEntity(log);
      await _getLogsCollection(log.userId)
          .doc(log.id)
          .update(model.toFirestore());
    } catch (e) {
      throw Exception('Failed to update log: $e');
    }
  }

  @override
  Stream<List<ReminderLog>> watchLogs(String userId) {
    return _getLogsCollection(userId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReminderLogModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<void> syncLogs(String userId) async {
    // Sync is automatic with Firestore real-time listeners
    // This method can be used for manual sync if needed
    try {
      await _getLogsCollection(userId).get();
    } catch (e) {
      throw Exception('Failed to sync logs: $e');
    }
  }
}
