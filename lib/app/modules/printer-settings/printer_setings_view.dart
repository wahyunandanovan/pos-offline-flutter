import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_offline/app/core/services/thermal_printer_service.dart';
import 'package:pos_offline/app/core/theme/app_theme.dart';

class PrinterSettingsView extends GetView<ThermalPrinterService> {
  const PrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        actions: [
          Obx(() => controller.isConnected.value
              ? IconButton(
                  icon: const Icon(Icons.bluetooth_connected),
                  color: Colors.green,
                  onPressed: controller.disconnect,
                  tooltip: 'Putuskan koneksi',
                )
              : IconButton(
                  icon: const Icon(Icons.bluetooth_disabled),
                  onPressed: null,
                )),
        ],
      ),
      body: Column(
        children: [
          // Connected Device Info
          Obx(() {
            if (controller.connectedDevice.value != null) {
              return Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                margin: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Terhubung dengan:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            controller.connectedDevice.value!.name ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.testPrint,
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Scan Button
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isScanning.value
                      ? null
                      : controller.scanDevices,
                  icon: controller.isScanning.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bluetooth_searching),
                  label: Text(controller.isScanning.value
                      ? 'Memindai...'
                      : 'Pindai Printer'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                )),
          ),

          // Available Devices List
          Expanded(
            child: Obx(() {
              if (controller.availableDevices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth_disabled,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada printer ditemukan',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pastikan printer sudah dipasangkan\ndi pengaturan Bluetooth',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                itemCount: controller.availableDevices.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final device = controller.availableDevices[index];
                  final isConnected =
                      controller.connectedDevice.value?.address ==
                          device.address;

                  return ListTile(
                    leading: Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                      color: isConnected ? Colors.green : null,
                    ),
                    title: Text(
                      device.name ?? 'Unknown Device',
                      style: TextStyle(
                        fontWeight:
                            isConnected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(device.address ?? ''),
                    trailing: isConnected
                        ? ElevatedButton(
                            onPressed: controller.disconnect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Putuskan'),
                          )
                        : ElevatedButton(
                            onPressed: () => controller.connectDevice(device),
                            child: const Text('Hubungkan'),
                          ),
                  );
                },
              );
            }),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                top: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Cara Menggunakan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Pastikan printer Bluetooth sudah menyala\n'
                  '2. Pasangkan printer di pengaturan Bluetooth HP\n'
                  '3. Klik "Pindai Printer" untuk mencari printer\n'
                  '4. Pilih printer dan klik "Hubungkan"\n'
                  '5. Klik "Test" untuk mencoba print',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
