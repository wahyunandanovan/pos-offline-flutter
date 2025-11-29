import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../product_controller.dart';

class ProductFormView extends GetView<ProductController> {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = controller.editingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE UPLOAD SECTION
            _buildImageUploadSection(context),
            const SizedBox(height: AppTheme.spacing24),

            CustomTextField(
              controller: controller.skuController,
              label: 'SKU',
              hintText: 'Kode unik produk',
              prefixIcon: Icons.qr_code,
              enabled: !isEdit,
            ),
            const SizedBox(height: AppTheme.spacing16),

            CustomTextField(
              controller: controller.nameController,
              label: 'Nama Produk *',
              hintText: 'Masukkan nama produk',
              prefixIcon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: AppTheme.spacing16),

            CustomTextField(
              controller: controller.descriptionController,
              label: 'Deskripsi',
              hintText: 'Deskripsi produk (opsional)',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacing16),

            _buildCategorySelect(context),
            const SizedBox(height: AppTheme.spacing16),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.buyPriceController,
                    label: 'Harga Beli *',
                    hintText: '0',
                    prefixIcon: Icons.shopping_cart_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: CustomTextField(
                    controller: controller.sellPriceController,
                    label: 'Harga Jual *',
                    hintText: '0',
                    prefixIcon: Icons.sell_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.stockController,
                    label: 'Stok',
                    hintText: '0',
                    prefixIcon: Icons.inventory_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: CustomTextField(
                    controller: controller.minStockController,
                    label: 'Stok Minimal',
                    hintText: '0',
                    prefixIcon: Icons.warning_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),

            CustomTextField(
              controller: controller.barcodeController,
              label: 'Barcode',
              hintText: 'Kode barcode (opsional)',
              prefixIcon: Icons.barcode_reader,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTheme.spacing32),

            Obx(() => CustomButton(
                  text: isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                  onPressed: controller.saveProduct,
                  isLoading: controller.isSaving.value,
                  icon: Icons.save,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    return Obx(() {
      final selectedImage = controller.selectedImageFile.value;
      final existingImage = controller.existingImagePath.value;
      final hasImage = selectedImage != null || existingImage != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gambar Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),

          // Image Preview
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      // Image Display
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        child: selectedImage != null
                            ? Image.file(
                                selectedImage,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : existingImage != null
                                ? Image.file(
                                    File(existingImage),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(),
                      ),

                      // Remove Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: controller.removeProductImage,
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Belum ada gambar',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Upload Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.pickProductImage(fromCamera: false),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.pickProductImage(fromCamera: true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildCategorySelect(BuildContext context) {
    return Obx(() {
      final categories = controller.categories;
      final selectedCategory = controller.selectedFormCategory.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 20),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'Kategori',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _showCategoryDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedCategory ?? 'Pilih atau buat kategori baru',
                            style: TextStyle(
                              color: selectedCategory == null
                                  ? Colors.grey
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                if (categories.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing8),
                    child: Wrap(
                      spacing: AppTheme.spacing8,
                      runSpacing: AppTheme.spacing8,
                      children: categories.take(5).map((category) {
                        final isSelected = selectedCategory == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            controller.selectedFormCategory.value =
                                selected ? category : null;
                            controller.categoryController.text =
                                selected ? category : '';
                          },
                          backgroundColor: Theme.of(context).cardColor,
                          selectedColor: AppTheme.primaryLight.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryLight,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showCategoryDialog(BuildContext context) {
    final newCategoryController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Pilih atau Buat Kategori'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: newCategoryController,
                decoration: InputDecoration(
                  labelText: 'Kategori Baru',
                  hintText: 'Ketik nama kategori baru',
                  prefixIcon: const Icon(Icons.add),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppTheme.spacing8),
              ElevatedButton.icon(
                onPressed: () {
                  if (newCategoryController.text.trim().isNotEmpty) {
                    controller
                        .createNewCategory(newCategoryController.text.trim());
                    Get.back();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Buat Kategori Baru'),
              ),
              const SizedBox(height: AppTheme.spacing16),
              if (controller.categories.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Pilih dari Kategori yang Ada:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spacing8),
                SizedBox(
                  height: 200,
                  child: Obx(() => ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.categories.length,
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          final isSelected =
                              controller.selectedFormCategory.value == category;

                          return ListTile(
                            title: Text(category),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryLight,
                                  )
                                : null,
                            selected: isSelected,
                            onTap: () {
                              controller.selectedFormCategory.value = category;
                              controller.categoryController.text = category;
                              Get.back();
                            },
                          );
                        },
                      )),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}
