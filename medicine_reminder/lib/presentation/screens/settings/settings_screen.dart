import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'medical_info_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Default reminder times
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _afternoonTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _nightTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadDefaultTimes();
  }

  Future<void> _loadDefaultTimes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _morningTime = TimeOfDay(
        hour: prefs.getInt('morning_hour') ?? 8,
        minute: prefs.getInt('morning_minute') ?? 0,
      );
      _afternoonTime = TimeOfDay(
        hour: prefs.getInt('afternoon_hour') ?? 14,
        minute: prefs.getInt('afternoon_minute') ?? 0,
      );
      _eveningTime = TimeOfDay(
        hour: prefs.getInt('evening_hour') ?? 18,
        minute: prefs.getInt('evening_minute') ?? 0,
      );
      _nightTime = TimeOfDay(
        hour: prefs.getInt('night_hour') ?? 22,
        minute: prefs.getInt('night_minute') ?? 0,
      );
    });
  }

  Future<void> _saveDefaultTime(String period, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${period}_hour', time.hour);
    await prefs.setInt('${period}_minute', time.minute);
  }

  Future<void> _editTime(String period, TimeOfDay currentTime) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (newTime != null) {
      await _saveDefaultTime(period, newTime);
      await _loadDefaultTimes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${period.capitalize()} time updated to ${_formatTime(newTime)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),

          // Profile section
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.medical_information),
                  title: const Text('Medical Information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicalInfoScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification settings
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive medicine reminders'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Sound'),
                  subtitle: const Text('Play sound for reminders'),
                  value: _soundEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        }
                      : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration),
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for reminders'),
                  value: _vibrationEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Default times
          const Text(
            'Default Reminder Times',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Text('🌅'),
                  title: const Text('Morning'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatTime(_morningTime)),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16),
                    ],
                  ),
                  onTap: () => _editTime('morning', _morningTime),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('☀️'),
                  title: const Text('Afternoon'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatTime(_afternoonTime)),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16),
                    ],
                  ),
                  onTap: () => _editTime('afternoon', _afternoonTime),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('🌇'),
                  title: const Text('Evening'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatTime(_eveningTime)),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16),
                    ],
                  ),
                  onTap: () => _editTime('evening', _eveningTime),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('🌙'),
                  title: const Text('Night'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatTime(_nightTime)),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16),
                    ],
                  ),
                  onTap: () => _editTime('night', _nightTime),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App settings
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup & Sync'),
                  subtitle: const Text('Sync with Firebase'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to backup settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to help
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show about dialog
                    showAboutDialog(
                      context: context,
                      applicationName: 'Medicine Reminder',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.medication,
                        size: 48,
                        color: Color(0xFF2196F3),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
