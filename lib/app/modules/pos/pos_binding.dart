import 'package:get/get.dart';
import '../product/product_binding.dart';
import 'providers/transaction_provider.dart';
import 'repositories/transaction_repository.dart';
import 'pos_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    ProductBinding().dependencies();
    Get.lazyPut(() => TransactionProvider());
    Get.lazyPut(() => TransactionRepository(Get.find()));
    Get.lazyPut(() => PosController(Get.find(), Get.find()));
  }
}
