import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static String _currentUserName = 'Unknown User';
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'your_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        vin TEXT UNIQUE NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<Map<String, dynamic>?> verifyUserCredentials(String email,
      String vin) async {
    try {
      final db = await database;
      final result = await db.query(
        'Users',
        where: 'email = ? AND vin = ?',
        whereArgs: [email, vin],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error verifying credentials: $e');
      rethrow;
    }
  }

  // Updated password change method with additional validation
  Future<int> updateUserPassword({
    required String email,
    required String vin,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final db = await database;

      // First verify the current credentials
      final user = await verifyUserCredentials(email, vin);
      if (user == null) {
        throw Exception('User not found');
      }

      // Verify current password matches
      if (user['password'] != currentPassword) {
        throw Exception('Current password is incorrect');
      }

      // Update the password
      return await db.update(
        'Users',
        {'password': newPassword},
        where: 'email = ? AND vin = ?',
        whereArgs: [email, vin],
      );
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  // Add this method for forgot password flow (no current password required)
  Future<int> resetUserPassword({
    required String email,
    required String vin,
    required String newPassword,
  }) async {
    try {
      final db = await database;

      // Verify user exists
      final userExists = await verifyUserCredentials(email, vin);
      if (userExists == null) {
        throw Exception('User not found');
      }

      // Update the password
      return await db.update(
        'Users',
        {'password': newPassword},
        where: 'email = ? AND vin = ?',
        whereArgs: [email, vin],
      );
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final db = await database;
      final result = await db.query(
        'Users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking email: $e');
      rethrow;
    }
  }

  Future<bool> checkVinExists(String vin) async {
    try {
      final db = await database;
      final result = await db.query(
        'Users',
        where: 'vin = ?',
        whereArgs: [vin],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking VIN: $e');
      rethrow;
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    try {
      final db = await database;
      return await db.insert('Users', user);
    } catch (e) {
      debugPrint('Error inserting user: $e');
      rethrow;
    }
  }
  // Call this after successful login or when you have the user's info
  static Future<void> cacheCurrentUserName(String email) async {
    try {
      final db = await _instance.database;
      final result = await db.query(
        'Users',
        columns: ['fullName'],
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (result.isNotEmpty) {
        _currentUserName = result.first['fullName'] as String;
      }
    } catch (e) {
      debugPrint('Error caching user name: $e');
      _currentUserName = 'Unknown User';
    }
  }

// Use this in your emergency page to get the name
  static String get senderName => _currentUserName;
}