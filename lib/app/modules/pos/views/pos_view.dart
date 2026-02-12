import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos_offline/app/modules/printer-settings/printer_setings_view.dart';
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
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => Get.to(() => const PrinterSettingsView()),
            tooltip: 'Pengaturan Printer',
          ),
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    padding: const EdgeInsets.all(12),
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
          child: Column(
            children: [
              // SEARCH FIELD WITH CLEAR BUTTON
              Obx(() => CustomTextField(
                    controller: controller.searchController,
                    hintText: 'Cari produk...',
                    prefixIcon: Icons.search,
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: controller.clearSearch,
                          )
                        : null,
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (controller.searchQuery.value == value) {
                          controller.searchProducts(value);
                        }
                      });
                      controller.searchQuery.value = value;
                    },
                  )),
              const SizedBox(height: AppTheme.spacing12),

              // SORT DROPDOWN
              _buildSortDropdown(),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final displayProducts = controller.filteredProducts;

            if (displayProducts.isEmpty) {
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
              itemCount: displayProducts.length +
                  (controller.hasMoreData.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayProducts.length) {
                  return Obx(() => controller.isLoadingMore.value
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink());
                }

                final product = displayProducts[index];
                return _buildProductCard(product);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Row(
            children: [
              const Icon(Icons.sort, size: 20),
              const SizedBox(width: 8),
              const Text('Urutkan:', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: controller.sortBy.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'best_seller',
                      child: Text('🔥 Paling Laku'),
                    ),
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('🔤 Nama A-Z'),
                    ),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text('💰 Harga Terendah'),
                    ),
                    DropdownMenuItem(
                      value: 'price_high',
                      child: Text('💎 Harga Tertinggi'),
                    ),
                    DropdownMenuItem(
                      value: 'stock',
                      child: Text('📦 Stok Terbanyak'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeSortBy(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildProductCard(product) {
    return Obx(() {
      final quantityInCart = controller.getProductQuantityInCart(product.id!);
      final hasImage =
          product.imagePath != null && product.imagePath!.isNotEmpty;

      return Card(
        child: InkWell(
          onTap: () => controller.addToCart(product),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                          child: hasImage
                              ? Image.file(
                                  File(product.imagePath!),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: AppTheme.primaryLight,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: AppTheme.primaryLight,
                                  ),
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
                        color: product.isLowStock
                            ? AppTheme.error
                            : AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),

              // QUANTITY BADGE IN CART
              if (quantityInCart > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryLight.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$quantityInCart',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCartSection() {
    return Column(
      children: [
        // Header Keranjang
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

        // List Cart Items
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

        // Checkout Section
        Obx(() => controller.cartItems.isEmpty
            ? const SizedBox.shrink()
            : _buildCheckoutSection()),
      ],
    );
  }

  Widget _buildCartItem(item) {
    final hasImage =
        item.product.imagePath != null && item.product.imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: hasImage
                    ? Image.file(
                        File(item.product.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_outlined,
                            color: AppTheme.primaryLight,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: AppTheme.primaryLight,
                      ),
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
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
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: () => controller.removeFromCart(item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    color: AppTheme.backgroundLight),
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
                          color: AppTheme.primaryLight,
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
              Text(
                'Stok: ${item.product.stock}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
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
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.totalItems} item',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Text('Total'),
                      Text(
                        controller.currencyFormat.format(controller.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  )),
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
      child: Obx(() => Column(
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
                  Text(
                    controller.currencyFormat.format(controller.total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              CustomButton(
                text: 'Proses Pembayaran',
                onPressed: () => _showCheckoutDialog(),
                isLoading: controller.isProcessing.value,
                icon: Icons.payment,
              ),
              const SizedBox(height: AppTheme.spacing8),
              CustomButton(
                text: 'Kosongkan Keranjang',
                onPressed: controller.clearCart,
                isOutlined: true,
                icon: Icons.delete_sweep,
              ),
            ],
          )),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            controller.currencyFormat.format(amount),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
    final discountController = TextEditingController();

    // Reset payment values
    controller.paidAmount.value = 0;
    controller.transactionDiscount.value = 0;

    Get.dialog(
      AlertDialog(
        title: const Text('Pembayaran'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total Bayar
              Obx(() => Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Column(
                      children: [
                        const Text('Total Bayar'),
                        Text(
                          controller.currencyFormat.format(controller.total),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: AppTheme.spacing16),

              // Metode Pembayaran
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      RadioListTile<String>(
                        title: const Text('Tunai'),
                        value: 'Tunai',
                        groupValue: controller.paymentMethod.value,
                        onChanged: (value) =>
                            controller.paymentMethod.value = value!,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        title: const Text('Kartu Debit/Kredit'),
                        value: 'Kartu',
                        groupValue: controller.paymentMethod.value,
                        onChanged: (value) =>
                            controller.paymentMethod.value = value!,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        title: const Text('Transfer Bank'),
                        value: 'Transfer',
                        groupValue: controller.paymentMethod.value,
                        onChanged: (value) =>
                            controller.paymentMethod.value = value!,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        title: const Text('E-Wallet'),
                        value: 'E-Wallet',
                        groupValue: controller.paymentMethod.value,
                        onChanged: (value) =>
                            controller.paymentMethod.value = value!,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  )),
              const SizedBox(height: AppTheme.spacing16),

              // Input Diskon
              CustomTextField(
                controller: discountController,
                label: 'Diskon Transaksi (Opsional)',
                hintText: 'Rp 0',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyInputFormatter(),
                ],
                prefixIcon: Icons.discount,
                onChanged: (value) {
                  // Remove non-numeric characters
                  final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                  controller.transactionDiscount.value =
                      double.tryParse(numericValue) ?? 0;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Input Jumlah Bayar dengan Format Currency
              CustomTextField(
                controller: paidController,
                label: 'Jumlah Bayar',
                hintText: 'Rp 0',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyInputFormatter(),
                ],
                prefixIcon: Icons.money,
                onChanged: (value) {
                  // Remove non-numeric characters
                  final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                  controller.paidAmount.value =
                      double.tryParse(numericValue) ?? 0;
                },
              ),
              const SizedBox(height: AppTheme.spacing8),

              // Quick Amount Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickAmountButton(
                      paidController, controller.total, 'Uang Pas'),
                  _buildQuickAmountButton(paidController, 50000, '50K'),
                  _buildQuickAmountButton(paidController, 100000, '100K'),
                  _buildQuickAmountButton(paidController, 200000, '200K'),
                  _buildQuickAmountButton(paidController, 500000, '500K'),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Kembalian
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
            onPressed: () {
              Get.back();
              controller.transactionDiscount.value = 0;
            },
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

  Widget _buildQuickAmountButton(
      TextEditingController controller, double amount, String label) {
    return ElevatedButton(
      onPressed: () {
        final formatter = NumberFormat('#,###', 'id_ID');
        final formattedAmount = 'Rp ${formatter.format(amount)}';
        controller.text = formattedAmount;
        this.controller.paidAmount.value = amount;
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}

// Currency Input Formatter
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove non-numeric characters
    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericValue.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Format with thousand separators
    final formatter = NumberFormat('#,###', 'id_ID');
    final formattedValue = formatter.format(int.parse(numericValue));

    return TextEditingValue(
      text: 'Rp $formattedValue',
      selection: TextSelection.collapsed(offset: formattedValue.length + 3),
    );
  }
}
