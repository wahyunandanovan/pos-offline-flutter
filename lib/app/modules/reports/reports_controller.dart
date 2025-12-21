import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/report_summary_model.dart';
import 'models/sales_by_product_model.dart';
import 'models/daily_sales_model.dart';
import 'repositories/report_repository.dart';

class ReportsController extends GetxController {
  final ReportRepository repository;

  ReportsController(this.repository);

  // Date range
  final startDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  final endDate = DateTime.now().obs;

  // Report data
  final reportSummary = Rxn<ReportSummaryModel>();
  final salesByProduct = <SalesByProductModel>[].obs;
  final dailySales = <DailySalesModel>[].obs;
  final topProducts = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isExporting = false.obs;

  // Selected tab
  final selectedTab = 0.obs;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      isLoading.value = true;

      // Load all reports in parallel
      await Future.wait([
        _loadSummary(),
        _loadSalesByProduct(),
        _loadDailySales(),
        _loadTopProducts(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat laporan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await repository.getSalesSummary(
        startDate.value,
        endDate.value.add(const Duration(days: 1)),
      );
      reportSummary.value = summary;
    } catch (e) {
      print('pppppppppp${e}');
    }
  }

  Future<void> _loadSalesByProduct() async {
    final data = await repository.getSalesByProduct(
      startDate.value,
      endDate.value.add(const Duration(days: 1)),
    );
    salesByProduct.value = data;
  }

  Future<void> _loadDailySales() async {
    final data = await repository.getDailySales(
      startDate.value,
      endDate.value.add(const Duration(days: 1)),
    );
    dailySales.value = data;
  }

  Future<void> _loadTopProducts() async {
    final data = await repository.getTopSellingProducts(
      startDate.value,
      endDate.value.add(const Duration(days: 1)),
      limit: 10,
    );
    topProducts.value = data;
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    loadReports();
  }

  void setQuickDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = now;
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate.value =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate.value = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case 'week':
        startDate.value = now.subtract(const Duration(days: 7));
        endDate.value = now;
        break;
      case 'month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = now;
        break;
      case 'year':
        startDate.value = DateTime(now.year, 1, 1);
        endDate.value = now;
        break;
    }
    loadReports();
  }

  /// Export reports to CSV
  Future<void> exportReports(String reportType) async {
    try {
      isExporting.value = true;

      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar('Error', 'Izin penyimpanan diperlukan',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      String csvData = '';
      String fileName = '';

      switch (reportType) {
        case 'summary':
          csvData = await _generateSummaryCSV();
          fileName = 'laporan_ringkasan_${_getDateString()}.csv';
          break;
        case 'products':
          csvData = await _generateProductSalesCSV();
          fileName = 'laporan_produk_${_getDateString()}.csv';
          break;
        case 'daily':
          csvData = await _generateDailySalesCSV();
          fileName = 'laporan_harian_${_getDateString()}.csv';
          break;
        case 'transactions':
          csvData = await _generateTransactionsCSV();
          fileName = 'laporan_transaksi_${_getDateString()}.csv';
          break;
      }

      // Save file
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      final path = '${directory!.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvData);

      Get.snackbar(
        'Berhasil',
        'Laporan berhasil di-export ke:\n$path',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal export laporan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isExporting.value = false;
    }
  }

  Future<String> _generateSummaryCSV() async {
    final summary = reportSummary.value!;

    final List<List<dynamic>> rows = [
      ['Laporan Ringkasan Penjualan'],
      [
        'Periode',
        '${dateFormat.format(summary.startDate)} - ${dateFormat.format(summary.endDate)}'
      ],
      [],
      ['Metrik', 'Nilai'],
      ['Total Penjualan', summary.totalSales],
      ['Total Profit', summary.totalProfit],
      ['Jumlah Transaksi', summary.totalTransactions],
      ['Total Item Terjual', summary.totalItemsSold],
      ['Rata-rata Transaksi', summary.averageTransaction],
    ];

    return const ListToCsvConverter().convert(rows);
  }

  Future<String> _generateProductSalesCSV() async {
    final List<List<dynamic>> rows = [
      ['Laporan Penjualan Per Produk'],
      [
        'Periode',
        '${dateFormat.format(startDate.value)} - ${dateFormat.format(endDate.value)}'
      ],
      [],
      ['Produk', 'SKU', 'Qty Terjual', 'Total Penjualan', 'Total Profit'],
    ];

    for (var product in salesByProduct) {
      rows.add([
        product.productName,
        product.sku,
        product.quantity,
        product.totalSales,
        product.totalProfit,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<String> _generateDailySalesCSV() async {
    final List<List<dynamic>> rows = [
      ['Laporan Penjualan Harian'],
      [
        'Periode',
        '${dateFormat.format(startDate.value)} - ${dateFormat.format(endDate.value)}'
      ],
      [],
      ['Tanggal', 'Jumlah Transaksi', 'Total Penjualan', 'Total Profit'],
    ];

    for (var daily in dailySales) {
      rows.add([
        dateFormat.format(daily.date),
        daily.transactionCount,
        daily.totalSales,
        daily.totalProfit,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<String> _generateTransactionsCSV() async {
    final transactions = await repository.getTransactionsForExport(
      startDate.value,
      endDate.value.add(const Duration(days: 1)),
    );

    final List<List<dynamic>> rows = [
      ['Laporan Transaksi'],
      [
        'Periode',
        '${dateFormat.format(startDate.value)} - ${dateFormat.format(endDate.value)}'
      ],
      [],
      [
        'Kode Transaksi',
        'Tanggal',
        'Kasir',
        'Subtotal',
        'Diskon',
        'Pajak',
        'Total',
        'Bayar',
        'Kembali',
        'Metode'
      ],
    ];

    for (var trx in transactions) {
      rows.add([
        trx['transactionCode'],
        trx['createdAt'],
        trx['userName'],
        trx['subtotal'],
        trx['discount'],
        trx['tax'],
        trx['total'],
        trx['paid'],
        trx['change'],
        trx['paymentMethod'],
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String _getDateString() {
    return '${startDate.value.toString().split(' ')[0]}_${endDate.value.toString().split(' ')[0]}';
  }
}
