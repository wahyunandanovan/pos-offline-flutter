import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../auth/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                authController.logout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(
                        user.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),

                    // Name
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacing8),

                    // Username
                    Text(
                      '@${user.username}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),

                    // Role Badge
                    CustomBadge(
                      text: user.role.toUpperCase(),
                      backgroundColor: user.isAdmin
                          ? AppTheme.error.withOpacity(0.1)
                          : AppTheme.info.withOpacity(0.1),
                      textColor: user.isAdmin ? AppTheme.error : AppTheme.info,
                      icon: user.isAdmin
                          ? Icons.admin_panel_settings
                          : Icons.person,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Info Cards
            _buildInfoCard(
              context,
              icon: Icons.email_outlined,
              title: 'Email',
              value: user.email ?? '-',
            ),
            _buildInfoCard(
              context,
              icon: Icons.phone_outlined,
              title: 'Telepon',
              value: user.phone ?? '-',
            ),
            _buildInfoCard(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Bergabung Sejak',
              value: DateFormat('dd MMMM yyyy', 'id_ID').format(user.createdAt),
            ),
            _buildInfoCard(
              context,
              icon: Icons.update_outlined,
              title: 'Terakhir Diupdate',
              value: DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                  .format(user.updatedAt),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Change Password Button
            CustomButton(
              text: 'Ubah Password',
              onPressed: () => _showChangePasswordDialog(context),
              icon: Icons.lock_outline,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: AppTheme.primaryLight),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final obscureCurrent = true.obs;
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Ubah Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrent.value,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            obscureCurrent.value = !obscureCurrent.value,
                      ),
                    ),
                  )),
              const SizedBox(height: AppTheme.spacing16),
              Obx(() => TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew.value,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => obscureNew.value = !obscureNew.value,
                      ),
                    ),
                  )),
              const SizedBox(height: AppTheme.spacing16),
              Obx(() => TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm.value,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            obscureConfirm.value = !obscureConfirm.value,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final current = currentPasswordController.text;
              final newPass = newPasswordController.text;
              final confirm = confirmPasswordController.text;

              if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                Get.snackbar('Error', 'Semua field harus diisi',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              if (newPass.length < 6) {
                Get.snackbar('Error', 'Password baru minimal 6 karakter',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              if (newPass != confirm) {
                Get.snackbar('Error', 'Password baru tidak cocok',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              final authController = Get.find<AuthController>();
              final user = authController.currentUser.value!;

              if (current != user.password) {
                Get.snackbar('Error', 'Password lama salah',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              // Update password
              final authRepository = authController.repository;
              authRepository.updatePassword(user.id!, newPass).then((success) {
                if (success) {
                  Get.back();
                  Get.snackbar('Berhasil', 'Password berhasil diubah',
                      backgroundColor: Colors.green, colorText: Colors.white);
                } else {
                  Get.snackbar('Error', 'Gagal mengubah password',
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
              });
            },
            child: const Text('Ubah Password'),
          ),
        ],
      ),
    );
  }
}
