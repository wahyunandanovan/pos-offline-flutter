import 'dart:io';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_offline/app/modules/pos/models/transaction_item_model.dart';
import 'package:pos_offline/app/modules/pos/models/transaction_model.dart';

class ThermalPrinterService extends GetxController {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  final connectedDevice = Rx<BluetoothDevice?>(null);
  final isConnected = false.obs;
  final availableDevices = <BluetoothDevice>[].obs;
  final isScanning = false.obs;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void onInit() {
    super.onInit();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // Request Bluetooth permissions for Android 12+
    if (Platform.isAndroid) {
      final status = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (status[Permission.bluetooth]!.isDenied ||
          status[Permission.bluetoothScan]!.isDenied ||
          status[Permission.bluetoothConnect]!.isDenied) {
        Get.snackbar(
          'Permission Denied',
          'Bluetooth permission diperlukan untuk print',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Check if already connected
    final connected = await bluetooth.isConnected ?? false;
    isConnected.value = connected;
  }

  Future<void> scanDevices() async {
    try {
      isScanning.value = true;
      availableDevices.clear();

      final devices = await bluetooth.getBondedDevices();
      availableDevices.value = devices;

      if (devices.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada printer yang dipasangkan. Silakan pasangkan printer di pengaturan Bluetooth.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memindai perangkat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }

  Future<bool> connectDevice(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      connectedDevice.value = device;
      isConnected.value = true;

      Get.snackbar(
        'Terhubung',
        'Berhasil terhubung ke ${device.name}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal terhubung: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
      connectedDevice.value = null;
      isConnected.value = false;

      Get.snackbar(
        'Terputus',
        'Printer terputus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memutus koneksi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> printReceipt({
    required TransactionModel transaction,
    required List<TransactionItemModel> items,
    String? storeName,
    String? storeAddress,
    String? storePhone,
  }) async {
    try {
      final connected = await bluetooth.isConnected ?? false;
      if (!connected) {
        Get.snackbar(
          'Error',
          'Printer tidak terhubung. Silakan hubungkan printer terlebih dahulu.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Print header
      bluetooth.printNewLine();
      bluetooth.printCustom(
        storeName ?? 'TOKO SAYA',
        Size.extraLarge.val,
        Align.center.val,
      );
      bluetooth.printNewLine();

      if (storeAddress != null) {
        bluetooth.printCustom(
          storeAddress,
          Size.medium.val,
          Align.center.val,
        );
      }

      if (storePhone != null) {
        bluetooth.printCustom(
          'Telp: $storePhone',
          Size.medium.val,
          Align.center.val,
        );
      }

      bluetooth.printNewLine();
      bluetooth.printCustom(
        '================================',
        Size.medium.val,
        Align.center.val,
      );

      // Print transaction info
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
      bluetooth.printLeftRight(
        'No',
        transaction.transactionCode,
        Size.medium.val,
      );
      bluetooth.printLeftRight(
        'Tanggal',
        dateFormat.format(transaction.createdAt),
        Size.medium.val,
      );
      bluetooth.printLeftRight(
        'Kasir',
        transaction.userName,
        Size.medium.val,
      );

      bluetooth.printCustom(
        '================================',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printNewLine();

      // Print items
      for (var item in items) {
        // Item name
        bluetooth.printCustom(
          item.productName,
          Size.medium.val,
          Align.left.val,
        );

        // Quantity x Price = Subtotal
        final qtyPrice =
            '${item.quantity} x ${currencyFormat.format(item.price)}';
        final subtotal = currencyFormat.format(item.subtotal);
        bluetooth.printLeftRight(
          qtyPrice,
          subtotal,
          Size.medium.val,
        );

        // Discount if any
        if (item.discount > 0) {
          bluetooth.printLeftRight(
            '  Diskon',
            '- ${currencyFormat.format(item.discount)}',
            Size.medium.val,
          );
        }

        bluetooth.printNewLine();
      }

      bluetooth.printCustom(
        '--------------------------------',
        Size.medium.val,
        Align.center.val,
      );

      // Print totals
      bluetooth.printLeftRight(
        'Subtotal',
        currencyFormat.format(transaction.subtotal),
        Size.medium.val,
      );

      if (transaction.discount > 0) {
        bluetooth.printLeftRight(
          'Diskon',
          '- ${currencyFormat.format(transaction.discount)}',
          Size.medium.val,
        );
      }

      if (transaction.tax > 0) {
        bluetooth.printLeftRight(
          'Pajak',
          currencyFormat.format(transaction.tax),
          Size.medium.val,
        );
      }

      bluetooth.printCustom(
        '================================',
        Size.medium.val,
        Align.center.val,
      );

      bluetooth.printLeftRight(
        'TOTAL',
        currencyFormat.format(transaction.total),
        Size.extraLarge.val,
        format: "1",
      );

      bluetooth.printCustom(
        '================================',
        Size.medium.val,
        Align.center.val,
      );

      // Print payment info
      bluetooth.printLeftRight(
        'Tunai',
        currencyFormat.format(transaction.paid),
        Size.medium.val,
      );
      bluetooth.printLeftRight(
        'Kembali',
        currencyFormat.format(transaction.change),
        Size.medium.val,
      );
      bluetooth.printLeftRight(
        'Metode',
        transaction.paymentMethod,
        Size.medium.val,
      );

      bluetooth.printNewLine();
      bluetooth.printCustom(
        '================================',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printNewLine();

      // Print footer
      bluetooth.printCustom(
        'Terima Kasih',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printCustom(
        'Atas Kunjungan Anda',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printNewLine();
      bluetooth.printCustom(
        'Barang yang sudah dibeli',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printCustom(
        'tidak dapat dikembalikan',
        Size.medium.val,
        Align.center.val,
      );

      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();

      Get.snackbar(
        'Sukses',
        'Struk berhasil dicetak',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencetak struk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> testPrint() async {
    try {
      final connected = await bluetooth.isConnected ?? false;
      if (!connected) {
        Get.snackbar(
          'Error',
          'Printer tidak terhubung',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      bluetooth.printNewLine();
      bluetooth.printCustom(
        'TEST PRINT',
        Size.extraLarge.val,
        Align.center.val,
      );
      bluetooth.printNewLine();
      bluetooth.printCustom(
        'Printer berhasil terhubung',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printCustom(
        'dan siap digunakan',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printNewLine();
      bluetooth.printCustom(
        '================================',
        Size.medium.val,
        Align.center.val,
      );
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();

      Get.snackbar(
        'Sukses',
        'Test print berhasil',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal test print: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

enum Size { small, medium, large, extraLarge }

extension SizeValue on Size {
  int get val {
    switch (this) {
      case Size.small:
        return 0;
      case Size.medium:
        return 1;
      case Size.large:
        return 2;
      case Size.extraLarge:
        return 3;
    }
  }
}

enum Align { left, center, right }

extension AlignValue on Align {
  int get val {
    switch (this) {
      case Align.left:
        return 0;
      case Align.center:
        return 1;
      case Align.right:
        return 2;
    }
  }
}
