import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

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
                    // Navigate to edit profile
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.medical_information),
                  title: const Text('Medical Information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to medical info
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
                  trailing: const Text('08:00 AM'),
                  onTap: () {
                    // Edit morning time
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('☀️'),
                  title: const Text('Afternoon'),
                  trailing: const Text('02:00 PM'),
                  onTap: () {
                    // Edit afternoon time
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('🌇'),
                  title: const Text('Evening'),
                  trailing: const Text('06:00 PM'),
                  onTap: () {
                    // Edit evening time
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('🌙'),
                  title: const Text('Night'),
                  trailing: const Text('10:00 PM'),
                  onTap: () {
                    // Edit night time
                  },
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
