# Do Not Disturb (DnD) Bypass & Full-Screen Notifications

This document explains how the Medicine Reminder app handles notifications that bypass Do Not Disturb mode and show as full-screen intents, ensuring users never miss their medicine reminders.

## 🚨 Critical Features for Medicine Reminders

### Why This Matters
Medicine reminders are time-critical and potentially life-saving. Users MUST be notified even when:
- Phone is locked
- Screen is off
- Do Not Disturb mode is active
- Silent mode is enabled

### What We've Implemented
✅ **Full-screen intent notifications** (Android)
✅ **Alarm category** to bypass DnD (Android)
✅ **Screen wake-up and show when locked** (Android)
✅ **Critical alert configuration** (iOS - requires entitlement)
✅ **High-priority alarm audio** (Android)

---

## Android Configuration

### 1. Permissions (AndroidManifest.xml)

```xml
<!-- Full-screen intent for showing notifications even when locked -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>

<!-- Access notification policy to bypass DnD for alarms -->
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY"/>

<!-- Other alarm-related permissions -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

**Location**: `android/app/src/main/AndroidManifest.xml:16-20`

### 2. Activity Configuration

```xml
<activity
    android:name=".MainActivity"
    android:showWhenLocked="true"
    android:turnScreenOn="true">
```

**What this does:**
- `showWhenLocked="true"`: Shows the activity over the lock screen
- `turnScreenOn="true"`: Turns the screen on when notification is displayed

**Location**: `android/app/src/main/AndroidManifest.xml:35-36`

### 3. Notification Configuration

In `NativeAlarmScheduler`, the notification is configured with:

```dart
AndroidNotificationDetails(
  'medicine_reminders',
  'Medicine Reminders',
  importance: Importance.max,
  priority: Priority.high,

  // Full-screen intent - shows notification even when screen is locked
  fullScreenIntent: true,

  // Alarm category - bypasses Do Not Disturb mode
  category: AndroidNotificationCategory.alarm,

  // Use alarm audio attributes
  audioAttributesUsage: AudioAttributesUsage.alarm,

  // Visibility on lock screen
  visibility: NotificationVisibility.public,
)
```

**Location**: `lib/infrastructure/alarm/native_alarm_scheduler.dart:61-77`

### What Each Setting Does:

| Setting | Purpose |
|---------|---------|
| `fullScreenIntent: true` | Shows full-screen notification when screen is locked |
| `category: AndroidNotificationCategory.alarm` | Bypasses Do Not Disturb (treats as alarm clock) |
| `audioAttributesUsage: AudioAttributesUsage.alarm` | Uses alarm audio stream (highest priority) |
| `visibility: NotificationVisibility.public` | Shows full content on lock screen |
| `importance: Importance.max` | Highest importance level |
| `priority: Priority.high` | High priority for heads-up notification |

### Android Versions:

| Version | Behavior |
|---------|----------|
| Android 10+ (API 29+) | Full-screen intent requires `USE_FULL_SCREEN_INTENT` permission |
| Android 12+ (API 31+) | User must grant "Alarms & reminders" special app access |
| Android 13+ (API 33+) | User must grant notification permission |

### User Setup Required:

For Android 12+, users need to:
1. Go to **Settings** → **Apps** → **Medicine Reminder**
2. Enable **"Alarms & reminders"** special access
3. Disable battery optimization for the app (optional but recommended)

---

## iOS Configuration

### 1. Critical Alerts (Bypasses DnD)

```dart
DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,

  // Critical alert - bypasses Do Not Disturb and silent mode
  interruptionLevel: InterruptionLevel.critical,
  sound: 'default',
)
```

**Location**: `lib/infrastructure/alarm/native_alarm_scheduler.dart:99-108`

### 2. Critical Alert Requirements

⚠️ **IMPORTANT**: Critical alerts on iOS require special approval from Apple.

**Requirements:**
1. **Entitlement Request**: Apply for `com.apple.developer.usernotifications.critical-alerts` entitlement
2. **App Review**: Justify why your app needs critical alerts during App Store review
3. **User Permission**: Even with entitlement, users must explicitly grant permission

**How to Apply:**
1. Log in to Apple Developer Center
2. Go to **Certificates, Identifiers & Profiles**
3. Select your App ID
4. Request **Critical Alerts** capability
5. Wait for Apple approval (can take several days)

**After Approval:**
1. Create/update `ios/Runner/Runner.entitlements`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.developer.usernotifications.critical-alerts</key>
       <true/>
   </dict>
   </plist>
   ```

2. Update in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select **Runner** target
   - Go to **Signing & Capabilities**
   - Click **+ Capability**
   - Add **Critical Alerts**

**Without Critical Alerts Entitlement:**
- App will work normally
- Notifications will NOT bypass DnD/Silent mode on iOS
- Users must manually allow notifications or disable DnD

