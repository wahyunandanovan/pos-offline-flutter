class DailySalesModel {
  final DateTime date;
  final int transactionCount;
  final double totalSales;
  final double totalProfit;

  DailySalesModel({
    required this.date,
    required this.transactionCount,
    required this.totalSales,
    required this.totalProfit,
  });

  Map<String, dynamic> toMap() {
    return {
      'Tanggal': date.toString().split(' ')[0],
      'Jumlah Transaksi': transactionCount,
      'Total Penjualan': totalSales,
      'Total Profit': totalProfit,
    };
  }
}
