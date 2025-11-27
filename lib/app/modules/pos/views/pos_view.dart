import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../pos_controller.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          // Cart badge
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed:
                        isTablet ? null : () => _showCartBottomSheet(context),
                  ),
                  if (controller.cartItems.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${controller.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadProducts(refresh: true),
          ),
        ],
      ),
      body: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildProductCatalog(),
        ),
        Container(
          width: 420,
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            boxShadow: AppTheme.shadowMedium,
          ),
          child: _buildCartSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: _buildProductCatalog(),
        ),
        Obx(() => controller.cartItems.isEmpty
            ? const SizedBox.shrink()
            : _buildCartSummaryBar()),
      ],
    );
  }

  Widget _buildProductCatalog() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: CustomTextField(
            hintText: 'Cari produk...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (controller.searchQuery.value == value) {
                  controller.searchProducts(value);
                }
              });
              controller.searchQuery.value = value;
            },
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredProducts.isEmpty) {
              return const Center(child: Text('Tidak ada produk'));
            }

            return GridView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    Get.width > 1200 ? 4 : (Get.width > 800 ? 3 : 2),
                childAspectRatio: 0.75,
                crossAxisSpacing: AppTheme.spacing12,
                mainAxisSpacing: AppTheme.spacing12,
              ),
              itemCount: controller.filteredProducts.length +
                  (controller.hasMoreData.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.filteredProducts.length) {
                  return Obx(() => controller.isLoadingMore.value
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink());
                }

                final product = controller.filteredProducts[index];
                return _buildProductCard(product);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductCard(product) {
    return Card(
      child: InkWell(
        onTap: () => controller.addToCart(product),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
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
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                controller.currencyFormat.format(product.sellPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primaryLight,
                ),
              ),
              Text(
                'Stok: ${product.stock}',
                style: TextStyle(
                  fontSize: 12,
                  color: product.isLowStock ? AppTheme.error : AppTheme.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    return Column(
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Keranjang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${controller.cartItems.length} produk',
                        style: const TextStyle(color: AppTheme.primaryLight),
                      ),
                      Text(
                        '${controller.totalItems} item',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),

        // Cart Items List
        Expanded(
          child: Obx(() {
            if (controller.cartItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Keranjang Kosong',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pilih produk untuk memulai',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: controller.cartItems.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = controller.cartItems[index];
                return _buildCartItem(item);
              },
            );
          }),
        ),

        // Cart Summary & Checkout
        Obx(() => controller.cartItems.isEmpty
            ? const SizedBox.shrink()
            : _buildCheckoutSection()),
      ],
    );
  }

  Widget _buildCartItem(item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Info & Remove
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${item.product.sku}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.currencyFormat.format(item.price),
                    style: const TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Remove Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: () => controller.removeFromCart(item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),

        // Quantity Controls & Subtotal
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Row(
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => controller.updateQuantity(
                        item,
                        item.quantity - 1,
                      ),
                      color: AppTheme.primaryLight,
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => controller.updateQuantity(
                        item,
                        item.quantity + 1,
                      ),
                      color: AppTheme.primaryLight,
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppTheme.spacing8),

              // Stock Info
              Text(
                'Stok: ${item.product.stock}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              // Subtotal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    controller.currencyFormat.format(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartSummaryBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        boxShadow: AppTheme.shadowLarge,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(
                        '${controller.totalItems} item',
                        style: const TextStyle(fontSize: 12),
                      )),
                  const Text('Total'),
                  Obx(() => Text(
                        controller.currencyFormat.format(controller.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      )),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showCheckoutDialog(),
              icon: const Icon(Icons.payment),
              label: const Text('Bayar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', controller.subtotal),
          _buildSummaryRow('Diskon', -controller.transactionDiscount.value),
          _buildSummaryRow('Pajak', controller.taxAmount),
          const Divider(thickness: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                    controller.currencyFormat.format(controller.total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Obx(() => CustomButton(
                text: 'Proses Pembayaran',
                onPressed: () => _showCheckoutDialog(),
                isLoading: controller.isProcessing.value,
                icon: Icons.payment,
              )),
          const SizedBox(height: AppTheme.spacing8),
          CustomButton(
            text: 'Kosongkan Keranjang',
            onPressed: controller.clearCart,
            isOutlined: true,
            icon: Icons.delete_sweep,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Obx(() => Text(
                controller.currencyFormat.format(amount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: _buildCartSection(),
      ),
      isScrollControlled: true,
    );
  }

  void _showCheckoutDialog() {
    final paidController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Pembayaran'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Column(
                  children: [
                    const Text('Total Bayar'),
                    Obx(() => Text(
                          controller.currencyFormat.format(controller.total),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryLight,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Metode Pembayaran'),
                      RadioListTile<String>(
                        title: const Text('Tunai'),
                        value: 'Tunai',
                        groupValue: controller.paymentMethod.value,
                        onChanged: (value) =>
                            controller.paymentMethod.value = value!,
                      ),
                      RadioListTile<String>(
                        title: const Text('Kartu Debit/Kredit'),
                        value: 'Kartu',
                        groupValue: controller.paymentMethod.value,
                        onChanged: (value) =>
                            controller.paymentMethod.value = value!,
                      ),
                    ],
                  )),
              const SizedBox(height: AppTheme.spacing16),
              CustomTextField(
                controller: paidController,
                label: 'Jumlah Bayar',
                hintText: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Icons.money,
                onChanged: (value) {
                  controller.paidAmount.value = double.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              Obx(() {
                final change = controller.change;
                return Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: change >= 0
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      const Text('Kembalian'),
                      Text(
                        controller.currencyFormat.format(change),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              change >= 0 ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed:
                    controller.change >= 0 ? controller.processPayment : null,
                child: controller.isProcessing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Bayar'),
              )),
        ],
      ),
    );
  }
}
