import '../models/report_summary_model.dart';
import '../models/sales_by_product_model.dart';
import '../models/daily_sales_model.dart';
import '../providers/report_provider.dart';

class ReportRepository {
  final ReportProvider _provider;

  ReportRepository(this._provider);

  Future<ReportSummaryModel> getSalesSummary(
      DateTime startDate, DateTime endDate) async {
    final data = await _provider.getSalesSummary(startDate, endDate);
    return ReportSummaryModel(
      totalSales: data['totalSales'],
      totalProfit: data['totalProfit'],
      totalTransactions: data['totalTransactions'],
      totalItemsSold: data['totalItems'],
      averageTransaction: data['averageTransaction'],
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<SalesByProductModel>> getSalesByProduct(
      DateTime startDate, DateTime endDate) async {
    final results = await _provider.getSalesByProduct(startDate, endDate);
    return results
        .map((data) => SalesByProductModel(
              productName: data['productName'],
              sku: data['sku'],
              quantity: data['quantity'],
              totalSales: (data['totalSales'] as num).toDouble(),
              totalProfit: (data['totalProfit'] as num).toDouble(),
            ))
        .toList();
  }

  Future<List<DailySalesModel>> getDailySales(
      DateTime startDate, DateTime endDate) async {
    final results = await _provider.getDailySales(startDate, endDate);
    return results
        .map((data) => DailySalesModel(
              date: DateTime.parse(data['date']),
              transactionCount: data['transactionCount'],
              totalSales: (data['totalSales'] as num).toDouble(),
              totalProfit: (data['totalProfit'] as num).toDouble(),
            ))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTransactionsForExport(
      DateTime startDate, DateTime endDate) async {
    return await _provider.getTransactionsForExport(startDate, endDate);
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(
      DateTime startDate, DateTime endDate,
      {int limit = 10}) async {
    return await _provider.getTopSellingProducts(startDate, endDate,
        limit: limit);
  }
}
