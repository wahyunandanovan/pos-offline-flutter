import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../auth/auth_controller.dart';
import '../product/models/product_model.dart';
import '../product/repositories/product_repository.dart';
import 'models/cart_item_model.dart';
import 'models/transaction_model.dart';
import 'models/transaction_item_model.dart';
import 'repositories/transaction_repository.dart';

class PosController extends GetxController {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;

  PosController(this.transactionRepository, this.productRepository);

  // Pagination for products
  final int pageSize = 20;
  var currentPage = 0;
  var hasMoreData = true.obs;

  // Sorting
  final sortBy = 'best_seller'.obs;

  // Product catalog
  final products = <ProductModel>[].obs;
  final filteredProducts = <ProductModel>[].obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  // Cart
  final cartItems = <CartItemModel>[].obs;
  final transactionDiscount = 0.0.obs;
  final taxPercentage = 0.0.obs;

  // Payment
  final paymentMethod = 'Tunai'.obs;
  final paidAmount = 0.0.obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isProcessing = false.obs;

  // Transactions history
  final transactions = <TransactionModel>[].obs;

  // Scroll controller for products
  final scrollController = ScrollController();

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Computed values
  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get taxAmount =>
      (subtotal - transactionDiscount.value) * (taxPercentage.value / 100);
  double get total => subtotal - transactionDiscount.value + taxAmount;
  double get change => paidAmount.value - total;
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadTransactions();

    // Setup infinite scroll
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMoreData.value) {
        loadMoreProducts();
      }
    }
  }

  Future<void> loadProducts({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage = 0;
        hasMoreData.value = true;
        products.clear();
        filteredProducts.clear();
      }

      isLoading.value = true;

      final result = await productRepository.getProductsPaginated(
        offset: 0,
        limit: pageSize,
        searchQuery: searchQuery.value,
      );

      products.value = result;

      // Apply sorting immediately after loading
      _sortProducts(result);
      filteredProducts.value = result;

      hasMoreData.value = result.length >= pageSize;
      currentPage = 1;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat produk: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;

      final result = await productRepository.getProductsPaginated(
        offset: currentPage * pageSize,
        limit: pageSize,
        searchQuery: searchQuery.value,
      );

      if (result.isNotEmpty) {
        // Sort new items before adding to maintain consistency
        _sortProducts(result);

        products.addAll(result);
        filteredProducts.addAll(result);

        currentPage++;
        hasMoreData.value = result.length >= pageSize;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat lebih banyak produk: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    loadProducts(refresh: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadProducts(refresh: true);
  }

  int getProductQuantityInCart(int productId) {
    final cartItem =
        cartItems.firstWhereOrNull((item) => item.product.id == productId);
    return cartItem?.quantity ?? 0;
  }

  void changeSortBy(String newSortBy) {
    sortBy.value = newSortBy;

    // Re-sort all loaded products
    _sortProducts(filteredProducts);
    filteredProducts.refresh();
  }

  void _sortProducts(List<ProductModel> productList) {
    switch (sortBy.value) {
      case 'best_seller':
        productList.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
        break;
      case 'name':
        productList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        productList.sort((a, b) => a.sellPrice.compareTo(b.sellPrice));
        break;
      case 'price_high':
        productList.sort((a, b) => b.sellPrice.compareTo(a.sellPrice));
        break;
      case 'stock':
        productList.sort((a, b) => b.stock.compareTo(a.stock));
        break;
    }
  }

  void applySorting() {
    _sortProducts(filteredProducts);
  }

  void addToCart(ProductModel product) {
    if (product.stock < 1) {
      Get.snackbar('Error', 'Stok produk habis',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final existingIndex =
        cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final currentQty = cartItems[existingIndex].quantity;
      if (currentQty >= product.stock) {
        Get.snackbar('Error', 'Stok tidak mencukupi',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(CartItemModel(product: product));
    }

    cartItems.refresh();

    // Show feedback
    // Get.snackbar(
    //   'Ditambahkan',
    //   '${product.name} ditambahkan ke keranjang',
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 1),
    // );
  }

  void updateQuantity(CartItemModel item, int newQty) {
    if (newQty < 1) {
      removeFromCart(item);
      return;
    }

    if (newQty > item.product.stock) {
      Get.snackbar('Error', 'Stok tidak mencukupi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    item.quantity = newQty;
    cartItems.refresh();
  }

  void updateItemDiscount(CartItemModel item, double discount) {
    if (discount < 0) discount = 0;
    if (discount > item.price * item.quantity) {
      discount = item.price * item.quantity;
    }
    item.discount = discount;
    cartItems.refresh();
  }

  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
  }

  void clearCart() {
    cartItems.clear();
    transactionDiscount.value = 0;
    taxPercentage.value = 0;
    paymentMethod.value = 'Tunai';
    paidAmount.value = 0;
  }

  Future<void> processPayment() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Keranjang kosong',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (paidAmount.value < total) {
      Get.snackbar('Error', 'Jumlah pembayaran kurang',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isProcessing.value = true;

      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value!;

      final now = DateTime.now();
      final transactionCode =
          'TRX${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

      final transaction = TransactionModel(
        transactionCode: transactionCode,
        userId: currentUser.id!,
        userName: currentUser.fullName,
        subtotal: subtotal,
        discount: transactionDiscount.value,
        tax: taxAmount,
        total: total,
        paid: paidAmount.value,
        change: change,
        paymentMethod: paymentMethod.value,
        createdAt: now,
      );

      final transactionId =
          await transactionRepository.createTransaction(transaction);

      for (var cartItem in cartItems) {
        final item = TransactionItemModel(
          transactionId: transactionId,
          productId: cartItem.product.id!,
          productName: cartItem.product.name,
          sku: cartItem.product.sku,
          quantity: cartItem.quantity,
          price: cartItem.price,
          discount: cartItem.discount,
          subtotal: cartItem.subtotal,
        );

        await transactionRepository.createTransactionItem(item);

        final newStock = cartItem.product.stock - cartItem.quantity;
        await productRepository.updateStock(cartItem.product.id!, newStock);

        await productRepository.updateSoldQuantity(
          cartItem.product.id!,
          cartItem.quantity,
        );
      }

      await _showSuccessDialog(transaction);
      clearCart();
      await loadProducts(refresh: true);
      await loadTransactions();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses transaksi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      final result = await transactionRepository.getAllTransactions();
      transactions.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat transaksi: $e');
    }
  }

  Future<void> _showSuccessDialog(TransactionModel transaction) async {
    await Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Transaksi Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode: ${transaction.transactionCode}'),
            const Divider(),
            Text('Total: ${currencyFormat.format(transaction.total)}'),
            Text('Bayar: ${currencyFormat.format(transaction.paid)}'),
            Text('Kembali: ${currencyFormat.format(transaction.change)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.snackbar('Info', 'Fitur print akan segera tersedia');
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }
}
