class ReportSummaryModel {
  final double totalSales;
  final double totalProfit;
  final int totalTransactions;
  final int totalItemsSold;
  final double averageTransaction;
  final DateTime startDate;
  final DateTime endDate;

  ReportSummaryModel({
    required this.totalSales,
    required this.totalProfit,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.averageTransaction,
    required this.startDate,
    required this.endDate,
  });
}
