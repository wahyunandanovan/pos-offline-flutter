import 'package:sqflite/sqflite.dart';
import '../../../core/utils/db_helper.dart';
import '../models/product_model.dart';

class ProductProvider {
  Future<Database> get _db async => await DBHelper.instance.database;

  Future<List<ProductModel>> getAllProducts() async {
    final db = await _db;
    final results = await db.query(
      'products',
      where: 'isActive = 1',
      orderBy: 'name ASC',
    );
    return results.map((map) => ProductModel.fromMap(map)).toList();
  }

  Future<ProductModel?> getProductById(int id) async {
    final db = await _db;
    final results =
        await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return ProductModel.fromMap(results.first);
    }
    return null;
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await _db;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await _db;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _db;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _db;
    final results = await db.query(
      'products',
      where: 'isActive = 1 AND (name LIKE ? OR sku LIKE ? OR barcode LIKE ?)',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return results.map((map) => ProductModel.fromMap(map)).toList();
  }

  Future<List<ProductModel>> filterByCategory(String category) async {
    final db = await _db;
    final results = await db.query(
      'products',
      where: 'isActive = 1 AND category = ?',
      whereArgs: [category],
    );
    return results.map((map) => ProductModel.fromMap(map)).toList();
  }

  Future<bool> skuExists(String sku, {int? excludeId}) async {
    final db = await _db;
    final where = excludeId != null ? 'sku = ? AND id != ?' : 'sku = ?';
    final whereArgs = excludeId != null ? [sku, excludeId] : [sku];

    final results =
        await db.query('products', where: where, whereArgs: whereArgs);
    return results.isNotEmpty;
  }

  Future<List<String>> getCategories() async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != "" ORDER BY category',
    );
    return results.map((r) => r['category'] as String).toList();
  }

  Future<int> updateStock(int productId, int newStock) async {
    final db = await _db;
    return await db.update(
      'products',
      {
        'stock': newStock,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<ProductModel>> getProductsPaginated({
    required int offset,
    required int limit,
    String? searchQuery,
    String? category,
  }) async {
    final db = await _db;

    String whereClause = 'isActive = 1';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND (name LIKE ? OR sku LIKE ? OR barcode LIKE ?)';
      whereArgs.addAll(['%$searchQuery%', '%$searchQuery%', '%$searchQuery%']);
    }

    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final results = await db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => ProductModel.fromMap(map)).toList();
  }
}
