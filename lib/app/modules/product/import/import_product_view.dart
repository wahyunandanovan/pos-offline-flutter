// lib/app/modules/product/import/import_product_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import 'import_product_controller.dart';

class ImportProductView extends GetView<ImportProductController> {
  const ImportProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Produk dari CSV'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.info),
                      SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Cara Import Produk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  const Text('1. Download template CSV'),
                  const SizedBox(height: AppTheme.spacing8),
                  const Text('2. Isi data produk sesuai kolom yang tersedia'),
                  const SizedBox(height: AppTheme.spacing8),
                  const Text('3. Simpan file sebagai CSV'),
                  const SizedBox(height: AppTheme.spacing8),
                  const Text('4. Pilih file CSV dan import'),
                  const SizedBox(height: AppTheme.spacing16),
                  CustomButton(
                    text: 'Download Template',
                    onPressed: controller.downloadTemplate,
                    icon: Icons.download,
                    isOutlined: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // File Picker
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pilih File CSV',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Obx(() => controller.fileName.value.isEmpty
                      ? CustomButton(
                          text: 'Pilih File CSV',
                          onPressed: controller.pickCSVFile,
                          icon: Icons.upload_file,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacing16),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppTheme.success),
                                  const SizedBox(width: AppTheme.spacing12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'File dipilih:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          controller.fileName.value,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            CustomButton(
                              text: 'Pilih File Lain',
                              onPressed: controller.pickCSVFile,
                              icon: Icons.upload_file,
                              isOutlined: true,
                            ),
                          ],
                        )),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Preview & Statistics
            Obx(() {
              if (controller.totalRows.value == 0) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistik Import',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        _buildStatRow(
                          'Total baris',
                          '${controller.totalRows.value}',
                          Icons.format_list_numbered,
                          AppTheme.info,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Valid',
                          '${controller.successCount.value}',
                          Icons.check_circle,
                          AppTheme.success,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Error',
                          '${controller.errorCount.value}',
                          Icons.error,
                          AppTheme.error,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Error List
                  if (controller.importErrors.isNotEmpty) ...[
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning, color: AppTheme.warning),
                              SizedBox(width: AppTheme.spacing8),
                              Text(
                                'Error Ditemukan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          ...controller.importErrors.take(5).map((error) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacing4,
                              ),
                              child: Text(
                                '• $error',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.error,
                                ),
                              ),
                            );
                          }),
                          if (controller.importErrors.length > 5)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: AppTheme.spacing8),
                              child: Text(
                                '... dan ${controller.importErrors.length - 5} error lainnya',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                  ],

                  // Import Button
                  Obx(() => CustomButton(
                        text: 'Import ${controller.successCount.value} Produk',
                        onPressed: controller.successCount.value > 0
                            ? () => _showConfirmDialog(context)
                            : null,
                        isLoading: controller.isImporting.value,
                        icon: Icons.upload,
                      )),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Text(label),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Import'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Akan mengimport ${controller.successCount.value} produk.'),
            if (controller.errorCount.value > 0)
              Text(
                '\n${controller.errorCount.value} baris akan dilewati karena error.',
                style: const TextStyle(color: AppTheme.warning),
              ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Produk dengan SKU yang sudah ada akan dilewati.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.importProducts();
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
