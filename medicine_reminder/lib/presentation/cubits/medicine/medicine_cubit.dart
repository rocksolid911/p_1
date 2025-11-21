import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/medicine.dart';
import '../../../domain/repositories/medicine_repository.dart';
import 'medicine_state.dart';
import 'dart:async';

class MedicineCubit extends Cubit<MedicineState> {
  final MedicineRepository _medicineRepository;
  StreamSubscription? _medicineSubscription;

  MedicineCubit(this._medicineRepository) : super(const MedicineInitial());

  Future<void> loadMedicines(String userId) async {
    emit(const MedicineLoading());
    try {
      final medicines = await _medicineRepository.getAllMedicines(userId);
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> loadActiveMedicines(String userId) async {
    emit(const MedicineLoading());
    try {
      final medicines = await _medicineRepository.getActiveMedicines(userId);
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  void watchMedicines(String userId) {
    _medicineSubscription?.cancel();
    _medicineSubscription = _medicineRepository.watchMedicines(userId).listen(
      (medicines) {
        emit(MedicineLoaded(medicines));
      },
      onError: (error) {
        emit(MedicineError(error.toString()));
      },
    );
  }

  Future<void> addMedicine(Medicine medicine, String userId) async {
    try {
      emit(const MedicineLoading());
      await _medicineRepository.addMedicine(medicine);
      final medicines = await _medicineRepository.getAllMedicines(userId);
      emit(MedicineOperationSuccess('Medicine added successfully', medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> updateMedicine(Medicine medicine, String userId) async {
    try {
      emit(const MedicineLoading());
      await _medicineRepository.updateMedicine(medicine);
      final medicines = await _medicineRepository.getAllMedicines(userId);
      emit(MedicineOperationSuccess('Medicine updated successfully', medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> deleteMedicine(String medicineId, String userId) async {
    try {
      emit(const MedicineLoading());
      await _medicineRepository.deleteMedicine(medicineId);
      final medicines = await _medicineRepository.getAllMedicines(userId);
      emit(MedicineOperationSuccess('Medicine deleted successfully', medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> toggleMedicineStatus(
    String medicineId,
    bool isActive,
    String userId,
  ) async {
    try {
      await _medicineRepository.toggleMedicineStatus(medicineId, isActive);
      final medicines = await _medicineRepository.getAllMedicines(userId);
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> syncMedicines(String userId) async {
    try {
      await _medicineRepository.syncMedicines(userId);
      final medicines = await _medicineRepository.getAllMedicines(userId);
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _medicineSubscription?.cancel();
    return super.close();
  }
}
