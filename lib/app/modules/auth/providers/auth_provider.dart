import 'package:sqflite/sqflite.dart';
import '../../../core/utils/db_helper.dart';
import '../models/user_model.dart';

class AuthProvider {
  Future<Database> get _db async => await DBHelper.instance.database;

  /// Login dengan username & password
  Future<UserModel?> login(String username, String password) async {
    final db = await _db;
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ? AND isActive = 1',
      whereArgs: [username, password],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  /// Create session
  Future<String> createSession(int userId) async {
    final db = await _db;
    final token = DateTime.now().millisecondsSinceEpoch.toString();
    final expiresAt = DateTime.now().add(const Duration(days: 30));

    await db.insert('sessions', {
      'userId': userId,
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });

    return token;
  }

  /// Get session
  Future<Map<String, dynamic>?> getSession(String token) async {
    final db = await _db;
    final results = await db.query(
      'sessions',
      where: 'token = ? AND expiresAt > ?',
      whereArgs: [token, DateTime.now().toIso8601String()],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Delete session (logout)
  Future<void> deleteSession(String token) async {
    final db = await _db;
    await db.delete('sessions', where: 'token = ?', whereArgs: [token]);
  }

  /// Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    final db = await _db;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  /// Update password
  Future<bool> updatePassword(int userId, String newPassword) async {
    final db = await _db;
    final count = await db.update(
      'users',
      {
        'password': newPassword,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }
}
