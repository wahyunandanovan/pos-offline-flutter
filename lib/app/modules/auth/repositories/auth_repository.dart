import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider;

  AuthRepository(this._provider);

  Future<UserModel?> login(String username, String password) async {
    return await _provider.login(username, password);
  }

  Future<String> createSession(int userId) async {
    return await _provider.createSession(userId);
  }

  Future<Map<String, dynamic>?> getSession(String token) async {
    return await _provider.getSession(token);
  }

  Future<void> logout(String token) async {
    await _provider.deleteSession(token);
  }

  Future<UserModel?> getUserById(int userId) async {
    return await _provider.getUserById(userId);
  }

  Future<bool> updatePassword(int userId, String newPassword) async {
    return await _provider.updatePassword(userId, newPassword);
  }
}
