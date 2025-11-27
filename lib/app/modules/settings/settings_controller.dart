import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_offline/app/core/theme/services/theme_service.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = Get.find<ThemeService>();

  Rx<ThemeMode> get currentThemeMode => _themeService.currentThemeMode;

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
}
