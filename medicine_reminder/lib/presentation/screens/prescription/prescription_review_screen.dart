import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/prescription.dart';

class PrescriptionReviewScreen extends StatefulWidget {
  final ParsedPrescription prescription;
  final File? sourceImage;

  const PrescriptionReviewScreen({
    super.key,
    required this.prescription,
    this.sourceImage,
  });

  @override
  State<PrescriptionReviewScreen> createState() => _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState extends State<PrescriptionReviewScreen> {
  late List<ParsedMedicine> _medicines;

  @override
  void initState() {
    super.initState();
    _medicines = List.from(widget.prescription.medicines);
  }

  Future<void> _saveMedicines() async {
    // TODO: Implement saving medicines to database
    // This will create Medicine entities and save them

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicines saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Prescription'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveMedicines,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show source image if available
            if (widget.sourceImage != null) ...[
              ClipRRectImage.file(
                widget.sourceImage!,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
            ],

            // Prescription info
            if (widget.prescription.doctorName != null ||
                widget.prescription.patientName != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prescription Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.prescription.doctorName != null) ...[
                        _buildInfoRow(
                          'Doctor',
                          widget.prescription.doctorName!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (widget.prescription.patientName != null) ...[
                        _buildInfoRow(
                          'Patient',
                          widget.prescription.patientName!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (widget.prescription.prescriptionDate != null)
                        _buildInfoRow(
                          'Date',
                          _formatDate(widget.prescription.prescriptionDate!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Medicines list
            const Text(
              'Extracted Medicines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review and edit the extracted information before saving',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            if (_medicines.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No medicines were detected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please add medicines manually',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._medicines.map((medicine) => _buildMedicineCard(medicine)),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveMedicines,
        icon: const Icon(Icons.check),
        label: const Text('Save All'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(ParsedMedicine medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    medicine.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // TODO: Edit medicine
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _medicines.remove(medicine);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (medicine.dosage != null)
              _buildDetailRow('Dosage', medicine.dosage!),
            if (medicine.form != null)
              _buildDetailRow('Form', medicine.form!.displayName),
            if (medicine.frequency != null)
              _buildDetailRow('Frequency', medicine.frequency!),
            if (medicine.duration != null)
              _buildDetailRow('Duration', '${medicine.duration} days'),
            if (medicine.timing != null)
              _buildDetailRow('Timing', medicine.timing!),
            if (medicine.suggestedTimes != null &&
                medicine.suggestedTimes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Suggested Times:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: medicine.suggestedTimes!
                    .map((time) => Chip(
                          label: Text(_formatTime(time)),
                          backgroundColor:
                              const Color(0xFF2196F3).withValues(alpha: 0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}

// Helper widget for rounded rectangle image
class ClipRRectImage extends StatelessWidget {
  final File imageFile;
  final double height;
  final BoxFit fit;

  const ClipRRectImage.file(
    this.imageFile, {
    super.key,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        imageFile,
        height: height,
        width: double.infinity,
        fit: fit,
      ),
    );
  }
}
