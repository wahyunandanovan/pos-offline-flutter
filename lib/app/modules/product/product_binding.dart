import 'package:get/get.dart';
import 'package:pos_offline/app/modules/product/import/import_product_controller.dart';
import 'providers/product_provider.dart';
import 'repositories/product_repository.dart';
import 'product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductProvider());
    Get.lazyPut(() => ProductRepository(Get.find()));
    Get.lazyPut(() => ProductController(Get.find()));
    Get.lazyPut(() => ImportProductController(Get.find()));
  }
}
