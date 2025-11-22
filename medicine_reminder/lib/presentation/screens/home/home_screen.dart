import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../medicine/add_medicine_screen.dart';
import '../prescription/prescription_upload_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/medicine/medicine_cubit.dart';
import '../../cubits/medicine/medicine_state.dart';
import '../../../domain/entities/medicine.dart';
import '../../../infrastructure/firebase/firebase_analytics_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _analytics = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('Home Screen', 'HomeScreen');
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthCubit>().signOut();
      _analytics.logLogout();
      _analytics.clearUserId();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? const _HomeContent()
          : _selectedIndex == 1
              ? const HistoryScreen()
              : const SettingsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddOptions(context),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Medicine',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
              title: const Text('Scan Prescription'),
              subtitle: const Text('Upload or take photo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrescriptionUploadScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF2196F3)),
              title: const Text('Add Manually'),
              subtitle: const Text('Enter details manually'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMedicineScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load medicines when home screen opens (only once)
    if (!_hasLoaded) {
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        context.read<MedicineCubit>().watchMedicines(currentUser.uid);
        _hasLoaded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineCubit, MedicineState>(
      builder: (context, state) {
        if (state is MedicineLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Medicine> medicines = [];
        if (state is MedicineLoaded) {
          medicines = state.medicines.where((m) => m.isActive).toList();
        } else if (state is MedicineOperationSuccess) {
          medicines = state.medicines.where((m) => m.isActive).toList();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_getGreeting()}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Stay healthy, take your medicines on time',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication,
                      size: 32,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Today's schedule header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
              const SizedBox(height: 16),
              // Display medicines by time of day
              if (medicines.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No medicines added yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the + button to add your first medicine',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._buildMedicinesByTime(medicines),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMedicinesByTime(List<Medicine> medicines) {
    // Group medicines by time of day
    final morning = <Medicine>[];
    final afternoon = <Medicine>[];
    final evening = <Medicine>[];
    final night = <Medicine>[];

    for (final medicine in medicines) {
      for (final time in medicine.times) {
        final hour = time.hour;
        if (hour >= 5 && hour < 12) {
          if (!morning.any((m) => m.id == medicine.id)) morning.add(medicine);
        } else if (hour >= 12 && hour < 17) {
          if (!afternoon.any((m) => m.id == medicine.id)) afternoon.add(medicine);
        } else if (hour >= 17 && hour < 21) {
          if (!evening.any((m) => m.id == medicine.id)) evening.add(medicine);
        } else {
          if (!night.any((m) => m.id == medicine.id)) night.add(medicine);
        }
      }
    }

    final sections = <Widget>[];

    if (morning.isNotEmpty) {
      sections.add(_buildTimeSection('🌅 Morning', morning));
      sections.add(const SizedBox(height: 16));
    }
    if (afternoon.isNotEmpty) {
      sections.add(_buildTimeSection('☀️ Afternoon', afternoon));
      sections.add(const SizedBox(height: 16));
    }
    if (evening.isNotEmpty) {
      sections.add(_buildTimeSection('🌇 Evening', evening));
      sections.add(const SizedBox(height: 16));
    }
    if (night.isNotEmpty) {
      sections.add(_buildTimeSection('🌙 Night', night));
      sections.add(const SizedBox(height: 16));
    }

    return sections;
  }

  Widget _buildTimeSection(String title, List<Medicine> medicines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...medicines.map((medicine) => _buildMedicineCard(medicine)),
      ],
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    // Get times for display (format the first time for now)
    final timeStr = medicine.times.isNotEmpty
        ? _formatTime(medicine.times.first)
        : '--:--';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getMedicineIcon(medicine.form),
            color: const Color(0xFF2196F3),
          ),
        ),
        title: Text(
          medicine.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${medicine.dosage} • $timeStr'),
            if (medicine.notes != null && medicine.notes!.isNotEmpty)
              Text(
                medicine.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.check_circle_outline,
            color: Colors.grey[400],
          ),
          onPressed: () {
            // TODO: Mark as taken
          },
        ),
      ),
    );
  }

  IconData _getMedicineIcon(MedicineForm form) {
    switch (form) {
      case MedicineForm.tablet:
      case MedicineForm.capsule:
        return Icons.medication;
      case MedicineForm.syrup:
        return Icons.local_drink;
      case MedicineForm.injection:
        return Icons.vaccines;
      case MedicineForm.drops:
        return Icons.water_drop;
      case MedicineForm.inhaler:
        return Icons.air;
      case MedicineForm.cream:
      case MedicineForm.ointment:
        return Icons.healing;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 21) return 'Evening';
    return 'Night';
  }
}