**More info**: https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications

---

## Notification Channel Configuration

### Android: Creating High-Priority Alarm Channel

The notification channel is automatically created on first use, but you can also create it manually:

```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'medicine_reminders',
  'Medicine Reminders',
  description: 'Reminders for taking medicines',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  enableLights: true,
);

await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
```

---

## Testing DnD Bypass

### Android Testing:

1. **Enable DnD**:
   - Swipe down notification shade
   - Enable Do Not Disturb mode

2. **Set Test Alarm**:
   - Add a medicine with reminder in 1 minute
   - Lock phone

3. **Expected Result**:
   - Screen turns on
   - Full-screen notification appears
   - Alarm sound plays (even in DnD)
   - Vibration occurs

4. **Test Full-Screen Intent**:
   - Ensure screen is off and locked
   - Wait for reminder time
   - Screen should turn on automatically

### iOS Testing:

**Without Critical Alerts Entitlement:**
- Enable DnD/Silent mode
- Set reminder
- Notification will appear but won't make sound

**With Critical Alerts Entitlement:**
- Enable DnD/Silent mode
- Set reminder
- Notification should bypass DnD and make sound

---

## Troubleshooting

### Android: Notifications Not Showing When Locked

**Problem**: Notification doesn't appear on lock screen

**Solutions:**
1. Check `showWhenLocked="true"` in AndroidManifest.xml
2. Ensure `visibility: NotificationVisibility.public`
3. Check if "Show notifications on lock screen" is enabled in phone settings

### Android: Not Bypassing DnD

**Problem**: Notification is silent during DnD

**Solutions:**
1. Verify `category: AndroidNotificationCategory.alarm`
2. Check "Alarms & reminders" permission in app settings (Android 12+)
3. Ensure `audioAttributesUsage: AudioAttributesUsage.alarm`

### Android: Full-Screen Intent Not Working

**Problem**: Screen doesn't turn on

**Solutions:**
1. Check `USE_FULL_SCREEN_INTENT` permission in manifest
2. Verify `fullScreenIntent: true` in notification details
3. Android 12+: Check "Alarms & reminders" special access
4. Disable battery optimization for the app

### iOS: Not Bypassing DnD

**Problem**: No sound during DnD

**Solution:**
- Critical alerts require Apple entitlement
- Without it, iOS will not bypass DnD
- Apply for entitlement or inform users to disable DnD for medicine times

### Battery Optimization Issues

**Problem**: Alarms delayed or not firing

**Solutions:**
1. **Android**: Disable battery optimization
   - Settings → Apps → Medicine Reminder → Battery → Unrestricted
2. **iOS**: No action needed (iOS handles this automatically)

---

## Best Practices

### 1. Inform Users
Tell users to:
- Grant "Alarms & reminders" permission (Android 12+)
- Disable battery optimization
- Allow notification access

### 2. Graceful Degradation
- App works without critical permissions
- Fallback to regular high-priority notifications
- Inform users if critical features unavailable

### 3. Test Thoroughly
- Test on different Android versions (especially 12+)
- Test with DnD enabled
- Test with locked screen
- Test with battery saver mode

### 4. Documentation
- Include setup instructions in onboarding
- Provide in-app help for permission setup
- Show warnings if critical permissions denied

---

## Summary Table

| Feature | Android | iOS | Notes |
|---------|---------|-----|-------|
| Full-screen when locked | ✅ Yes | ✅ Yes | Works out of the box |
| Screen turn on | ✅ Yes | ⚠️ Limited | Android reliable, iOS system-dependent |
| Bypass DnD | ✅ Yes | ⚠️ Requires entitlement | Android works, iOS needs approval |
| Alarm audio priority | ✅ Yes | ⚠️ Requires entitlement | Android always, iOS with critical alerts |
| Works when app closed | ✅ Yes | ✅ Yes | Both platforms support |
| Survives reboot | ✅ Yes | ⚠️ Partial | Android with BootReceiver, iOS reschedule on app open |

✅ = Works out of the box
⚠️ = Requires special setup or entitlement

---

## Additional Resources

### Android:
- [Full-Screen Intent](https://developer.android.com/training/notify-user/time-sensitive#fullscreen-intent)
- [Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
- [Schedule Exact Alarms](https://developer.android.com/training/scheduling/alarms)

### iOS:
- [Critical Alerts](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications)
- [UNNotificationInterruptionLevel](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel)
- [Local Notifications](https://developer.apple.com/documentation/usernotifications/scheduling_a_notification_locally_from_your_app)

### Flutter Plugins:
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [permission_handler](https://pub.dev/packages/permission_handler)

---

**Last Updated**: Based on flutter_local_notifications latest documentation
**Tested On**: Android 13, iOS 16+
