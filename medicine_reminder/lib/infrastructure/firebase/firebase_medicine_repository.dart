import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import 'models/medicine_model.dart';

/// Firebase implementation of MedicineRepository
class FirebaseMedicineRepository implements MedicineRepository {
  final FirebaseFirestore _firestore;

  FirebaseMedicineRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getMedicinesCollection(String userId) {
    return _firestore.collection('medicines').doc(userId).collection('medicines');
  }

  @override
  Future<List<Medicine>> getAllMedicines(String userId) async {
    try {
      final snapshot = await _getMedicinesCollection(userId).get();
      return snapshot.docs
          .map((doc) => MedicineModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get medicines: $e');
    }
  }

  @override
  Future<Medicine?> getMedicineById(String medicineId) async {
    try {
      // We need userId to access the medicine, but it's embedded in the path
      // For now, we'll search across all users (not ideal for production)
      // In a real app, you'd pass userId or restructure the database
      final usersSnapshot = await _firestore.collection('medicines').get();

      for (final userDoc in usersSnapshot.docs) {
        final medicineDoc = await userDoc.reference
            .collection('medicines')
            .doc(medicineId)
            .get();

        if (medicineDoc.exists) {
          return MedicineModel.fromFirestore(medicineDoc).toEntity();
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get medicine: $e');
    }
  }

  @override
  Future<List<Medicine>> getActiveMedicines(String userId) async {
    try {
      final snapshot = await _getMedicinesCollection(userId)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => MedicineModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get active medicines: $e');
    }
  }

  @override
  Future<Medicine> addMedicine(Medicine medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      final docRef = _getMedicinesCollection(medicine.userId).doc(medicine.id);
      await docRef.set(model.toFirestore());
      return medicine;
    } catch (e) {
      throw Exception('Failed to add medicine: $e');
    }
  }

  @override
  Future<void> updateMedicine(Medicine medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      await _getMedicinesCollection(medicine.userId)
          .doc(medicine.id)
          .update(model.toFirestore());
    } catch (e) {
      throw Exception('Failed to update medicine: $e');
    }
  }

  @override
  Future<void> deleteMedicine(String medicineId) async {
    try {
      // Similar issue as getMedicineById - need userId
      // For now, search across all users
      final usersSnapshot = await _firestore.collection('medicines').get();

      for (final userDoc in usersSnapshot.docs) {
        final medicineDoc = await userDoc.reference
            .collection('medicines')
            .doc(medicineId)
            .get();

        if (medicineDoc.exists) {
          await medicineDoc.reference.delete();
          return;
        }
      }
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }

  @override
  Future<void> toggleMedicineStatus(String medicineId, bool isActive) async {
    try {
      // Similar issue - need userId
      final usersSnapshot = await _firestore.collection('medicines').get();

      for (final userDoc in usersSnapshot.docs) {
        final medicineDoc = await userDoc.reference
            .collection('medicines')
            .doc(medicineId)
            .get();

        if (medicineDoc.exists) {
          await medicineDoc.reference.update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return;
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle medicine status: $e');
    }
  }

  @override
  Stream<List<Medicine>> watchMedicines(String userId) {
    return _getMedicinesCollection(userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicineModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<void> syncMedicines(String userId) async {
    // Sync is automatic with Firestore real-time listeners
    // This method can be used for manual sync if needed
    try {
      await _getMedicinesCollection(userId).get();
    } catch (e) {
      throw Exception('Failed to sync medicines: $e');
    }
  }
}
