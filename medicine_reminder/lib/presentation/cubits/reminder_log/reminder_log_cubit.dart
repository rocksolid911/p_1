import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/reminder_log.dart';
import '../../../domain/repositories/reminder_log_repository.dart';
import 'reminder_log_state.dart';
import 'dart:async';

class ReminderLogCubit extends Cubit<ReminderLogState> {
  final ReminderLogRepository _reminderLogRepository;
  StreamSubscription? _logsSubscription;

  ReminderLogCubit(this._reminderLogRepository)
      : super(const ReminderLogInitial());

  Future<void> addLog(ReminderLog log, String userId) async {
    try {
      emit(const ReminderLogLoading());
      await _reminderLogRepository.addLog(log);
      final logs = await _reminderLogRepository.getLogsForDay(
        userId,
        DateTime.now(),
      );
      emit(ReminderLogOperationSuccess('Log added successfully', logs));
    } catch (e) {
      emit(ReminderLogError(e.toString()));
    }
  }

  Future<void> loadLogsForMedicine(
    String userId,
    String medicineId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(const ReminderLogLoading());
    try {
      final logs = await _reminderLogRepository.getLogsForMedicine(
        userId,
        medicineId,
        startDate: startDate,
        endDate: endDate,
      );
      emit(ReminderLogLoaded(logs));
    } catch (e) {
      emit(ReminderLogError(e.toString()));
    }
  }

  Future<void> loadLogsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    emit(const ReminderLogLoading());
    try {
      final logs = await _reminderLogRepository.getLogsForDateRange(
        userId,
        startDate,
        endDate,
      );
      emit(ReminderLogLoaded(logs));
    } catch (e) {
      emit(ReminderLogError(e.toString()));
    }
  }

  Future<void> loadLogsForDay(String userId, DateTime day) async {
    emit(const ReminderLogLoading());
    try {
      final logs = await _reminderLogRepository.getLogsForDay(userId, day);
      emit(ReminderLogLoaded(logs));
    } catch (e) {
      emit(ReminderLogError(e.toString()));
    }
  }

  void watchLogs(String userId) {
    _logsSubscription?.cancel();
    _logsSubscription = _reminderLogRepository.watchLogs(userId).listen(
      (logs) {
        emit(ReminderLogLoaded(logs));
      },
      onError: (error) {
        emit(ReminderLogError(error.toString()));
      },
    );
  }

  Future<void> calculateAdherence(
    String userId,
    String medicineId,
    int days,
  ) async {
    try {
      final adherence = await _reminderLogRepository.calculateAdherence(
        userId,
        medicineId,
        days,
      );
      emit(ReminderLogAdherence(adherence));
    } catch (e) {
      emit(ReminderLogError(e.toString()));
    }
  }

  Future<void> updateLog(ReminderLog log, String userId) async {
    try {
      emit(const ReminderLogLoading());
      await _reminderLogRepository.updateLog(log);
      final logs = await _reminderLogRepository.getLogsForDay(
        userId,
        log.scheduledTime,
      );
      emit(ReminderLogOperationSuccess('Log updated successfully', logs));
    } catch (e) {
      emit(ReminderLogError(e.toString()));
    }
  }

  Future<void> syncLogs(String userId) async {
    try {
      await _reminderLogRepository.syncLogs(userId);
    } catch (e) {
      emit(ReminderLogError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    return super.close();
  }
}
