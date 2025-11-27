import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import 'models/user_model.dart';
import 'repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository repository;

  AuthController(this.repository);

  // Observables
  final currentUser = Rxn<UserModel>();
  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Form state
  final obscurePassword = true.obs;
  final rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Check if user already logged in
  Future<void> checkLoginStatus() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      final token = prefs.getString('session_token');

      if (token != null) {
        final session = await repository.getSession(token);
        if (session != null) {
          final user = await repository.getUserById(session['userId']);
          if (user != null) {
            currentUser.value = user;
            isLoggedIn.value = true;
            return;
          }
        }
      }

      isLoggedIn.value = false;
    } catch (e) {
      isLoggedIn.value = false;
      debugPrint('Error checking login status: $e');
    }
  }

  /// Login
  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Username dan password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = await repository.login(
        usernameController.text.trim(),
        passwordController.text,
      );

      if (user != null) {
        // Create session
        final token = await repository.createSession(user.id!);

        // Save to SharedPreferences
        final prefs = Get.find<SharedPreferences>();
        await prefs.setString('session_token', token);
        if (rememberMe.value) {
          await prefs.setString('last_username', user.username);
        }

        currentUser.value = user;
        isLoggedIn.value = true;

        Get.snackbar(
          'Berhasil',
          'Selamat datang, ${user.fullName}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to home
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        Get.snackbar(
          'Error',
          'Username atau password salah',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      final token = prefs.getString('session_token');

      if (token != null) {
        await repository.logout(token);
        await prefs.remove('session_token');
      }

      currentUser.value = null;
      isLoggedIn.value = false;

      Get.offAllNamed(AppRoutes.LOGIN);

      Get.snackbar(
        'Berhasil',
        'Anda telah logout',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat logout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Forgot password (simulasi offline)
  Future<void> forgotPassword(String username) async {
    if (username.isEmpty) {
      Get.snackbar(
        'Error',
        'Username harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Simulasi reset password offline
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'Untuk reset password offline, silakan hubungi administrator.\n\n'
          'Username: $username',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Switch user (untuk testing)
  Future<void> switchUser(String username) async {
    try {
      // Logout current user
      final prefs = Get.find<SharedPreferences>();
      final token = prefs.getString('session_token');
      if (token != null) {
        await repository.logout(token);
      }

      // Set username for login
      usernameController.text = username;

      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      debugPrint('Error switching user: $e');
    }
  }
}
