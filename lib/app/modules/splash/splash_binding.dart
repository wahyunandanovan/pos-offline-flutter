import 'package:get/get.dart';
import '../auth/auth_binding.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    Get.put(SplashController());
  }
}
