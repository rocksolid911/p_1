package com.example.medicine_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Boot receiver to reschedule alarms after device restart
 *
 * This receiver listens for BOOT_COMPLETED broadcast and triggers
 * the Flutter app to reschedule all pending medicine reminders.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON") {

            Log.d("BootReceiver", "Device boot completed, rescheduling alarms")

            // TODO: Trigger Flutter app to reschedule alarms
            // This can be done by:
            // 1. Using WorkManager to trigger a background task
            // 2. Using MethodChannel to communicate with Flutter
            // 3. Reading from local database and rescheduling directly

            // For now, we'll rely on the app to reschedule when it's opened
            // A more robust solution would use WorkManager for background execution
        }
    }
}
