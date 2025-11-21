import 'package:firebase_analytics/firebase_analytics.dart';
import '../../domain/entities/medicine.dart';

/// Firebase Analytics Service
/// Provides centralized analytics tracking for the app
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance =
      FirebaseAnalyticsService._internal();

  factory FirebaseAnalyticsService() => _instance;

  FirebaseAnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Auth Events
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  // Screen View Events
  Future<void> logScreenView(String screenName, String screenClass) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Medicine Events
  Future<void> logMedicineAdded(Medicine medicine) async {
    await _analytics.logEvent(
      name: 'medicine_added',
      parameters: {
        'medicine_name': medicine.name,
        'medicine_type': medicine.type,
        'frequency': medicine.frequency,
        'has_prescription': medicine.prescriptionImageUrl != null,
      },
    );
  }

  Future<void> logMedicineUpdated(String medicineId) async {
    await _analytics.logEvent(
      name: 'medicine_updated',
      parameters: {'medicine_id': medicineId},
    );
  }

  Future<void> logMedicineDeleted(String medicineId) async {
    await _analytics.logEvent(
      name: 'medicine_deleted',
      parameters: {'medicine_id': medicineId},
    );
  }

  Future<void> logMedicineToggled(String medicineId, bool isActive) async {
    await _analytics.logEvent(
      name: 'medicine_toggled',
      parameters: {
        'medicine_id': medicineId,
        'is_active': isActive,
      },
    );
  }

  // Reminder Events
  Future<void> logReminderTaken(String medicineId, bool onTime) async {
    await _analytics.logEvent(
      name: 'reminder_taken',
      parameters: {
        'medicine_id': medicineId,
        'on_time': onTime,
      },
    );
  }

  Future<void> logReminderSkipped(String medicineId) async {
    await _analytics.logEvent(
      name: 'reminder_skipped',
      parameters: {'medicine_id': medicineId},
    );
  }

  Future<void> logReminderSnoozed(String medicineId) async {
    await _analytics.logEvent(
      name: 'reminder_snoozed',
      parameters: {'medicine_id': medicineId},
    );
  }

  // Prescription Events
  Future<void> logPrescriptionUploaded(String source) async {
    await _analytics.logEvent(
      name: 'prescription_uploaded',
      parameters: {'source': source}, // 'camera', 'gallery', 'pdf'
    );
  }

  Future<void> logPrescriptionScanned(int medicinesDetected) async {
    await _analytics.logEvent(
      name: 'prescription_scanned',
      parameters: {'medicines_detected': medicinesDetected},
    );
  }

  // Settings Events
  Future<void> logNotificationSettingsChanged(bool enabled) async {
    await _analytics.logEvent(
      name: 'notification_settings_changed',
      parameters: {'enabled': enabled},
    );
  }

  Future<void> logThemeChanged(String theme) async {
    await _analytics.logEvent(
      name: 'theme_changed',
      parameters: {'theme': theme},
    );
  }

  // History Events
  Future<void> logHistoryViewed(String period) async {
    await _analytics.logEvent(
      name: 'history_viewed',
      parameters: {'period': period}, // 'day', 'week', 'month'
    );
  }

  Future<void> logAdherenceChecked(String medicineId, double adherence) async {
    await _analytics.logEvent(
      name: 'adherence_checked',
      parameters: {
        'medicine_id': medicineId,
        'adherence_percentage': adherence,
      },
    );
  }

  // Error Events
  Future<void> logError(String errorMessage, String location) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_message': errorMessage,
        'location': location,
      },
    );
  }

  // User Properties
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> clearUserId() async {
    await _analytics.setUserId(id: null);
  }
}
