// lib/app/modules/product/import/import_product_controller.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ImportProductController extends GetxController {
  final ProductRepository repository;

  ImportProductController(this.repository);

  // Import state
  final isImporting = false.obs;
  final importProgress = 0.0.obs;
  final importedProducts = <ProductModel>[].obs;
  final importErrors = <String>[].obs;

  // CSV file
  File? csvFile;
  final fileName = ''.obs;

  // Statistics
  final totalRows = 0.obs;
  final successCount = 0.obs;
  final errorCount = 0.obs;

  /// Pick CSV file
  Future<void> pickCSVFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        csvFile = File(result.files.first.path!);
        fileName.value = result.files.first.name;

        // Parse and preview
        await _parseCSV();

        Get.snackbar(
          'Berhasil',
          'File CSV berhasil dimuat: ${fileName.value}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Parse CSV file
  Future<void> _parseCSV() async {
    try {
      if (csvFile == null) return;

      final input = csvFile!.readAsStringSync();
      final fields = const CsvToListConverter().convert(
        input,
        eol: '\n',
        fieldDelimiter: ',',
      );

      if (fields.isEmpty) {
        throw Exception('File CSV kosong');
      }

      // Skip header row
      final dataRows = fields.skip(1).toList();
      totalRows.value = dataRows.length;

      importedProducts.clear();
      importErrors.clear();

      for (var i = 0; i < dataRows.length; i++) {
        try {
          final row = dataRows[i];

          // Validate row length
          if (row.length < 6) {
            importErrors.add('Baris ${i + 2}: Data tidak lengkap');
            continue;
          }

          // Parse product
          final product = ProductModel(
            sku: _cleanString(row[0]),
            name: _cleanString(row[1]),
            description: row.length > 2 ? _cleanString(row[2]) : null,
            category: row.length > 3 ? _cleanString(row[3]) : null,
            buyPrice: _parseDouble(row[4]),
            sellPrice: _parseDouble(row[5]),
            stock: row.length > 6 ? _parseInt(row[6]) : 0,
            minStock: row.length > 7 ? _parseInt(row[7]) : 0,
            barcode: row.length > 8 ? _cleanString(row[8]) : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Validate product
          final error = _validateProduct(product, i + 2);
          if (error != null) {
            importErrors.add(error);
            continue;
          }

          importedProducts.add(product);
        } catch (e) {
          importErrors.add('Baris ${i + 2}: Error parsing - $e');
        }
      }

      successCount.value = importedProducts.length;
      errorCount.value = importErrors.length;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memproses CSV: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Import products to database
  Future<void> importProducts() async {
    if (importedProducts.isEmpty) {
      Get.snackbar(
        'Error',
        'Tidak ada produk yang valid untuk di-import',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isImporting.value = true;
      importProgress.value = 0.0;

      int imported = 0;
      int skipped = 0;

      for (var i = 0; i < importedProducts.length; i++) {
        try {
          final product = importedProducts[i];

          // Check if SKU exists
          final exists = await repository.skuExists(product.sku);

          if (exists) {
            skipped++;
            importErrors.add('SKU ${product.sku} sudah ada, dilewati');
          } else {
            await repository.createProduct(product);
            imported++;
          }

          importProgress.value = (i + 1) / importedProducts.length;
        } catch (e) {
          importErrors.add('Gagal import ${importedProducts[i].name}: $e');
        }
      }

      Get.back(); // Close dialog

      Get.dialog(
        AlertDialog(
          title: const Text('Import Selesai'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Berhasil: $imported produk'),
              Text('⏭️ Dilewati: $skipped produk (SKU sudah ada)'),
              if (importErrors.isNotEmpty)
                Text('❌ Error: ${importErrors.length}'),
            ],
          ),
          actions: [
            if (importErrors.isNotEmpty)
              TextButton(
                onPressed: () {
                  Get.back();
                  _showErrorsDialog();
                },
                child: const Text('Lihat Error'),
              ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back(); // Back to product list
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      );

      // Reset state
      _reset();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal import produk: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isImporting.value = false;
    }
  }

  void _showErrorsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Import Errors'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: importErrors.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${index + 1}. ${importErrors[index]}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String? _validateProduct(ProductModel product, int rowNumber) {
    if (product.sku.isEmpty) {
      return 'Baris $rowNumber: SKU tidak boleh kosong';
    }
    if (product.name.isEmpty) {
      return 'Baris $rowNumber: Nama produk tidak boleh kosong';
    }
    if (product.buyPrice < 0) {
      return 'Baris $rowNumber: Harga beli tidak valid';
    }
    if (product.sellPrice < 0) {
      return 'Baris $rowNumber: Harga jual tidak valid';
    }
    if (product.sellPrice < product.buyPrice) {
      return 'Baris $rowNumber: Harga jual harus lebih dari harga beli';
    }
    return null;
  }

  String _cleanString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll(',', '');
    return double.tryParse(str) ?? 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  void _reset() {
    csvFile = null;
    fileName.value = '';
    importedProducts.clear();
    importErrors.clear();
    totalRows.value = 0;
    successCount.value = 0;
    errorCount.value = 0;
    importProgress.value = 0.0;
  }

  /// Download template CSV
  Future<void> downloadTemplate() async {
    try {
      final template = [
        [
          'SKU',
          'Nama',
          'Deskripsi',
          'Kategori',
          'Harga Beli',
          'Harga Jual',
          'Stok',
          'Stok Minimal',
          'Barcode'
        ],
        [
          'PRD001',
          'Contoh Produk 1',
          'Deskripsi produk',
          'Makanan',
          '2500',
          '3500',
          '100',
          '20',
          '8992388101'
        ],
        [
          'PRD002',
          'Contoh Produk 2',
          'Deskripsi produk',
          'Minuman',
          '2000',
          '3000',
          '150',
          '30',
          '8991234567'
        ],
      ];

      final csv = const ListToCsvConverter().convert(template);

      // Save to downloads
      final directory = await getDownloadsDirectory();
      final file = File('${directory!.path}/template_import_produk.csv');
      await file.writeAsString(csv);

      Get.snackbar(
        'Berhasil',
        'Template berhasil diunduh ke:\n${file.path}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunduh template: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

// Helper function for downloads directory
Future<Directory?> getDownloadsDirectory() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  } else {
    return await getApplicationDocumentsDirectory();
  }
}
