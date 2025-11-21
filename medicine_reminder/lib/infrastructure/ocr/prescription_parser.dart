import '../../domain/entities/prescription.dart';
import '../../domain/entities/medicine.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

/// Parser for prescription text to extract structured medicine data
/// Now powered by Gemini AI for more accurate parsing
class PrescriptionParser {
  static const String _geminiApiKey = 'AIzaSyCpB8C7QQo8KxH9FvKZrqZqp4B8QzqG4zM'; // TODO: Move to environment variables
  GenerativeModel? _model;

  PrescriptionParser() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
      );
    } catch (e) {
      print('Failed to initialize Gemini model: $e');
    }
  }

  /// Parse prescription text into structured data
  /// Uses Gemini AI if available, falls back to regex parsing
  Future<ParsedPrescription> parse(String text) async {
    // Try Gemini AI first if available
    if (_model != null) {
      try {
        final geminiResult = await _parseWithGemini(text);
        if (geminiResult != null) {
          return geminiResult;
        }
      } catch (e) {
        print('Gemini parsing failed, falling back to regex: $e');
      }
    }

    // Fall back to regex-based parsing
    return _parseWithRegex(text);
  }

  /// Parse using Gemini AI
  Future<ParsedPrescription?> _parseWithGemini(String text) async {
    if (_model == null) return null;

    final prompt = '''
Analyze the following prescription text and extract structured information.
Return ONLY a valid JSON object with this exact structure (no markdown, no code blocks):

{
  "doctorName": "doctor name or null",
  "patientName": "patient name or null",
  "prescriptionDate": "YYYY-MM-DD or null",
  "medicines": [
    {
      "name": "medicine name",
      "dosage": "dosage with unit (e.g., 500 mg, 5 ml)",
      "form": "tablet|capsule|syrup|injection|drops|inhaler|cream|ointment",
      "frequency": "OD|BD|TDS|QID or 1-0-1 format or times per day",
      "duration": 7 (number of days as integer or null),
      "timing": "before food|after food|with food|at bedtime or null",
      "suggestedTimes": ["08:00", "14:00", "20:00"] (times in HH:mm format based on frequency)
    }
  ]
}

Rules for suggested times:
- OD/once daily: ["08:00"]
- BD/twice daily: ["08:00", "20:00"]
- TDS/thrice daily: ["08:00", "14:00", "20:00"]
- QID/4 times daily: ["08:00", "12:00", "16:00", "20:00"]
- 1-0-1: ["08:00", "20:00"] (morning and night)
- 1-1-1: ["08:00", "14:00", "20:00"] (morning, afternoon, night)

Prescription text:
$text
''';

    final content = [Content.text(prompt)];
    final response = await _model!.generateContent(content);
    final responseText = response.text?.trim() ?? '';

    if (responseText.isEmpty) return null;

    // Clean up response - remove markdown code blocks if present
    String jsonText = responseText;
    if (jsonText.contains('```json')) {
      jsonText = jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
    } else if (jsonText.contains('```')) {
      jsonText = jsonText.replaceAll('```', '').trim();
    }

    try {
      final jsonData = json.decode(jsonText) as Map<String, dynamic>;
      return _parseGeminiResponse(jsonData);
    } catch (e) {
      print('Failed to parse Gemini JSON response: $e');
      print('Response was: $responseText');
      return null;
    }
  }

  /// Convert Gemini JSON response to ParsedPrescription
  ParsedPrescription _parseGeminiResponse(Map<String, dynamic> json) {
    DateTime? prescriptionDate;
    if (json['prescriptionDate'] != null && json['prescriptionDate'] != 'null') {
      try {
        prescriptionDate = DateTime.parse(json['prescriptionDate']);
      } catch (e) {
        // Invalid date format
      }
    }

    final medicines = <ParsedMedicine>[];
    if (json['medicines'] is List) {
      for (final med in json['medicines']) {
        if (med is! Map<String, dynamic>) continue;

        // Parse suggested times
        List<DateTime>? suggestedTimes;
        if (med['suggestedTimes'] is List) {
          suggestedTimes = [];
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          for (final timeStr in med['suggestedTimes']) {
            try {
              final parts = timeStr.toString().split(':');
              if (parts.length >= 2) {
                suggestedTimes.add(
                  today.add(Duration(
                    hours: int.parse(parts[0]),
                    minutes: int.parse(parts[1]),
                  ))
                );
              }
            } catch (e) {
              // Skip invalid time
            }
          }
        }

        // Parse medicine form
        MedicineForm? form;
        if (med['form'] != null && med['form'] != 'null') {
          try {
            form = MedicineForm.values.firstWhere(
              (e) => e.name == med['form'].toString().toLowerCase()
            );
          } catch (e) {
            // Invalid form
          }
        }

        medicines.add(ParsedMedicine(
          name: med['name']?.toString() ?? 'Unknown',
          dosage: med['dosage']?.toString(),
          form: form,
          frequency: med['frequency']?.toString(),
          duration: med['duration'] is int ? med['duration'] : null,
          timing: med['timing']?.toString() != 'null' ? med['timing']?.toString() : null,
          suggestedTimes: suggestedTimes,
        ));
      }
    }

    return ParsedPrescription(
      doctorName: json['doctorName']?.toString() != 'null' ? json['doctorName']?.toString() : null,
      patientName: json['patientName']?.toString() != 'null' ? json['patientName']?.toString() : null,
      prescriptionDate: prescriptionDate,
      medicines: medicines,
    );
  }

  /// Fallback regex-based parsing
  Future<ParsedPrescription> _parseWithRegex(String text) async {
    try {
      final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

      String? doctorName;
      String? patientName;
      DateTime? prescriptionDate;
      final List<ParsedMedicine> medicines = [];

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        // Try to extract doctor name
        if (_containsPattern(line, ['dr.', 'dr ', 'doctor'])) {
          doctorName ??= _extractDoctorName(line);
        }

        // Try to extract patient name
        if (_containsPattern(line, ['patient:', 'name:', 'mr.', 'mrs.', 'ms.'])) {
          patientName ??= _extractPatientName(line);
        }

        // Try to extract date
        prescriptionDate ??= _extractDate(line);

        // Try to extract medicine
        final medicine = _extractMedicine(line, i < lines.length - 1 ? lines[i + 1] : null);
        if (medicine != null) {
          medicines.add(medicine);
        }
      }

      return ParsedPrescription(
        doctorName: doctorName,
        patientName: patientName,
        prescriptionDate: prescriptionDate,
        medicines: medicines,
      );
    } catch (e) {
      throw Exception('Failed to parse prescription: ${e.toString()}');
    }
  }

  /// Extract doctor name from line
  String? _extractDoctorName(String line) {
    final patterns = [
      RegExp(r'dr\.?\s+([a-z\s\.]+)', caseSensitive: false),
      RegExp(r'doctor\s+([a-z\s\.]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim();
      }
    }

    return null;
  }

  /// Extract patient name from line
  String? _extractPatientName(String line) {
    final patterns = [
      RegExp(r'patient:\s*([a-z\s\.]+)', caseSensitive: false),
      RegExp(r'name:\s*([a-z\s\.]+)', caseSensitive: false),
      RegExp(r'(?:mr\.|mrs\.|ms\.)\s+([a-z\s\.]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim();
      }
    }

    return null;
  }

  /// Extract date from line
  DateTime? _extractDate(String line) {
    final patterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      RegExp(r'(\d{2,4})[/-](\d{1,2})[/-](\d{1,2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null && match.groupCount >= 3) {
        try {
          final p1 = int.parse(match.group(1)!);
          final p2 = int.parse(match.group(2)!);
          var p3 = int.parse(match.group(3)!);

          // Handle 2-digit year
          if (p3 < 100) {
            p3 += 2000;
          }

          // Try different date formats
          try {
            return DateTime(p3, p2, p1); // DD/MM/YYYY
          } catch (e) {
            try {
              return DateTime(p1, p2, p3); // YYYY/MM/DD
            } catch (e) {
              // Invalid date
            }
          }
        } catch (e) {
          // Continue to next pattern
        }
      }
    }

    return null;
  }

  /// Extract medicine from line
  ParsedMedicine? _extractMedicine(String line, String? nextLine) {
    // Common medicine patterns
    final medicinePattern = RegExp(
      r'(?:tab\.?|cap\.?|syp\.?|inj\.?|drops?)\s+([a-z0-9\s\-]+)',
      caseSensitive: false,
    );

    final match = medicinePattern.firstMatch(line);
    if (match == null) return null;

    final name = match.group(1)?.trim();
    if (name == null || name.isEmpty) return null;

    // Extract dosage
    final dosage = _extractDosage(line);

    // Extract frequency (e.g., 1-0-1, BD, TDS, QID)
    final frequency = _extractFrequency(line);

    // Extract duration
    final duration = _extractDuration(line);

    // Extract timing
    final timing = _extractTiming(line);

    // Determine medicine form
    final form = _determineMedicineForm(line);

    // Generate suggested times based on frequency
    final suggestedTimes = _generateSuggestedTimes(frequency);

    return ParsedMedicine(
      name: name,
      dosage: dosage,
      form: form,
      frequency: frequency,
      duration: duration,
      timing: timing,
      suggestedTimes: suggestedTimes,
    );
  }

  /// Extract dosage from line
  String? _extractDosage(String line) {
    final patterns = [
      RegExp(r'(\d+\.?\d*\s*(?:mg|ml|g|mcg|iu))', caseSensitive: false),
      RegExp(r'(\d+\.?\d*\s*(?:milligram|milliliter|gram))', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }

    return null;
  }

  /// Extract frequency from line
  String? _extractFrequency(String line) {
    final patterns = [
      RegExp(r'\b(\d+-\d+-\d+)\b'), // e.g., 1-0-1, 1-1-1
      RegExp(r'\b(od|bd|tds|qid|sos|stat)\b', caseSensitive: false),
      RegExp(r'(\d+)\s*times?\s*(?:a|per)?\s*day', caseSensitive: false),
      RegExp(r'(?:once|twice|thrice)\s*(?:a|per)?\s*day', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        return match.group(0)?.trim();
      }
    }

    return null;
  }

  /// Extract duration from line
  int? _extractDuration(String line) {
    final patterns = [
      RegExp(r'for\s+(\d+)\s*days?', caseSensitive: false),
      RegExp(r'(\d+)\s*days?', caseSensitive: false),
      RegExp(r'x\s*(\d+)\s*days?', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null && match.groupCount > 0) {
        return int.tryParse(match.group(1)!);
      }
    }

    return null;
  }

  /// Extract timing from line
  String? _extractTiming(String line) {
    final patterns = [
      'before food',
      'after food',
      'with food',
      'before meals',
      'after meals',
      'empty stomach',
      'at bedtime',
    ];

    for (final pattern in patterns) {
      if (line.toLowerCase().contains(pattern)) {
        return pattern;
      }
    }

    return null;
  }

  /// Determine medicine form from line
  MedicineForm? _determineMedicineForm(String line) {
    final lowerLine = line.toLowerCase();

    if (lowerLine.contains('tab')) return MedicineForm.tablet;
    if (lowerLine.contains('cap')) return MedicineForm.capsule;
    if (lowerLine.contains('syp') || lowerLine.contains('syrup')) {
      return MedicineForm.syrup;
    }
    if (lowerLine.contains('inj')) return MedicineForm.injection;
    if (lowerLine.contains('drop')) return MedicineForm.drops;
    if (lowerLine.contains('inh')) return MedicineForm.inhaler;
    if (lowerLine.contains('cream')) return MedicineForm.cream;
    if (lowerLine.contains('ointment')) return MedicineForm.ointment;

    return null;
  }

  /// Generate suggested times based on frequency
  List<DateTime>? _generateSuggestedTimes(String? frequency) {
    if (frequency == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Handle 1-0-1, 1-1-1, etc. patterns
    final dosagePattern = RegExp(r'(\d+)-(\d+)-(\d+)');
    final dosageMatch = dosagePattern.firstMatch(frequency);

    if (dosageMatch != null) {
      final morning = int.parse(dosageMatch.group(1)!);
      final afternoon = int.parse(dosageMatch.group(2)!);
      final night = int.parse(dosageMatch.group(3)!);

      final times = <DateTime>[];
      if (morning > 0) times.add(today.add(const Duration(hours: 8))); // 8 AM
      if (afternoon > 0) times.add(today.add(const Duration(hours: 14))); // 2 PM
      if (night > 0) times.add(today.add(const Duration(hours: 20))); // 8 PM

      return times;
    }

    // Handle OD, BD, TDS, QID
    final lowerFreq = frequency.toLowerCase();

    if (lowerFreq.contains('od') || lowerFreq.contains('once')) {
      return [today.add(const Duration(hours: 8))]; // 8 AM
    }

    if (lowerFreq.contains('bd') || lowerFreq.contains('twice')) {
      return [
        today.add(const Duration(hours: 8)), // 8 AM
        today.add(const Duration(hours: 20)), // 8 PM
      ];
    }

    if (lowerFreq.contains('tds') || lowerFreq.contains('thrice')) {
      return [
        today.add(const Duration(hours: 8)), // 8 AM
        today.add(const Duration(hours: 14)), // 2 PM
        today.add(const Duration(hours: 20)), // 8 PM
      ];
    }

    if (lowerFreq.contains('qid')) {
      return [
        today.add(const Duration(hours: 8)), // 8 AM
        today.add(const Duration(hours: 12)), // 12 PM
        today.add(const Duration(hours: 16)), // 4 PM
        today.add(const Duration(hours: 20)), // 8 PM
      ];
    }

    // Handle "X times a day"
    final timesPattern = RegExp(r'(\d+)\s*times?', caseSensitive: false);
    final timesMatch = timesPattern.firstMatch(frequency);

    if (timesMatch != null) {
      final count = int.parse(timesMatch.group(1)!);
      final times = <DateTime>[];
      final interval = 12 ~/ count; // Distribute across waking hours

      for (var i = 0; i < count; i++) {
        times.add(today.add(Duration(hours: 8 + (i * interval))));
      }

      return times;
    }

    return null;
  }

  /// Check if line contains any of the patterns
  bool _containsPattern(String line, List<String> patterns) {
    final lowerLine = line.toLowerCase();
    return patterns.any((pattern) => lowerLine.contains(pattern.toLowerCase()));
  }
}
