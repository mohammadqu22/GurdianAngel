import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  // Get or create the database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'guardian_angel.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // User Settings table
    await db.execute('''
      CREATE TABLE User_Settings (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        language_pref TEXT DEFAULT 'en',
        is_first_run INTEGER DEFAULT 1
      )
    ''');

    // Emergency Contact table
    await db.execute('''
      CREATE TABLE Emergency_Contact (
        contact_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES User_Settings(user_id)
      )
    ''');

    // Incident Log table
    await db.execute('''
      CREATE TABLE Incident_Log (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        timestamp TEXT NOT NULL,
        emergency_type TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES User_Settings(user_id)
      )
    ''');

    // Insert default user settings on first run
    await db.insert('User_Settings', {
      'language_pref': 'en',
      'is_first_run': 1,
    });
  }

  // ─── User Settings ───────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserSettings() async {
    final db = await database;
    final results = await db.query('User_Settings', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  static Future<void> updateLanguage(String langCode) async {
    final db = await database;
    await db.update(
      'User_Settings',
      {'language_pref': langCode},
      where: 'user_id = ?',
      whereArgs: [1],
    );
  }

  // ─── Emergency Contact ───────────────────────────────────

  static Future<void> saveEmergencyContact(String name, String phone) async {
    final db = await database;
    // Delete old contact first (only one contact supported for now)
    await db.delete('Emergency_Contact');
    await db.insert('Emergency_Contact', {
      'user_id': 1,
      'name': name,
      'phone_number': phone,
    });
  }

  static Future<Map<String, dynamic>?> getEmergencyContact() async {
    final db = await database;
    final results = await db.query('Emergency_Contact', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  static Future<void> deleteEmergencyContact() async {
    final db = await database;
    await db.delete('Emergency_Contact');
  }

  // ─── Incident Log ─────────────────────────────────────────

  static Future<void> logIncident(String emergencyType) async {
    final db = await database;
    await db.insert('Incident_Log', {
      'user_id': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'emergency_type': emergencyType,
    });
  }

  static Future<List<Map<String, dynamic>>> getIncidentLog() async {
    final db = await database;
    return await db.query(
      'Incident_Log',
      orderBy: 'timestamp DESC',
    );
  }

  static Future<void> clearIncidentLog() async {
    final db = await database;
    await db.delete('Incident_Log');
  }
}