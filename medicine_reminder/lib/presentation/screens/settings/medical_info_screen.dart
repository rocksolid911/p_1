import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalInfo() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _bloodTypeController.text = data['bloodType'] ?? '';
          _allergiesController.text = data['allergies'] ?? '';
          _conditionsController.text = data['medicalConditions'] ?? '';
          _notesController.text = data['medicalNotes'] ?? '';
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load medical info: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveMedicalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final updates = {
        'bloodType': _bloodTypeController.text.trim(),
        'allergies': _allergiesController.text.trim(),
        'medicalConditions': _conditionsController.text.trim(),
        'medicalNotes': _notesController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(updates, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical information updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save medical info: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveMedicalInfo,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This information helps emergency services provide better care if needed.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Blood Type
                    TextFormField(
                      controller: _bloodTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        hintText: 'e.g., A+, O-, AB+',
                        prefixIcon: Icon(Icons.bloodtype_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Allergies
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Allergies',
                        hintText: 'e.g., Penicillin, Peanuts, Shellfish',
                        prefixIcon: Icon(Icons.warning_amber_outlined),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Medical Conditions
                    TextFormField(
                      controller: _conditionsController,
                      decoration: const InputDecoration(
                        labelText: 'Medical Conditions',
                        hintText: 'e.g., Diabetes, Hypertension, Asthma',
                        prefixIcon: Icon(Icons.health_and_safety_outlined),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Additional Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        hintText: 'Any other important medical information',
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMedicalInfo,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save Medical Information'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
