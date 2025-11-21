# Medicine Reminder App

A production-ready mobile application for managing medicine schedules with prescription scanning, native OS alarms, and Firebase integration.

## Features

### Core Functionality
- **Prescription Scanning**: Upload prescription as PDF or image, or capture via camera
- **AI-Powered Extraction**: On-device OCR using ML Kit to extract medicine details
- **Smart Parsing**: Automatic detection of medicine name, dosage, frequency, and schedule
- **Native Alarms**: OS-level reminders using AlarmManager (Android) and UNUserNotificationCenter (iOS)
- **🚨 Full-Screen Notifications**: Alarm notifications that show even when phone is locked
- **🔕 DnD Bypass**: Notifications bypass Do Not Disturb mode (treated as alarm clock)
- **📱 Screen Wake-up**: Automatically turns on screen for medicine reminders
- **Manual Management**: Add, edit, and delete medicines manually
- **Firebase Integration**: User authentication, cloud sync, and backup
- **Adherence Tracking**: Monitor medicine intake history and compliance
- **Offline Support**: Local database with automatic sync when online

> **⚠️ Critical Feature**: Medicine reminders use full-screen intent and alarm category to ensure you NEVER miss a dose, even when your phone is locked or on Do Not Disturb. See [DND_BYPASS_GUIDE.md](DND_BYPASS_GUIDE.md) for details.

