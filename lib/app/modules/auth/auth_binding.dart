import 'package:get/get.dart';
import 'auth_controller.dart';
import 'providers/auth_provider.dart';
import 'repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthProvider(), fenix: true);
    Get.lazyPut(() => AuthRepository(Get.find()), fenix: true);
    Get.lazyPut(() => AuthController(Get.find()), fenix: true);
  }
}
