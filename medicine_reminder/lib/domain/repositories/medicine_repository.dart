import '../entities/medicine.dart';

/// Repository interface for medicine operations
abstract class MedicineRepository {
  /// Get all medicines for a user
  Future<List<Medicine>> getAllMedicines(String userId);

  /// Get a specific medicine by ID
  Future<Medicine?> getMedicineById(String medicineId);

  /// Get active medicines for a user
  Future<List<Medicine>> getActiveMedicines(String userId);

  /// Add a new medicine
  Future<Medicine> addMedicine(Medicine medicine);

  /// Update an existing medicine
  Future<void> updateMedicine(Medicine medicine);

  /// Delete a medicine
  Future<void> deleteMedicine(String medicineId);

  /// Toggle medicine active status
  Future<void> toggleMedicineStatus(String medicineId, bool isActive);

  /// Stream of medicines for a user
  Stream<List<Medicine>> watchMedicines(String userId);

  /// Sync local medicines with remote
  Future<void> syncMedicines(String userId);
}
