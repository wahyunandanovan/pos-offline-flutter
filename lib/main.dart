import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_offline/app/core/theme/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/core/theme/app_theme.dart';
import 'app/core/utils/db_helper.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Initialize Database
  await DBHelper.instance.database;

// Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // Initialize ThemeService
  final themeService = ThemeService();
  await themeService.init();
  Get.put(themeService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(() => GetMaterialApp(
          title: 'POS Offline',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.currentThemeMode.value,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.SPLASH,
          getPages: AppPages.pages,
          defaultTransition: Transition.fade,
        ));
  }
}
