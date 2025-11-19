import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database helper for offline storage
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicine_reminder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Medicines table
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        form TEXT NOT NULL,
        scheduleType TEXT NOT NULL,
        times TEXT NOT NULL,
        intervalHours INTEGER,
        daysOfWeek TEXT,
        startDate INTEGER NOT NULL,
        endDate INTEGER,
        notes TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Reminder logs table
    await db.execute('''
      CREATE TABLE reminder_logs (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        medicineId TEXT NOT NULL,
        scheduledTime INTEGER NOT NULL,
        actualTakenTime INTEGER,
        status TEXT NOT NULL,
        notes TEXT,
        createdAt INTEGER NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Pending alarms table (to track scheduled alarms)
    await db.execute('''
      CREATE TABLE pending_alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId TEXT NOT NULL,
        alarmId INTEGER NOT NULL,
        scheduledTime INTEGER NOT NULL,
        medicineName TEXT NOT NULL,
        dosage TEXT NOT NULL,
        notes TEXT,
        UNIQUE(medicineId, scheduledTime)
      )
    ''');

    // Create indices for better query performance
    await db.execute(
      'CREATE INDEX idx_medicines_userId ON medicines(userId)',
    );
    await db.execute(
      'CREATE INDEX idx_medicines_isActive ON medicines(isActive)',
    );
    await db.execute(
      'CREATE INDEX idx_logs_userId ON reminder_logs(userId)',
    );
    await db.execute(
      'CREATE INDEX idx_logs_medicineId ON reminder_logs(medicineId)',
    );
    await db.execute(
      'CREATE INDEX idx_logs_scheduledTime ON reminder_logs(scheduledTime)',
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here in future versions
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('medicines');
    await db.delete('reminder_logs');
    await db.delete('pending_alarms');
  }
}
