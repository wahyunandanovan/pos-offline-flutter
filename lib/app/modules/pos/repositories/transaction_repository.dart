import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';
import '../providers/transaction_provider.dart';

class TransactionRepository {
  final TransactionProvider _provider;

  TransactionRepository(this._provider);

  Future<int> createTransaction(TransactionModel transaction) =>
      _provider.insertTransaction(transaction);

  Future<int> createTransactionItem(TransactionItemModel item) =>
      _provider.insertTransactionItem(item);

  Future<List<TransactionModel>> getAllTransactions() =>
      _provider.getAllTransactions();

  Future<List<TransactionModel>> getTransactionsByDate(
    DateTime startDate,
    DateTime endDate,
  ) =>
      _provider.getTransactionsByDate(startDate, endDate);

  Future<TransactionModel?> getTransactionById(int id) =>
      _provider.getTransactionById(id);

  Future<List<TransactionItemModel>> getTransactionItems(int transactionId) =>
      _provider.getTransactionItems(transactionId);

  Future<void> deleteTransaction(int id) => _provider.deleteTransaction(id);
  Future<List<TransactionModel>> getTransactionsPaginated({
    required int offset,
    required int limit,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final results = await _provider.getTransactionsPaginated(
      offset: offset,
      limit: limit,
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
    );

    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }
}
