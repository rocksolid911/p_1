import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'infrastructure/alarm/native_alarm_scheduler.dart';
import 'infrastructure/firebase/firebase_auth_repository.dart';
import 'infrastructure/firebase/firebase_medicine_repository.dart';
import 'infrastructure/firebase/firebase_reminder_log_repository.dart';
import 'infrastructure/firebase/firebase_analytics_service.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/medicine/medicine_cubit.dart';
import 'presentation/cubits/reminder_log/reminder_log_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize timezone data for alarms
  tz.initializeTimeZones();

  // Initialize alarm scheduler
  final alarmScheduler = NativeAlarmScheduler();
  await alarmScheduler.initialize();

  // Request notification permissions
  await alarmScheduler.requestAlarmPermissions();

  // Initialize repositories
  final authRepository = FirebaseAuthRepository();
  final medicineRepository = FirebaseMedicineRepository();
  final reminderLogRepository = FirebaseReminderLogRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: alarmScheduler),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: medicineRepository),
        RepositoryProvider.value(value: reminderLogRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepository),
          ),
          BlocProvider<MedicineCubit>(
            create: (context) => MedicineCubit(medicineRepository),
          ),
          BlocProvider<ReminderLogCubit>(
            create: (context) => ReminderLogCubit(reminderLogRepository),
          ),
        ],
        child: const MedicineReminderApp(),
      ),
    ),
  );
}

class MedicineReminderApp extends StatelessWidget {
  const MedicineReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsService = FirebaseAnalyticsService();

    return MaterialApp(
      title: 'Medicine Reminder',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [analyticsService.analyticsObserver],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
