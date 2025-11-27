import 'package:get/get.dart';
import '../pos/pos_binding.dart';
import '../product/product_binding.dart';
import '../user/user_binding.dart';
import '../reports/reports_binding.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    PosBinding().dependencies();
    ProductBinding().dependencies();
    UserBinding().dependencies();
    ReportsBinding().dependencies();
  }
}
