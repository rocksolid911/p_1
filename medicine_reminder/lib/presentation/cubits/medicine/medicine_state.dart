import 'package:equatable/equatable.dart';
import '../../../domain/entities/medicine.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {
  const MedicineInitial();
}

class MedicineLoading extends MedicineState {
  const MedicineLoading();
}

class MedicineLoaded extends MedicineState {
  final List<Medicine> medicines;

  const MedicineLoaded(this.medicines);

  @override
  List<Object?> get props => [medicines];
}

class MedicineOperationSuccess extends MedicineState {
  final String message;
  final List<Medicine> medicines;

  const MedicineOperationSuccess(this.message, this.medicines);

  @override
  List<Object?> get props => [message, medicines];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}
