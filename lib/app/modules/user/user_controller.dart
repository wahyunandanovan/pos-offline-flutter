import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/models/user_model.dart';
import 'repositories/user_repository.dart';

class UserController extends GetxController {
  final UserRepository repository;

  UserController(this.repository);

  // Observable lists
  final users = <UserModel>[].obs;
  final filteredUsers = <UserModel>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Form state
  final selectedRole = 'kasir'.obs;
  final isActive = true.obs;
  final searchQuery = ''.obs;

  // Edit mode
  UserModel? editingUser;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Load all users
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final result = await repository.getAllUsers();
      users.value = result;
      filteredUsers.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search users
  void searchUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users
          .where((user) =>
              user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.fullName.toLowerCase().contains(query.toLowerCase()) ||
              (user.email?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    }
  }

  /// Prepare form for creating new user
  void prepareCreate() {
    editingUser = null;
    usernameController.clear();
    passwordController.clear();
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    selectedRole.value = 'kasir';
    isActive.value = true;
  }

  /// Prepare form for editing user
  void prepareEdit(UserModel user) {
    editingUser = user;
    usernameController.text = user.username;
    passwordController.text = ''; // Don't show password
    fullNameController.text = user.fullName;
    emailController.text = user.email ?? '';
    phoneController.text = user.phone ?? '';
    selectedRole.value = user.role;
    isActive.value = user.isActive;
  }

  /// Validate form
  String? validateForm() {
    if (usernameController.text.trim().isEmpty) {
      return 'Username harus diisi';
    }
    if (editingUser == null && passwordController.text.isEmpty) {
      return 'Password harus diisi untuk user baru';
    }
    if (fullNameController.text.trim().isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    if (fullNameController.text.trim().length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    if (usernameController.text.trim().length < 3) {
      return 'Username minimal 3 karakter';
    }
    if (editingUser == null && passwordController.text.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Save user (create or update)
  Future<void> saveUser() async {
    final error = validateForm();
    if (error != null) {
      Get.snackbar('Error', error,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;

      // Check if username already exists
      final usernameExists = await repository.usernameExists(
        usernameController.text.trim(),
        excludeId: editingUser?.id,
      );

      if (usernameExists) {
        Get.snackbar('Error', 'Username sudah digunakan',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final now = DateTime.now();
      final user = UserModel(
        id: editingUser?.id,
        username: usernameController.text.trim(),
        password: passwordController.text.isNotEmpty
            ? passwordController.text
            : editingUser!.password,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        phone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        role: selectedRole.value,
        isActive: isActive.value,
        createdAt: editingUser?.createdAt ?? now,
        updatedAt: now,
      );

      if (editingUser == null) {
        await repository.createUser(user);
        Get.snackbar('Berhasil', 'User berhasil ditambahkan',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        await repository.updateUser(user);
        Get.snackbar('Berhasil', 'User berhasil diupdate',
            backgroundColor: Colors.green, colorText: Colors.white);
      }

      await loadUsers();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan user: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete user
  Future<void> deleteUser(UserModel user) async {
    try {
      await repository.deleteUser(user.id!);
      Get.snackbar('Berhasil', 'User berhasil dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      await loadUsers();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus user: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Toggle user active status
  Future<void> toggleUserStatus(UserModel user) async {
    try {
      final updatedUser = user.copyWith(
        isActive: !user.isActive,
        updatedAt: DateTime.now(),
      );
      await repository.updateUser(updatedUser);
      await loadUsers();
      Get.snackbar(
        'Berhasil',
        user.isActive ? 'User dinonaktifkan' : 'User diaktifkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status user: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
