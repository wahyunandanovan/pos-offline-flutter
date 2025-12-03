import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/services/theme_service.dart';
import '../../core/services/store_settings_service.dart';
import '../../core/utils/image_helper.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = Get.find<ThemeService>();
  final StoreSettingsService _storeSettings = Get.find<StoreSettingsService>();

  Rx<ThemeMode> get currentThemeMode => _themeService.currentThemeMode;

  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeEmailController = TextEditingController();

  final selectedLogoFile = Rxn<File>();
  final isSavingSettings = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStoreSettings();
  }

  @override
  void onClose() {
    storeNameController.dispose();
    storeAddressController.dispose();
    storePhoneController.dispose();
    storeEmailController.dispose();
    super.onClose();
  }

  void loadStoreSettings() {
    storeNameController.text = _storeSettings.storeName.value;
    storeAddressController.text = _storeSettings.storeAddress.value;
    storePhoneController.text = _storeSettings.storePhone.value;
    storeEmailController.text = _storeSettings.storeEmail.value;
  }

  void setThemeMode(ThemeMode mode) {
    _themeService.setThemeMode(mode);
  }

  String getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      default:
        return 'Sistem';
    }
  }

  IconData getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  Future<void> pickStoreLogo({bool fromCamera = false}) async {
    try {
      final File? imageFile =
          await ImageHelper.pickImage(fromCamera: fromCamera);
      if (imageFile != null) {
        selectedLogoFile.value = imageFile;

        Get.snackbar(
          'Berhasil',
          'Logo berhasil dipilih',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih logo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeStoreLogo() async {
    selectedLogoFile.value = null;

    if (_storeSettings.storeLogoPath.value != null) {
      await ImageHelper.deleteImage(_storeSettings.storeLogoPath.value!);
      await _storeSettings.saveStoreLogoPath(null);
    }
  }

  Future<void> saveStoreSettings() async {
    if (storeNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Nama toko harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSavingSettings.value = true;

      // Save logo if selected
      String? logoPath = _storeSettings.storeLogoPath.value;
      if (selectedLogoFile.value != null) {
        // Delete old logo if exists
        if (logoPath != null) {
          await ImageHelper.deleteImage(logoPath);
        }

        // Save new logo
        logoPath = await ImageHelper.saveImageToLocal(
          selectedLogoFile.value!,
          'store_logo',
        );
      }

      // Save all settings
      await _storeSettings.saveAllSettings(
        name: storeNameController.text.trim(),
        address: storeAddressController.text.trim(),
        phone: storePhoneController.text.trim(),
        email: storeEmailController.text.trim(),
        logoPath: logoPath,
      );

      Get.snackbar(
        'Berhasil',
        'Pengaturan toko berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan pengaturan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSavingSettings.value = false;
    }
  }
}
