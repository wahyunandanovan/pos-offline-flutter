import 'package:get/get.dart';
import 'providers/report_provider.dart';
import 'repositories/report_repository.dart';
import 'reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportProvider());
    Get.lazyPut(() => ReportRepository(Get.find()));
    Get.lazyPut(() => ReportsController(Get.find()));
  }
}
