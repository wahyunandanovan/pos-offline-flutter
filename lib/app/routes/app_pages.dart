import 'package:get/get.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/user/user_binding.dart';
import '../modules/user/views/user_list_view.dart';
import '../modules/user/views/user_form_view.dart';
import '../modules/user/views/profile_view.dart';
import '../modules/product/product_binding.dart';
import '../modules/product/views/product_list_view.dart';
import '../modules/product/views/product_form_view.dart';
import '../modules/pos/pos_binding.dart';
import '../modules/pos/views/pos_view.dart';
import '../modules/pos/views/transaction_history_view.dart';
import '../modules/reports/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/product/import/import_product_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.USERS,
      page: () => const UserListView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.USER_FORM,
      page: () => const UserFormView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.PRODUCTS,
      page: () => const ProductListView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.PRODUCT_FORM,
      page: () => const ProductFormView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.POS,
      page: () => const PosView(),
      binding: PosBinding(),
    ),
    GetPage(
      name: AppRoutes.TRANSACTION_HISTORY,
      page: () => const TransactionHistoryView(),
      binding: PosBinding(),
    ),
    GetPage(
      name: AppRoutes.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.IMPORT_PRODUCT,
      page: () => const ImportProductView(),
      binding: ProductBinding(), // Reuse product binding
    ),
  ];
}
