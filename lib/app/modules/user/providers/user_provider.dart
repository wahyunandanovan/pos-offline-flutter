import 'package:sqflite/sqflite.dart';
import '../../../core/utils/db_helper.dart';
import '../../auth/models/user_model.dart';

class UserProvider {
  Future<Database> get _db async => await DBHelper.instance.database;

  Future<List<UserModel>> getAllUsers() async {
    final db = await _db;
    final results = await db.query('users', orderBy: 'createdAt DESC');
    return results.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await _db;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  Future<int> insertUser(UserModel user) async {
    final db = await _db;
    return await db.insert('users', user.toMap());
  }

  Future<int> updateUser(UserModel user) async {
    final db = await _db;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _db;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final db = await _db;
    final results = await db.query(
      'users',
      where: 'username LIKE ? OR fullName LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return results.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<bool> usernameExists(String username, {int? excludeId}) async {
    final db = await _db;
    final where =
        excludeId != null ? 'username = ? AND id != ?' : 'username = ?';
    final whereArgs = excludeId != null ? [username, excludeId] : [username];

    final results = await db.query('users', where: where, whereArgs: whereArgs);
    return results.isNotEmpty;
  }
}
