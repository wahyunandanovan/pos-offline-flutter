// lib/app/modules/reports/providers/report_provider.dart
import 'package:sqflite/sqflite.dart';
import '../../../core/utils/db_helper.dart';

class ReportProvider {
  Future<Database> get _db async => await DBHelper.instance.database;

  /// Get sales summary for date range
  Future<Map<String, dynamic>> getSalesSummary(
      DateTime startDate, DateTime endDate) async {
    final db = await _db;

    // Get total sales and transactions
    final salesResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalTransactions,
        COALESCE(SUM(total), 0) as totalSales,
        COALESCE(SUM(subtotal - discount), 0) as revenue,
        COALESCE(AVG(total), 0) as averageTransaction
      FROM transactions
      WHERE createdAt BETWEEN ? AND ?
      AND status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    // Get total items sold
    final itemsResult = await db.rawQuery('''
      SELECT COALESCE(SUM(ti.quantity), 0) as totalItems
      FROM transaction_items ti
      INNER JOIN transactions t ON ti.transactionId = t.id
      WHERE t.createdAt BETWEEN ? AND ?
      AND t.status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    // Calculate profit (need to get product buy prices)
    final profitResult = await db.rawQuery('''
      SELECT 
        COALESCE(SUM((ti.price - p.buyPrice) * ti.quantity - ti.discount), 0) as totalProfit
      FROM transaction_items ti
      INNER JOIN transactions t ON ti.transactionId = t.id
      INNER JOIN products p ON ti.productId = p.id
      WHERE t.createdAt BETWEEN ? AND ?
      AND t.status = 'completed'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return {
      'totalSales': salesResult.first['totalSales'] as double,
      'totalTransactions': salesResult.first['totalTransactions'] as int,
      'totalItems': itemsResult.first['totalItems'] as int,
      'averageTransaction': salesResult.first['averageTransaction'] as double,
      'totalProfit': profitResult.first['totalProfit'] as double,
    };
  }

  /// Get sales by product
  Future<List<Map<String, dynamic>>> getSalesByProduct(
      DateTime startDate, DateTime endDate) async {
    final db = await _db;

    final results = await db.rawQuery('''
      SELECT 
        ti.productName,
        ti.sku,
        SUM(ti.quantity) as quantity,
        SUM(ti.subtotal) as totalSales,
        SUM((ti.price - p.buyPrice) * ti.quantity - ti.discount) as totalProfit
      FROM transaction_items ti
      INNER JOIN transactions t ON ti.transactionId = t.id
      INNER JOIN products p ON ti.productId = p.id
      WHERE t.createdAt BETWEEN ? AND ?
      AND t.status = 'completed'
      GROUP BY ti.productId, ti.productName, ti.sku
      ORDER BY totalSales DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return results;
  }

  /// Get daily sales
  Future<List<Map<String, dynamic>>> getDailySales(
      DateTime startDate, DateTime endDate) async {
    final db = await _db;

    final results = await db.rawQuery('''
      SELECT 
        DATE(t.createdAt) as date,
        COUNT(*) as transactionCount,
        COALESCE(SUM(t.total), 0) as totalSales,
        COALESCE(SUM((ti.price - p.buyPrice) * ti.quantity - ti.discount), 0) as totalProfit
      FROM transactions t
      LEFT JOIN transaction_items ti ON t.id = ti.transactionId
      LEFT JOIN products p ON ti.productId = p.id
      WHERE t.createdAt BETWEEN ? AND ?
      AND t.status = 'completed'
      GROUP BY DATE(t.createdAt)
      ORDER BY DATE(t.createdAt) ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return results;
  }

  /// Get transactions for export
  Future<List<Map<String, dynamic>>> getTransactionsForExport(
      DateTime startDate, DateTime endDate) async {
    final db = await _db;

    final results = await db.query(
      'transactions',
      where: 'createdAt BETWEEN ? AND ? AND status = ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        'completed'
      ],
      orderBy: 'createdAt DESC',
    );

    return results;
  }

  /// Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
      DateTime startDate, DateTime endDate,
      {int limit = 10}) async {
    final db = await _db;

    final results = await db.rawQuery('''
      SELECT 
        ti.productName,
        ti.sku,
        SUM(ti.quantity) as quantity,
        SUM(ti.subtotal) as totalSales
      FROM transaction_items ti
      INNER JOIN transactions t ON ti.transactionId = t.id
      WHERE t.createdAt BETWEEN ? AND ?
      AND t.status = 'completed'
      GROUP BY ti.productId, ti.productName, ti.sku
      ORDER BY quantity DESC
      LIMIT ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String(), limit]);

    return results;
  }
}
