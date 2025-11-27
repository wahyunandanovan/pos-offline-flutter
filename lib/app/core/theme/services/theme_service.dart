import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static const String _themeKey = 'theme_mode';

  late SharedPreferences _prefs;
  final currentThemeMode = ThemeMode.system.obs;

  Future<ThemeService> init() async {
    _prefs = Get.find<SharedPreferences>();
    await _loadTheme();
    return this;
  }

  Future<void> _loadTheme() async {
    final themeString = _prefs.getString(_themeKey);
    if (themeString != null) {
      currentThemeMode.value = _themeModeFromString(themeString);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    currentThemeMode.value = mode;
    await _prefs.setString(_themeKey, _themeModeToString(mode));
    Get.changeThemeMode(mode);
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  bool get isDarkMode {
    if (currentThemeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return currentThemeMode.value == ThemeMode.dark;
  }
}
