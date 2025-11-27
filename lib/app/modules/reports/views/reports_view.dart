import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadReports,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range Selector
          _buildDateRangeSelector(context),

          // Quick Filter Chips
          _buildQuickFilters(),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(text: 'Ringkasan'),
                        Tab(text: 'Per Produk'),
                        Tab(text: 'Harian'),
                        Tab(text: 'Top Produk'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSummaryTab(),
                          _buildProductSalesTab(),
                          _buildDailySalesTab(),
                          _buildTopProductsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${controller.dateFormat.format(controller.startDate.value)} - ${controller.dateFormat.format(controller.endDate.value)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Hari Ini', 'today'),
          _buildFilterChip('Kemarin', 'yesterday'),
          _buildFilterChip('7 Hari', 'week'),
          _buildFilterChip('Bulan Ini', 'month'),
          _buildFilterChip('Tahun Ini', 'year'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String period) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing8),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => controller.setQuickDateRange(period),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Obx(() {
      final summary = controller.reportSummary.value;
      if (summary == null) {
        return const Center(child: Text('Tidak ada data'));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Penjualan',
                    controller.currencyFormat.format(summary.totalSales),
                    Icons.attach_money,
                    AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Profit',
                    controller.currencyFormat.format(summary.totalProfit),
                    Icons.trending_up,
                    AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Transaksi',
                    '${summary.totalTransactions}',
                    Icons.receipt_long,
                    AppTheme.info,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _buildSummaryCard(
                    'Item Terjual',
                    '${summary.totalItemsSold}',
                    Icons.shopping_cart,
                    AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            _buildSummaryCard(
              'Rata-rata Transaksi',
              controller.currencyFormat.format(summary.averageTransaction),
              Icons.calculate,
              AppTheme.warning,
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Export Button
            Obx(() => CustomButton(
                  text: 'Export Ringkasan',
                  onPressed: () => controller.exportReports('summary'),
                  isLoading: controller.isExporting.value,
                  icon: Icons.download,
                )),
          ],
        ),
      );
    });
  }

  Widget _buildProductSalesTab() {
    return Obx(() {
      if (controller.salesByProduct.isEmpty) {
        return const Center(child: Text('Tidak ada data'));
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: controller.salesByProduct.length,
              itemBuilder: (context, index) {
                final product = controller.salesByProduct[index];
                return CustomCard(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            'Qty: ${product.quantity}',
                            style: const TextStyle(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text('SKU: ${product.sku}'),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Penjualan',
                                  style: TextStyle(fontSize: 12)),
                              Text(
                                controller.currencyFormat
                                    .format(product.totalSales),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Profit',
                                  style: TextStyle(fontSize: 12)),
                              Text(
                                controller.currencyFormat
                                    .format(product.totalProfit),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Obx(() => CustomButton(
                  text: 'Export Laporan Produk',
                  onPressed: () => controller.exportReports('products'),
                  isLoading: controller.isExporting.value,
                  icon: Icons.download,
                )),
          ),
        ],
      );
    });
  }

  Widget _buildDailySalesTab() {
    return Obx(() {
      if (controller.dailySales.isEmpty) {
        return const Center(child: Text('Tidak ada data'));
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: controller.dailySales.length,
              itemBuilder: (context, index) {
                final daily = controller.dailySales[index];
                return CustomCard(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.dateFormat.format(daily.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Transaksi',
                                  style: TextStyle(fontSize: 12)),
                              Text(
                                '${daily.transactionCount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Penjualan',
                                  style: TextStyle(fontSize: 12)),
                              Text(
                                controller.currencyFormat
                                    .format(daily.totalSales),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Profit',
                                  style: TextStyle(fontSize: 12)),
                              Text(
                                controller.currencyFormat
                                    .format(daily.totalProfit),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Obx(() => CustomButton(
                  text: 'Export Laporan Harian',
                  onPressed: () => controller.exportReports('daily'),
                  isLoading: controller.isExporting.value,
                  icon: Icons.download,
                )),
          ),
        ],
      );
    });
  }

  Widget _buildTopProductsTab() {
    return Obx(() {
      if (controller.topProducts.isEmpty) {
        return const Center(child: Text('Tidak ada data'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: controller.topProducts.length,
        itemBuilder: (context, index) {
          final product = controller.topProducts[index];
          return CustomCard(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['productName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'SKU: ${product['sku']}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product['quantity']} terjual',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      controller.currencyFormat.format(product['totalSales']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }
}
