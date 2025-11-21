import 'package:equatable/equatable.dart';
import '../../../domain/entities/reminder_log.dart';

abstract class ReminderLogState extends Equatable {
  const ReminderLogState();

  @override
  List<Object?> get props => [];
}

class ReminderLogInitial extends ReminderLogState {
  const ReminderLogInitial();
}

class ReminderLogLoading extends ReminderLogState {
  const ReminderLogLoading();
}

class ReminderLogLoaded extends ReminderLogState {
  final List<ReminderLog> logs;

  const ReminderLogLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class ReminderLogOperationSuccess extends ReminderLogState {
  final String message;
  final List<ReminderLog> logs;

  const ReminderLogOperationSuccess(this.message, this.logs);

  @override
  List<Object?> get props => [message, logs];
}

class ReminderLogError extends ReminderLogState {
  final String message;

  const ReminderLogError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReminderLogAdherence extends ReminderLogState {
  final double adherencePercentage;

  const ReminderLogAdherence(this.adherencePercentage);

  @override
  List<Object?> get props => [adherencePercentage];
}
