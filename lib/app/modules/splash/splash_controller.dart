import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 2));

    // Initialize AuthController
    Get.find<AuthController>();
    final authController = Get.find<AuthController>();

    await authController.checkLoginStatus();

    if (authController.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
