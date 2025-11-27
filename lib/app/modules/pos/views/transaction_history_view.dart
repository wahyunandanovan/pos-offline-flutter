import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../pos_controller.dart';

class TransactionHistoryView extends GetView<PosController> {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a separate controller for transaction history if needed
    return TransactionHistoryContent(controller: controller);
  }
}

class TransactionHistoryContent extends StatefulWidget {
  final PosController controller;

  const TransactionHistoryContent({super.key, required this.controller});

  @override
  State<TransactionHistoryContent> createState() =>
      _TransactionHistoryContentState();
}

class _TransactionHistoryContentState extends State<TransactionHistoryContent> {
  final ScrollController _scrollController = ScrollController();
  final searchController = TextEditingController();

  final transactions = <dynamic>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;

  int currentPage = 0;
  final int pageSize = 20;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMoreData.value) {
        loadMoreTransactions();
      }
    }
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage = 0;
      hasMoreData.value = true;
      transactions.clear();
    }

    try {
      isLoading.value = true;

      final result = await widget.controller.transactionRepository
          .getTransactionsPaginated(
        offset: 0,
        limit: pageSize,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
      );

      transactions.value = result;
      hasMoreData.value = result.length >= pageSize;
      currentPage = 1;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;

      final result = await widget.controller.transactionRepository
          .getTransactionsPaginated(
        offset: currentPage * pageSize,
        limit: pageSize,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
      );

      if (result.isNotEmpty) {
        transactions.addAll(result);
        currentPage++;
        hasMoreData.value = result.length >= pageSize;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat lebih banyak transaksi: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void searchTransactions(String query) {
    searchQuery = query;
    loadTransactions(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => loadTransactions(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: CustomTextField(
              controller: searchController,
              hintText: 'Cari transaksi...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (searchController.text == value) {
                    searchTransactions(value);
                  }
                });
              },
            ),
          ),

          // Transaction List
          Expanded(
            child: Obx(() {
              if (isLoading.value && transactions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (transactions.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: searchQuery.isEmpty
                      ? 'Belum ada transaksi'
                      : 'Transaksi tidak ditemukan',
                  message: searchQuery.isEmpty
                      ? 'Transaksi akan muncul di sini'
                      : 'Coba kata kunci lain',
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppTheme.spacing16),
                itemCount: transactions.length + (hasMoreData.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == transactions.length) {
                    return Obx(() => isLoadingMore.value
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppTheme.spacing16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox.shrink());
                  }

                  final transaction = transactions[index];
                  return _buildTransactionCard(context, transaction);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, transaction) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: InkWell(
        onTap: () => _showTransactionDetail(transaction),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction.transactionCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      transaction.status.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                dateFormat.format(transaction.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Kasir: ${transaction.userName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: AppTheme.spacing16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total'),
                      Text(
                        widget.controller.currencyFormat
                            .format(transaction.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Metode'),
                      Text(
                        transaction.paymentMethod,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTransactionDetail(transaction) async {
    final items = await widget.controller.transactionRepository
        .getTransactionItems(transaction.id!);

    Get.dialog(
      AlertDialog(
        title: Text(transaction.transactionCode),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Tanggal',
                  DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
                      .format(transaction.createdAt)),
              _buildDetailRow('Kasir', transaction.userName),
              _buildDetailRow('Status', transaction.status.toUpperCase()),
              _buildDetailRow('Metode Bayar', transaction.paymentMethod),
              const Divider(),
              const Text(
                'Item Produk',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.spacing8),
              ...items.map((item) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child:
                              Text('${item.productName} (${item.quantity}x)'),
                        ),
                        Text(
                          widget.controller.currencyFormat
                              .format(item.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
              const Divider(),
              _buildDetailRow(
                  'Subtotal',
                  widget.controller.currencyFormat
                      .format(transaction.subtotal)),
              if (transaction.discount > 0)
                _buildDetailRow('Diskon',
                    '-${widget.controller.currencyFormat.format(transaction.discount)}'),
              if (transaction.tax > 0)
                _buildDetailRow('Pajak',
                    widget.controller.currencyFormat.format(transaction.tax)),
              const Divider(),
              _buildDetailRow('Total',
                  widget.controller.currencyFormat.format(transaction.total),
                  isTotal: true),
              _buildDetailRow('Bayar',
                  widget.controller.currencyFormat.format(transaction.paid)),
              _buildDetailRow('Kembali',
                  widget.controller.currencyFormat.format(transaction.change)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.snackbar('Info', 'Fitur print akan segera tersedia');
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.primaryLight : null,
            ),
          ),
        ],
      ),
    );
  }
}
