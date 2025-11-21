import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/alarm_repository.dart';

/// Native alarm scheduler using flutter_local_notifications
class NativeAlarmScheduler implements AlarmRepository {
  final FlutterLocalNotificationsPlugin _notifications;

  NativeAlarmScheduler({
    FlutterLocalNotificationsPlugin? notifications,
  }) : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification interaction
    // This will be connected to the app's routing system
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen or show medicine intake dialog
      // Implementation will be connected via callback
    }
  }

  @override
  Future<void> scheduleAlarm({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    try {
      final notificationId = _generateNotificationId(medicineId, scheduledTime);

      // Android notification details with full-screen intent and DnD bypass
      const androidDetails = AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Reminders for taking medicines',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        // Full-screen intent - shows notification even when screen is locked
        fullScreenIntent: true,
        // Alarm category - bypasses Do Not Disturb mode
        category: AndroidNotificationCategory.alarm,
        // Use alarm audio attributes
        audioAttributesUsage: AudioAttributesUsage.alarm,
        // Visibility on lock screen
        visibility: NotificationVisibility.public,
        // Actions
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'taken',
            'Taken',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'snooze',
            'Snooze',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'skip',
            'Skip',
            showsUserInterface: false,
          ),
        ],
      );

      // iOS notification details with critical alert (bypasses DnD)
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // Critical alert - bypasses Do Not Disturb and silent mode
        // Note: Requires special entitlement from Apple
        interruptionLevel: InterruptionLevel.critical,
        sound: 'default',
        categoryIdentifier: 'medicine_reminder',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      final scheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      await _notifications.zonedSchedule(
        notificationId,
        'Time to take your medicine',
        '$medicineName - $dosage${notes != null ? '\n$notes' : ''}',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: '$medicineId|${scheduledTime.millisecondsSinceEpoch}',
      );
    } catch (e) {
      throw Exception('Failed to schedule alarm: ${e.toString()}');
    }
  }

  @override
  Future<void> scheduleMedicineAlarms(Medicine medicine) async {
    try {
      if (!medicine.isActive) return;

      final now = DateTime.now();
      final endDate = medicine.endDate ?? now.add(const Duration(days: 365));

      switch (medicine.scheduleType) {
        case ScheduleType.fixedTimes:
          await _scheduleFixedTimeAlarms(medicine, now, endDate);
          break;
        case ScheduleType.interval:
          await _scheduleIntervalAlarms(medicine, now, endDate);
          break;
        case ScheduleType.weeklyDays:
          await _scheduleWeeklyAlarms(medicine, now, endDate);
          break;
      }
    } catch (e) {
      throw Exception('Failed to schedule medicine alarms: ${e.toString()}');
    }
  }

  Future<void> _scheduleFixedTimeAlarms(
    Medicine medicine,
    DateTime start,
    DateTime end,
  ) async {
    var currentDate = start;

    while (currentDate.isBefore(end)) {
      for (final time in medicine.times) {
        final scheduledTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          time.hour,
          time.minute,
        );

        if (scheduledTime.isAfter(start)) {
          await scheduleAlarm(
            medicineId: medicine.id,
            medicineName: medicine.name,
            dosage: medicine.dosage,
            scheduledTime: scheduledTime,
            notes: medicine.notes,
          );
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));

      // Limit to next 30 days to avoid too many scheduled notifications
      if (currentDate.isAfter(start.add(const Duration(days: 30)))) {
        break;
      }
    }
  }

  Future<void> _scheduleIntervalAlarms(
    Medicine medicine,
    DateTime start,
    DateTime end,
  ) async {
    if (medicine.intervalHours == null) return;

    var currentTime = start;
    final limitDate = start.add(const Duration(days: 30));
    final actualEnd = end.isBefore(limitDate) ? end : limitDate;

    while (currentTime.isBefore(actualEnd)) {
      await scheduleAlarm(
        medicineId: medicine.id,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        scheduledTime: currentTime,
        notes: medicine.notes,
      );

      currentTime = currentTime.add(Duration(hours: medicine.intervalHours!));
    }
  }

  Future<void> _scheduleWeeklyAlarms(
    Medicine medicine,
    DateTime start,
    DateTime end,
  ) async {
    if (medicine.daysOfWeek == null || medicine.daysOfWeek!.isEmpty) return;

    var currentDate = start;
    final limitDate = start.add(const Duration(days: 30));
    final actualEnd = end.isBefore(limitDate) ? end : limitDate;

    while (currentDate.isBefore(actualEnd)) {
      // Check if current day matches any of the specified days
      if (medicine.daysOfWeek!.contains(currentDate.weekday)) {
        for (final time in medicine.times) {
          final scheduledTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            time.hour,
            time.minute,
          );

          if (scheduledTime.isAfter(start)) {
            await scheduleAlarm(
              medicineId: medicine.id,
              medicineName: medicine.name,
              dosage: medicine.dosage,
              scheduledTime: scheduledTime,
              notes: medicine.notes,
            );
          }
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  @override
  Future<void> cancelAlarm(String medicineId, DateTime scheduledTime) async {
    try {
      final notificationId = _generateNotificationId(medicineId, scheduledTime);
      await _notifications.cancel(notificationId);
    } catch (e) {
      throw Exception('Failed to cancel alarm: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelMedicineAlarms(String medicineId) async {
    try {
      // Get all pending notifications
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();

      // Cancel all notifications for this medicine
      for (final notification in pendingNotifications) {
        if (notification.payload?.startsWith(medicineId) ?? false) {
          await _notifications.cancel(notification.id);
        }
      }
    } catch (e) {
      throw Exception('Failed to cancel medicine alarms: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelAllAlarms() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      throw Exception('Failed to cancel all alarms: ${e.toString()}');
    }
  }

  @override
  Future<void> rescheduleAllAlarms(List<Medicine> medicines) async {
    try {
      // Cancel all existing alarms
      await cancelAllAlarms();

      // Reschedule all active medicines
      for (final medicine in medicines) {
        if (medicine.isActive) {
          await scheduleMedicineAlarms(medicine);
        }
      }
    } catch (e) {
      throw Exception('Failed to reschedule alarms: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasAlarmPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> requestAlarmPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Generate a unique notification ID based on medicine ID and time
  int _generateNotificationId(String medicineId, DateTime scheduledTime) {
    // Combine medicine ID hash with time to create unique ID
    final medicineHash = medicineId.hashCode;
    final timeHash = scheduledTime.millisecondsSinceEpoch ~/ 1000;
    return (medicineHash + timeHash) % 2147483647; // Max int32 value
  }
}
