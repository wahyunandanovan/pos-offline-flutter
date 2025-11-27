import 'package:sqflite/sqflite.dart';
import '../../../core/utils/db_helper.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';

class TransactionProvider {
  Future<Database> get _db async => await DBHelper.instance.database;

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await _db;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> insertTransactionItem(TransactionItemModel item) async {
    final db = await _db;
    return await db.insert('transaction_items', item.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _db;
    final results = await db.query(
      'transactions',
      orderBy: 'createdAt DESC',
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final results = await db.query(
      'transactions',
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _db;
    final results = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return TransactionModel.fromMap(results.first);
    }
    return null;
  }

  Future<List<TransactionItemModel>> getTransactionItems(
      int transactionId) async {
    final db = await _db;
    final results = await db.query(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    return results.map((map) => TransactionItemModel.fromMap(map)).toList();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _db;
    await db.delete('transaction_items',
        where: 'transactionId = ?', whereArgs: [id]);
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTransactionsPaginated({
    required int offset,
    required int limit,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _db;

    String whereClause = "status = 'completed'";
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND (transactionCode LIKE ? OR userName LIKE ?)';
      whereArgs.addAll(['%$searchQuery%', '%$searchQuery%']);
    }

    if (startDate != null && endDate != null) {
      whereClause += ' AND createdAt BETWEEN ? AND ?';
      whereArgs
          .addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    }

    final results = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );

    return results;
  }
}
