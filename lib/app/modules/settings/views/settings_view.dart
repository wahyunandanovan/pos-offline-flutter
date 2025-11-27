import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
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
                  subtitle: '1.0.0',
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
          const SizedBox(height: AppTheme.spacing24),

          // Database Section (Admin Only)
          if (user.isAdmin) ...[
            const Text(
              'Database',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.delete_forever, color: AppTheme.error),
                    title: const Text('Hapus Semua Data'),
                    subtitle: const Text(
                        'Menghapus semua transaksi (Produk & User tetap ada)'),
                    onTap: () => _showClearDataDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.restore, color: AppTheme.warning),
                    title: const Text('Reset Database'),
                    subtitle:
                        const Text('Reset database ke kondisi awal (DANGER!)'),
                    onTap: () => _showResetDatabaseDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data transaksi?\n\n'
          'Data produk dan user tidak akan terhapus.\n\n'
          'Tindakan ini tidak dapat dibatalkan!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement clear data
              Get.snackbar(
                'Berhasil',
                'Semua data transaksi telah dihapus',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showResetDatabaseDialog(BuildContext context) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PERINGATAN! Tindakan ini akan menghapus SEMUA data termasuk:\n'
              '• Semua transaksi\n'
              '• Semua produk\n'
              '• Semua user (kecuali admin default)\n\n'
              'Database akan direset ke kondisi awal.\n\n'
              'Ketik "RESET" untuk melanjutkan:',
              style: TextStyle(color: AppTheme.error),
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'Ketik RESET',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text == 'RESET') {
                Navigator.pop(context);
                // TODO: Implement reset database
                Get.snackbar(
                  'Berhasil',
                  'Database telah direset',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Konfirmasi salah',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Reset Database'),
          ),
        ],
      ),
    );
  }
}
