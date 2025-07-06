import 'package:get/get.dart';
import 'core/services/storage/cloudflare_storage_service.dart';
import 'core/services/storage/storage_service_interface.dart';
import 'features/auth/controllers/auth_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);

    Get.put<IStorageService>(CloudflareStorageService(), permanent: true);
  }
}