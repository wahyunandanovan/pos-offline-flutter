import 'package:get/get.dart';
import 'providers/user_provider.dart';
import 'repositories/user_repository.dart';
import 'user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserProvider());
    Get.lazyPut(() => UserRepository(Get.find()));
    Get.lazyPut(() => UserController(Get.find()));
  }
}
