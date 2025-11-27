// lib/app/modules/product/product_controller.dart - UPDATED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'models/product_model.dart';
import 'repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository repository;

  ProductController(this.repository);

  // Pagination
  final int pageSize = 20;
  var currentPage = 0;
  var hasMoreData = true.obs;

  final products = <ProductModel>[].obs;
  final filteredProducts = <ProductModel>[].obs;
  final categories = <String>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSaving = false.obs;

  // Form controllers
  final skuController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final stockController = TextEditingController();
  final minStockController = TextEditingController();
  final barcodeController = TextEditingController();

  // Filters
  final searchQuery = ''.obs;
  final selectedCategory = Rxn<String>();

  // Selected category for form
  final selectedFormCategory = Rxn<String>();

  ProductModel? editingProduct;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Scroll Controller
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();

    // Setup infinite scroll
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    skuController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    buyPriceController.dispose();
    sellPriceController.dispose();
    stockController.dispose();
    minStockController.dispose();
    barcodeController.dispose();
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

      final result = await repository.getProductsPaginated(
        offset: 0,
        limit: pageSize,
        searchQuery: searchQuery.value,
        category: selectedCategory.value,
      );

      products.value = result;
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

      final result = await repository.getProductsPaginated(
        offset: currentPage * pageSize,
        limit: pageSize,
        searchQuery: searchQuery.value,
        category: selectedCategory.value,
      );

      if (result.isNotEmpty) {
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

  Future<void> loadCategories() async {
    try {
      final result = await repository.getCategories();
      categories.value = result;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    loadProducts(refresh: true);
  }

  void filterByCategory(String? category) {
    selectedCategory.value = category;
    loadProducts(refresh: true);
  }

  void prepareCreate() {
    editingProduct = null;
    skuController.text = _generateSKU();
    nameController.clear();
    descriptionController.clear();
    categoryController.clear();
    buyPriceController.clear();
    sellPriceController.clear();
    stockController.text = '0';
    minStockController.text = '0';
    barcodeController.clear();
    selectedFormCategory.value = null;
  }

  void prepareEdit(ProductModel product) {
    editingProduct = product;
    skuController.text = product.sku;
    nameController.text = product.name;
    descriptionController.text = product.description ?? '';
    categoryController.text = product.category ?? '';
    buyPriceController.text = product.buyPrice.toString();
    sellPriceController.text = product.sellPrice.toString();
    stockController.text = product.stock.toString();
    minStockController.text = product.minStock.toString();
    barcodeController.text = product.barcode ?? '';
    selectedFormCategory.value = product.category;
  }

  String? validateForm() {
    if (skuController.text.trim().isEmpty) return 'SKU harus diisi';
    if (nameController.text.trim().isEmpty) return 'Nama produk harus diisi';
    if (buyPriceController.text.isEmpty) return 'Harga beli harus diisi';
    if (sellPriceController.text.isEmpty) return 'Harga jual harus diisi';

    final buyPrice = double.tryParse(buyPriceController.text);
    final sellPrice = double.tryParse(sellPriceController.text);

    if (buyPrice == null || buyPrice < 0) return 'Harga beli tidak valid';
    if (sellPrice == null || sellPrice < 0) return 'Harga jual tidak valid';
    if (sellPrice < buyPrice) return 'Harga jual harus lebih dari harga beli';

    return null;
  }

  Future<void> saveProduct() async {
    final error = validateForm();
    if (error != null) {
      Get.snackbar('Error', error,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;

      final skuExists = await repository.skuExists(
        skuController.text.trim(),
        excludeId: editingProduct?.id,
      );

      if (skuExists) {
        Get.snackbar('Error', 'SKU sudah digunakan',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final now = DateTime.now();

      // Use selected category or text input
      final category = selectedFormCategory.value ??
          (categoryController.text.trim().isEmpty
              ? null
              : categoryController.text.trim());

      final product = ProductModel(
        id: editingProduct?.id,
        sku: skuController.text.trim(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        category: category,
        buyPrice: double.parse(buyPriceController.text),
        sellPrice: double.parse(sellPriceController.text),
        stock: int.tryParse(stockController.text) ?? 0,
        minStock: int.tryParse(minStockController.text) ?? 0,
        barcode: barcodeController.text.trim().isEmpty
            ? null
            : barcodeController.text.trim(),
        createdAt: editingProduct?.createdAt ?? now,
        updatedAt: now,
      );

      if (editingProduct == null) {
        await repository.createProduct(product);
        Get.snackbar('Berhasil', 'Produk berhasil ditambahkan',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        await repository.updateProduct(product);
        Get.snackbar('Berhasil', 'Produk berhasil diupdate',
            backgroundColor: Colors.green, colorText: Colors.white);
      }

      await loadProducts(refresh: true);
      await loadCategories();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan produk: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    try {
      await repository.deleteProduct(product.id!);
      Get.snackbar('Berhasil', 'Produk berhasil dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      await loadProducts(refresh: true);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus produk: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String _generateSKU() {
    final now = DateTime.now();
    return 'PRD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  // Method untuk create new category from input
  void createNewCategory(String categoryName) {
    if (categoryName.trim().isNotEmpty &&
        !categories.contains(categoryName.trim())) {
      categories.add(categoryName.trim());
      selectedFormCategory.value = categoryName.trim();
      categoryController.text = categoryName.trim();
    }
  }
}
