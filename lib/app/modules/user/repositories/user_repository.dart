// lib/app/modules/user/repositories/user_repository.dart
import '../../auth/models/user_model.dart';
import '../providers/user_provider.dart';

class UserRepository {
  final UserProvider _provider;

  UserRepository(this._provider);

  Future<List<UserModel>> getAllUsers() async {
    return await _provider.getAllUsers();
  }

  Future<UserModel?> getUserById(int id) async {
    return await _provider.getUserById(id);
  }

  Future<int> createUser(UserModel user) async {
    return await _provider.insertUser(user);
  }

  Future<int> updateUser(UserModel user) async {
    return await _provider.updateUser(user);
  }

  Future<int> deleteUser(int id) async {
    return await _provider.deleteUser(id);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    return await _provider.searchUsers(query);
  }

  Future<bool> usernameExists(String username, {int? excludeId}) async {
    return await _provider.usernameExists(username, excludeId: excludeId);
  }
}
