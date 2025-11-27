import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../user_controller.dart';

class UserFormView extends GetView<UserController> {
  const UserFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = controller.editingUser != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit User' : 'Tambah User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username
            CustomTextField(
              controller: controller.usernameController,
              label: 'Username',
              hintText: 'Masukkan username',
              prefixIcon: Icons.person_outline,
              enabled: !isEdit, // Username tidak bisa diubah saat edit
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Password
            CustomTextField(
              controller: controller.passwordController,
              label: isEdit
                  ? 'Password Baru (kosongkan jika tidak diubah)'
                  : 'Password',
              hintText: 'Masukkan password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Full Name
            CustomTextField(
              controller: controller.fullNameController,
              label: 'Nama Lengkap',
              hintText: 'Masukkan nama lengkap',
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Email
            CustomTextField(
              controller: controller.emailController,
              label: 'Email (opsional)',
              hintText: 'Masukkan email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Phone
            CustomTextField(
              controller: controller.phoneController,
              label: 'Telepon (opsional)',
              hintText: 'Masukkan nomor telepon',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Role
            Obx(() => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Role',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        RadioListTile<String>(
                          title: const Text('Admin'),
                          subtitle: const Text('Akses penuh ke semua fitur'),
                          value: 'admin',
                          groupValue: controller.selectedRole.value,
                          onChanged: (value) {
                            controller.selectedRole.value = value!;
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Kasir'),
                          subtitle:
                              const Text('Akses terbatas untuk transaksi'),
                          value: 'kasir',
                          groupValue: controller.selectedRole.value,
                          onChanged: (value) {
                            controller.selectedRole.value = value!;
                          },
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: AppTheme.spacing16),

            // Status
            Obx(() => Card(
                  child: SwitchListTile(
                    title: const Text('Status Aktif'),
                    subtitle: Text(
                      controller.isActive.value
                          ? 'User dapat login ke sistem'
                          : 'User tidak dapat login',
                    ),
                    value: controller.isActive.value,
                    onChanged: (value) {
                      controller.isActive.value = value;
                    },
                  ),
                )),
            const SizedBox(height: AppTheme.spacing32),

            // Save Button
            Obx(() => CustomButton(
                  text: isEdit ? 'Simpan Perubahan' : 'Tambah User',
                  onPressed: controller.saveUser,
                  isLoading: controller.isSaving.value,
                  icon: Icons.save,
                )),
          ],
        ),
      ),
    );
  }
}
