import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../routes/app_routes.dart';
import '../product_controller.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import CSV',
            onPressed: () => Get.toNamed(AppRoutes.IMPORT_PRODUCT),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadProducts(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: CustomTextField(
              hintText: 'Cari produk (nama, SKU, barcode)...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (controller.searchQuery.value == value) {
                    controller.searchProducts(value);
                  }
                });
                controller.searchQuery.value = value;
              },
            ),
          ),

          // Category Filter
          Obx(() {
            if (controller.categories.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              height: 50,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(
                    context,
                    label: 'Semua',
                    isSelected: controller.selectedCategory.value == null,
                    onTap: () => controller.filterByCategory(null),
                  ),
                  ...controller.categories.map((category) {
                    return _buildCategoryChip(
                      context,
                      label: category,
                      isSelected: controller.selectedCategory.value == category,
                      onTap: () => controller.filterByCategory(category),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: AppTheme.spacing8),

          // Product List/Grid with Infinite Scroll
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredProducts.isEmpty) {
                return EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Tidak ada produk',
                  message: controller.searchQuery.value.isEmpty
                      ? 'Belum ada produk yang ditambahkan'
                      : 'Produk tidak ditemukan',
                  actionText: controller.searchQuery.value.isEmpty
                      ? 'Tambah Produk'
                      : null,
                  onAction: controller.searchQuery.value.isEmpty
                      ? () {
                          controller.prepareCreate();
                          Get.toNamed(AppRoutes.PRODUCT_FORM);
                        }
                      : null,
                );
              }

              if (isTablet) {
                return _buildGridView();
              } else {
                return _buildListView();
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepareCreate();
          Get.toNamed(AppRoutes.PRODUCT_FORM);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: AppTheme.primaryLight.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryLight,
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: controller.filteredProducts.length +
          (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at bottom
        if (index == controller.filteredProducts.length) {
          return Obx(() => controller.isLoadingMore.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacing16),
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink());
        }

        final product = controller.filteredProducts[index];
        return _buildProductListItem(context, product);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppTheme.spacing16,
        mainAxisSpacing: AppTheme.spacing16,
      ),
      itemCount: controller.filteredProducts.length +
          (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at bottom
        if (index == controller.filteredProducts.length) {
          return Obx(() => controller.isLoadingMore.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink());
        }

        final product = controller.filteredProducts[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductListItem(BuildContext context, product) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacing12),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacing4),
            Text('SKU: ${product.sku}'),
            if (product.category != null) Text('Kategori: ${product.category}'),
            const SizedBox(height: AppTheme.spacing4),
            Row(
              children: [
                Text(
                  controller.currencyFormat.format(product.sellPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing8),
                // CustomBadge(
                //   text: 'Stok: ${product.stock}',
                //   backgroundColor: product.isLowStock
                //       ? AppTheme.error.withOpacity(0.1)
                //       : AppTheme.success.withOpacity(0.1),
                //   textColor:
                //       product.isLowStock ? AppTheme.error : AppTheme.success,
                // ),
                const SizedBox(width: AppTheme.spacing8),
                if (product.soldQuantity > 0)
                  CustomBadge(
                    text: 'Terjual: ${product.soldQuantity}',
                    backgroundColor: AppTheme.info.withOpacity(0.1),
                    textColor: AppTheme.info,
                    icon: Icons.trending_up,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(context, value, product),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, product) {
    return Card(
      child: InkWell(
        onTap: () {
          controller.prepareEdit(product);
          Get.toNamed(AppRoutes.PRODUCT_FORM);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                product.sku,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.currencyFormat.format(product.sellPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  CustomBadge(
                    text: '${product.stock}',
                    backgroundColor: product.isLowStock
                        ? AppTheme.error.withOpacity(0.1)
                        : AppTheme.success.withOpacity(0.1),
                    textColor:
                        product.isLowStock ? AppTheme.error : AppTheme.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, value, product) async {
    switch (value) {
      case 'edit':
        controller.prepareEdit(product);
        Get.toNamed(AppRoutes.PRODUCT_FORM);
        break;
      case 'delete':
        final confirm = await ConfirmDialog.show(
          context: context,
          title: 'Hapus Produk',
          message: 'Apakah Anda yakin ingin menghapus ${product.name}?',
          isDanger: true,
        );
        if (confirm == true) {
          controller.deleteProduct(product);
        }
        break;
    }
  }
}
