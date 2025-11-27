class SalesByProductModel {
  final String productName;
  final String sku;
  final int quantity;
  final double totalSales;
  final double totalProfit;

  SalesByProductModel({
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.totalSales,
    required this.totalProfit,
  });

  Map<String, dynamic> toMap() {
    return {
      'Produk': productName,
      'SKU': sku,
      'Qty Terjual': quantity,
      'Total Penjualan': totalSales,
      'Total Profit': totalProfit,
    };
  }
}
