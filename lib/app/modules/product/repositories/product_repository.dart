import '../models/product_model.dart';
import '../providers/product_provider.dart';

class ProductRepository {
  final ProductProvider _provider;

  ProductRepository(this._provider);

  Future<List<ProductModel>> getAllProducts() => _provider.getAllProducts();
  Future<ProductModel?> getProductById(int id) => _provider.getProductById(id);
  Future<int> createProduct(ProductModel product) =>
      _provider.insertProduct(product);
  Future<int> updateProduct(ProductModel product) =>
      _provider.updateProduct(product);
  Future<int> deleteProduct(int id) => _provider.deleteProduct(id);
  Future<List<ProductModel>> searchProducts(String query) =>
      _provider.searchProducts(query);
  Future<List<ProductModel>> filterByCategory(String category) =>
      _provider.filterByCategory(category);
  Future<bool> skuExists(String sku, {int? excludeId}) =>
      _provider.skuExists(sku, excludeId: excludeId);
  Future<List<String>> getCategories() => _provider.getCategories();
  Future<int> updateStock(int productId, int newStock) =>
      _provider.updateStock(productId, newStock);
  Future<int> updateSoldQuantity(int productId, int additionalQuantity) {
    return _provider.updateSoldQuantity(productId, additionalQuantity);
  }

  Future<List<ProductModel>> getProductsPaginated({
    required int offset,
    required int limit,
    String? searchQuery,
    String? category,
    String sortBy = 'best_seller',
  }) {
    return _provider.getProductsPaginated(
      offset: offset,
      limit: limit,
      searchQuery: searchQuery,
      category: category,
      sortBy: sortBy,
    );
  }
}
