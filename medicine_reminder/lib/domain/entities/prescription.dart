import 'medicine.dart';

/// Represents a parsed prescription
class ParsedPrescription {
  final String? doctorName;
  final String? patientName;
  final DateTime? prescriptionDate;
  final List<ParsedMedicine> medicines;
  final String? notes;

  const ParsedPrescription({
    this.doctorName,
    this.patientName,
    this.prescriptionDate,
    required this.medicines,
    this.notes,
  });

  ParsedPrescription copyWith({
    String? doctorName,
    String? patientName,
    DateTime? prescriptionDate,
    List<ParsedMedicine>? medicines,
    String? notes,
  }) {
    return ParsedPrescription(
      doctorName: doctorName ?? this.doctorName,
      patientName: patientName ?? this.patientName,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      medicines: medicines ?? this.medicines,
      notes: notes ?? this.notes,
    );
  }
}

/// Represents a medicine parsed from prescription
class ParsedMedicine {
  final String name;
  final String? dosage;
  final MedicineForm? form;
  final String? frequency; // e.g., "1-0-1", "TDS", "BD"
  final int? duration; // in days
  final String? timing; // e.g., "after food", "before meals"
  final List<DateTime>? suggestedTimes;

  const ParsedMedicine({
    required this.name,
    this.dosage,
    this.form,
    this.frequency,
    this.duration,
    this.timing,
    this.suggestedTimes,
  });

  ParsedMedicine copyWith({
    String? name,
    String? dosage,
    MedicineForm? form,
    String? frequency,
    int? duration,
    String? timing,
    List<DateTime>? suggestedTimes,
  }) {
    return ParsedMedicine(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      timing: timing ?? this.timing,
      suggestedTimes: suggestedTimes ?? this.suggestedTimes,
    );
  }
}