### Technical Highlights
- Clean Architecture (Domain, Application, Infrastructure, Presentation layers)
- State Management with Riverpod
- Local persistence with SQLite
- Firebase Authentication (Email/Password, Google Sign-In)
- Cloud Firestore for data sync
- Firebase Cloud Messaging for push notifications
- Responsive and modern UI with Material Design 3

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Installation](#installation)
4. [Running the App](#running-the-app)
5. [Architecture](#architecture)
6. [Features Explained](#features-explained)
7. [DnD Bypass & Full-Screen Notifications](#dnd-bypass--full-screen-notifications)
8. [Testing](#testing)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode
- Firebase CLI (optional but recommended)

### Platform Requirements
- **Android**: Minimum SDK 21 (Android 5.0)
- **iOS**: iOS 12.0 or higher

---

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project**
3. Enter project name: `medicine-reminder` (or your preferred name)
4. Disable Google Analytics (optional for this project)
5. Click **Create Project**

### Step 2: Register Android App

1. In Firebase Console, click **Add app** → **Android**
2. Enter package name: `com.example.medicine_reminder`
3. Enter app nickname: `Medicine Reminder Android`
4. Download `google-services.json`
5. Place the file in: `medicine_reminder/android/app/google-services.json`

### Step 3: Register iOS App

1. In Firebase Console, click **Add app** → **iOS**
2. Enter bundle ID: `com.example.medicineReminder`
3. Enter app nickname: `Medicine Reminder iOS`
4. Download `GoogleService-Info.plist`
5. Place the file in: `medicine_reminder/ios/Runner/GoogleService-Info.plist`

### Step 4: Enable Firebase Services

#### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google** (optional)
   - Download OAuth client configuration
   - Add to Android: Update `android/app/src/main/res/values/strings.xml`:
     ```xml
     <string name="default_web_client_id">YOUR_WEB_CLIENT_ID</string>
     ```

#### Cloud Firestore
1. Go to **Firestore Database** → **Create database**
2. Start in **production mode** (we'll set rules next)
3. Choose your preferred location
4. Click **Enable**

#### Set Firestore Security Rules
Go to **Firestore Database** → **Rules** and add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents - users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // User's medicines subcollection
      match /medicines/{medicineId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // User's reminder logs subcollection
      match /reminderLogs/{logId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

#### Firebase Cloud Messaging (FCM)
1. Go to **Project settings** → **Cloud Messaging**
2. Note down the **Server Key** for backend integration (if needed)
3. Android: No additional setup required
4. iOS: Upload APNs authentication key or certificate

### Step 5: Update Android Configuration

Add to `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

### Step 6: Update iOS Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure `GoogleService-Info.plist` is added to the project
3. Enable **Push Notifications** capability
4. Enable **Background Modes** → Check **Remote notifications**

---

## Installation

### 1. Clone the Repository
```bash
cd medicine_reminder
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Add Firebase Configuration Files
Ensure you've placed:
- `google-services.json` in `android/app/`
- `GoogleService-Info.plist` in `ios/Runner/`

### 4. Run Code Generation (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Running the App

### Android
```bash
flutter run
```

### iOS
```bash
cd ios
pod install
cd ..
flutter run
```

### Build Release APK (Android)
```bash
flutter build apk --release
```

### Build iOS App
```bash
flutter build ios --release
```

---

## Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── domain/              # Business logic and entities
│   ├── entities/        # Core data models
│   └── repositories/    # Repository interfaces
├── infrastructure/      # External services implementation
│   ├── firebase/        # Firebase services
│   ├── local_db/        # SQLite database
│   ├── ocr/            # ML Kit OCR and parsing
│   └── alarm/          # Native alarm scheduling
├── application/         # Application logic
│   ├── use_cases/      # Business use cases
│   └── services/       # Application services
└── presentation/        # UI layer
    ├── screens/        # App screens
    ├── widgets/        # Reusable widgets
    └── providers/      # Riverpod providers
```

### Key Components

#### 1. Domain Layer
- **Entities**: `User`, `Medicine`, `ReminderLog`, `ParsedPrescription`
- **Repositories**: Interfaces for data operations
- Pure Dart, no external dependencies

#### 2. Infrastructure Layer
- **Firebase Auth Repository**: User authentication
- **Firestore Repository**: Cloud data storage
- **ML Kit OCR Service**: Text extraction from images/PDFs
- **Prescription Parser**: Converts OCR text to structured data
- **Native Alarm Scheduler**: OS-level reminders
- **Local Database**: SQLite for offline storage

#### 3. Presentation Layer
- **Authentication**: Login, Signup screens
- **Home**: Dashboard with today's medicines
- **Prescription Upload**: Scan and review
- **Medicine Management**: Add/edit manually
- **History**: View adherence and logs
- **Settings**: User preferences

---

## Features Explained

### 1. Prescription Upload & OCR

**How it works:**
1. User uploads PDF or image of prescription
2. `MLKitOCRService` extracts text using Google ML Kit (on-device)
3. `PrescriptionParser` analyzes text and extracts:
   - Medicine names
   - Dosage (e.g., "500 mg")
   - Frequency (e.g., "1-0-1", "BD", "TDS")
   - Duration (e.g., "5 days")
   - Timing (e.g., "after food")
4. Suggested reminder times are generated
5. User reviews and edits on `PrescriptionReviewScreen`
6. Medicines are saved to local DB and Firestore

**Supported Patterns:**
- Dosage codes: `1-0-1` (morning-afternoon-night)
- Frequency: `OD`, `BD`, `TDS`, `QID`
- Duration: "for X days", "X days"
- Forms: Tablet, Capsule, Syrup, Injection, etc.

### 2. Native Alarm System

**Android:**
- Uses `flutter_local_notifications`
- Schedules exact alarms via `AlarmManager`
- `SCHEDULE_EXACT_ALARM` permission for precise timing
- Alarms survive app closure and phone restart
- `BootReceiver` reschedules alarms after reboot

**iOS:**
- Uses `UNUserNotificationCenter`
- Schedules local notifications with exact time
- Notifications delivered even when app is closed
- User must grant notification permissions

**Features:**
- Snooze (+10/15/30 minutes)
- Mark as Taken/Skipped
- Notification actions

### 3. Firebase Integration

#### Authentication
- Email/Password signup and login
- Google Sign-In (optional)
- Password reset via email
- Session management

#### Cloud Firestore Structure
```
users/
  {userId}/
    - email, name, age, timezone, medicalNotes

    medicines/
      {medicineId}/
        - name, dosage, form, scheduleType, times, startDate, endDate, etc.

    reminderLogs/
      {logId}/
        - medicineId, scheduledTime, actualTakenTime, status
```

#### Security
- Firestore rules ensure users can only access their own data
- All queries scoped by `userId`

#### Offline Support
- Local SQLite database mirrors Firestore data
- App works fully offline
- Automatic sync when connection is restored

### 4. Adherence Tracking

**Metrics:**
- Doses taken vs. scheduled
- Adherence percentage (7-day, 30-day)
- Missed and skipped doses
- Calendar view of history

**Implementation:**
- Each reminder action creates a `ReminderLog`
- Logs stored locally and synced to Firestore
- Statistics calculated from logs

---

## Project Structure Details

### Data Models

#### Medicine Entity
```dart
class Medicine {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final MedicineForm form;
  final ScheduleType scheduleType;
  final List<DateTime> times;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
}
```

#### Schedule Types
1. **Fixed Times**: Specific times each day (e.g., 8 AM, 2 PM, 8 PM)
2. **Interval**: Every X hours
3. **Weekly Days**: Specific days of the week

### OCR Pipeline

```
Image/PDF
    ↓
MLKitOCRService (Text Recognition)
    ↓
Raw Text
    ↓
PrescriptionParser (Pattern Matching & NLP)
    ↓
ParsedPrescription
    ↓
PrescriptionReviewScreen (User Validation)
    ↓
Medicine Entities
```

### Alarm Scheduling Flow

```
Medicine Created/Updated
    ↓
NativeAlarmScheduler.scheduleMedicineAlarms()
    ↓
Calculate all reminder times (next 30 days)
    ↓
For each time:
  - Generate unique notification ID
  - Schedule with flutter_local_notifications
  - Store in pending_alarms table
    ↓
Alarm fires at scheduled time
    ↓
Notification with actions (Taken/Snooze/Skip)
    ↓
User action creates ReminderLog
    ↓
Sync to Firestore
```

---

## DnD Bypass & Full-Screen Notifications

### 🚨 Critical Feature for Medicine Reminders

Medicine reminders are time-critical and potentially life-saving. This app implements **full-screen intent notifications** and **Do Not Disturb (DnD) bypass** to ensure users NEVER miss a dose.

### What This Means:
- ✅ Notifications show even when phone is **locked**
- ✅ Screen **turns on automatically** for reminders
- ✅ **Bypasses Do Not Disturb** mode (treated as alarm clock)
- ✅ Uses **highest priority alarm audio**
- ✅ Shows **full content on lock screen**

### Android Configuration

**Permissions** (`AndroidManifest.xml`):
```xml
<!-- Full-screen intent for showing notifications when locked -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>

<!-- Bypass DnD for alarms -->
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY"/>
```

**Activity Configuration**:
```xml
<activity
    android:showWhenLocked="true"
    android:turnScreenOn="true">
```

**Notification Setup** (`native_alarm_scheduler.dart:61-77`):
```dart
AndroidNotificationDetails(
  fullScreenIntent: true,              // Shows when locked
  category: AndroidNotificationCategory.alarm,  // Bypasses DnD
  audioAttributesUsage: AudioAttributesUsage.alarm,  // Alarm priority
  visibility: NotificationVisibility.public,  // Full content on lock screen
)
```

### iOS Configuration

**Critical Alerts** (requires Apple entitlement):
```dart
DarwinNotificationDetails(
  interruptionLevel: InterruptionLevel.critical,  // Bypasses DnD
)
```

⚠️ **Note**: iOS critical alerts require special approval from Apple. See [DND_BYPASS_GUIDE.md](DND_BYPASS_GUIDE.md) for how to apply.

### User Setup (Android 12+)

For full functionality, users need to:
1. Grant "Alarms & reminders" special app access
2. Allow notification permissions
3. Disable battery optimization (recommended)

### Complete Documentation

For detailed information including:
- Platform-specific behavior
- iOS critical alert entitlement process
- Testing procedures
- Troubleshooting DnD issues
- Battery optimization handling

**See: [DND_BYPASS_GUIDE.md](DND_BYPASS_GUIDE.md)**

---

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test
```

### Manual Testing Checklist
- [ ] User signup and login
- [ ] Upload prescription (image and PDF)
- [ ] Verify OCR extraction accuracy
- [ ] Edit and save medicines
- [ ] Verify alarm notifications fire
- [ ] Test notification actions
- [ ] Check offline functionality
- [ ] Verify data syncs after coming online
- [ ] Test adherence tracking

---

## Troubleshooting

### Firebase Connection Issues

**Problem:** App crashes on startup with Firebase error

**Solution:**
1. Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in correct locations
2. Check package name matches Firebase configuration
3. Run `flutter clean && flutter pub get`

### Alarms Not Firing

**Problem:** Notifications not appearing at scheduled time

**Solution (Android):**
1. Check if app has notification permissions
2. Verify `SCHEDULE_EXACT_ALARM` permission is granted
3. Disable battery optimization for the app
4. Check Do Not Disturb settings

**Solution (iOS):**
1. Check notification permissions in Settings
2. Ensure app has Background App Refresh enabled

### OCR Not Working

**Problem:** Text not extracted from prescription

**Solution:**
1. Ensure good image quality (clear, well-lit)
2. Check camera and storage permissions
3. Verify `google_mlkit_text_recognition` plugin is properly installed
4. Try preprocessing image (increase contrast)

### Build Errors

**Problem:** Build fails with dependency conflicts

**Solution:**
```bash
flutter clean
flutter pub get
cd ios && pod install && pod update
cd ..
flutter run
```

---

## Firebase Configuration Files

### Required Files (Add these yourself):

1. **android/app/google-services.json**
   - Download from Firebase Console
   - Android app configuration

2. **ios/Runner/GoogleService-Info.plist**
   - Download from Firebase Console
   - iOS app configuration

### Sample Structure:

The Firebase configuration files are gitignored for security. You must:
1. Create Firebase project
2. Download configuration files
3. Place them in the correct directories

---

## Additional Configuration

### Notification Icons (Android)

Place notification icons in:
```
android/app/src/main/res/
  ├── mipmap-hdpi/ic_launcher.png
  ├── mipmap-mdpi/ic_launcher.png
  ├── mipmap-xhdpi/ic_launcher.png
  ├── mipmap-xxhdpi/ic_launcher.png
  └── mipmap-xxxhdpi/ic_launcher.png
```

### App Icons

Generate using:
```bash
flutter pub run flutter_launcher_icons:main
```

---

## Environment Variables

For production deployment, consider using environment variables for:
- Firebase API keys
- OAuth client IDs
- Backend API URLs

Use `flutter_dotenv` or similar package.

---

## Future Enhancements

- [ ] Multi-language support
- [ ] Dark mode
- [ ] Medicine interaction warnings
- [ ] Refill reminders
- [ ] Doctor appointment tracking
- [ ] Export reports (PDF)
- [ ] Family member management
- [ ] Medication barcode scanner
- [ ] Voice commands

---

## License

This project is licensed under the MIT License.

---

## Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review Firebase setup steps
3. Check Flutter and Firebase documentation
4. Open an issue on GitHub

---

## Credits

Built with:
- Flutter & Dart
- Firebase (Auth, Firestore, FCM)
- Google ML Kit
- flutter_local_notifications
- Riverpod

---

**Happy Coding! 💊📱**
