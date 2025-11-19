# Firebase Configuration Guide

This guide will help you set up Firebase for the Medicine Reminder app.

## Required Files

You need to add the following Firebase configuration files (not included in git for security):

### Android Configuration
**File:** `android/app/google-services.json`

**How to get it:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project or create a new one
3. Click on the Android icon or "Add app"
4. Enter package name: `com.example.medicine_reminder`
5. Download `google-services.json`
6. Place it in `android/app/` directory

**Sample structure (DO NOT use this, get your own from Firebase):**
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_BUCKET"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_APP_ID",
        "android_client_info": {
          "package_name": "com.example.medicine_reminder"
        }
      }
    }
  ]
}
```

### iOS Configuration
**File:** `ios/Runner/GoogleService-Info.plist`

**How to get it:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on the iOS icon or "Add app"
4. Enter bundle ID: `com.example.medicineReminder`
5. Download `GoogleService-Info.plist`
6. Place it in `ios/Runner/` directory
7. Open Xcode and add the file to the project

**Sample structure (DO NOT use this, get your own from Firebase):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>YOUR_CLIENT_ID</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>YOUR_REVERSED_CLIENT_ID</string>
    <key>API_KEY</key>
    <string>YOUR_API_KEY</string>
    <key>GCM_SENDER_ID</key>
    <string>YOUR_SENDER_ID</string>
    <key>PROJECT_ID</key>
    <string>YOUR_PROJECT_ID</string>
    <key>STORAGE_BUCKET</key>
    <string>YOUR_BUCKET</string>
    <key>IS_ADS_ENABLED</key>
    <false/>
    <key>IS_ANALYTICS_ENABLED</key>
    <false/>
    <key>IS_APPINVITE_ENABLED</key>
    <false/>
    <key>IS_GCM_ENABLED</key>
    <true/>
    <key>IS_SIGNIN_ENABLED</key>
    <true/>
    <key>GOOGLE_APP_ID</key>
    <string>YOUR_APP_ID</string>
</dict>
</plist>
```

## Firebase Services to Enable

After creating your Firebase project, enable these services:

### 1. Authentication
- Go to **Authentication** → **Sign-in method**
- Enable **Email/Password**
- (Optional) Enable **Google** sign-in

### 2. Cloud Firestore
- Go to **Firestore Database**
- Click **Create database**
- Start in **production mode**
- Choose your location
- Set security rules (see main README)

### 3. Cloud Messaging (Optional)
- Automatically enabled with Firebase
- For iOS: Upload APNs certificate/key in **Project Settings** → **Cloud Messaging**

## Firestore Security Rules

Copy these rules to **Firestore Database** → **Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /medicines/{medicineId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /reminderLogs/{logId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Verification Checklist

- [ ] Created Firebase project
- [ ] Added Android app to Firebase
- [ ] Downloaded `google-services.json`
- [ ] Placed `google-services.json` in `android/app/`
- [ ] Added iOS app to Firebase
- [ ] Downloaded `GoogleService-Info.plist`
- [ ] Placed `GoogleService-Info.plist` in `ios/Runner/`
- [ ] Added plist file to Xcode project
- [ ] Enabled Email/Password authentication
- [ ] Created Firestore database
- [ ] Set Firestore security rules
- [ ] (Optional) Enabled Google Sign-In
- [ ] (Optional) Configured Cloud Messaging for iOS

## Testing Firebase Connection

Run the app and check if:
1. You can sign up with email/password
2. User data appears in Firestore console
3. Authentication works correctly
4. No Firebase connection errors in console

## Troubleshooting

**"FirebaseOptions not found" error:**
- Make sure configuration files are in the correct directories
- Run `flutter clean && flutter pub get`
- Rebuild the app

**"Package name mismatch" error:**
- Verify package name in `AndroidManifest.xml` matches Firebase console
- Verify bundle ID in Xcode matches Firebase console

**"Invalid API key" error:**
- Re-download configuration files from Firebase
- Ensure files are not corrupted

---

For more detailed instructions, see the main [README.md](README.md) file.
