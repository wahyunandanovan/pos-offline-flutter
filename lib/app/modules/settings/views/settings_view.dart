import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_offline/app/core/services/store_settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/auth_controller.dart';
import '../settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          // User Info Section
          CustomCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    user.fullName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isAdmin
                        ? AppTheme.error.withOpacity(0.1)
                        : AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      color: user.isAdmin ? AppTheme.error : AppTheme.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Store Settings Section (Admin Only)
          if (user.isAdmin) ...[
            const Text(
              'Pengaturan Toko',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            CustomCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: AppTheme.primaryLight,
                  ),
                ),
                title: const Text('Info Toko'),
                subtitle: const Text('Atur nama, alamat, dan logo toko'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showStoreSettingsDialog(context),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
          ],

          // Theme Section
          const Text(
            'Tampilan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),

          Obx(() => CustomCard(
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      ThemeMode.system,
                      'Sistem',
                      'Ikuti pengaturan sistem',
                      Icons.brightness_auto,
                    ),
                    const Divider(),
                    _buildThemeOption(
                      context,
                      ThemeMode.light,
                      'Terang',
                      'Mode terang',
                      Icons.light_mode,
                    ),
                    const Divider(),
                    _buildThemeOption(
                      context,
                      ThemeMode.dark,
                      'Gelap',
                      'Mode gelap',
                      Icons.dark_mode,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppTheme.spacing24),

          // App Info Section
          const Text(
            'Tentang Aplikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),

          CustomCard(
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.info_outline,
                  title: 'Versi',
                  subtitle: '1.3.0',
                ),
                const Divider(),
                _buildInfoTile(
                  icon: Icons.code,
                  title: 'Build',
                  subtitle: '2024.01',
                ),
                const Divider(),
                _buildInfoTile(
                  icon: Icons.developer_mode,
                  title: 'Developer',
                  subtitle: 'POS Offline Team',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreSettingsDialog(BuildContext context) {
    // Reset form
    controller.loadStoreSettings();
    controller.selectedLogoFile.value = null;

    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.store, color: AppTheme.primaryLight),
                    const SizedBox(width: AppTheme.spacing12),
                    const Expanded(
                      child: Text(
                        'Pengaturan Toko',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Logo Section
                _buildLogoSection(),
                const SizedBox(height: AppTheme.spacing24),

                // Store Name
                CustomTextField(
                  controller: controller.storeNameController,
                  label: 'Nama Toko *',
                  hintText: 'Masukkan nama toko',
                  prefixIcon: Icons.store,
                ),
                const SizedBox(height: AppTheme.spacing16),

                // Store Address
                CustomTextField(
                  controller: controller.storeAddressController,
                  label: 'Alamat',
                  hintText: 'Masukkan alamat toko',
                  prefixIcon: Icons.location_on,
                  maxLines: 2,
                ),
                const SizedBox(height: AppTheme.spacing16),

                // Store Phone
                CustomTextField(
                  controller: controller.storePhoneController,
                  label: 'Telepon',
                  hintText: 'Masukkan nomor telepon',
                  prefixIcon: Icons.phone,
                ),
                const SizedBox(height: AppTheme.spacing16),

                // Store Email
                CustomTextField(
                  controller: controller.storeEmailController,
                  label: 'Email',
                  hintText: 'Masukkan email',
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Save Button
                Obx(() => CustomButton(
                      text: 'Simpan Pengaturan',
                      onPressed: controller.saveStoreSettings,
                      isLoading: controller.isSavingSettings.value,
                      icon: Icons.save,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    final storeSettings = Get.find<StoreSettingsService>();

    return Obx(() {
      final selectedLogo = controller.selectedLogoFile.value;
      final existingLogo = storeSettings.storeLogoPath.value;
      final hasLogo = selectedLogo != null || existingLogo != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Logo Toko',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: hasLogo
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        child: selectedLogo != null
                            ? Image.file(
                                selectedLogo,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.contain,
                              )
                            : existingLogo != null
                                ? Image.file(
                                    File(existingLogo),
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.store,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: controller.removeStoreLogo,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Belum ada logo',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.pickStoreLogo(fromCamera: false),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Galeri'),
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.pickStoreLogo(fromCamera: true),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Kamera'),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = controller.currentThemeMode.value == mode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryLight : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryLight : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryLight)
          : null,
      onTap: () => controller.setThemeMode(mode),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
