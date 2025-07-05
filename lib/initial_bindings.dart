import 'package:get/get.dart';
import 'core/services/storage_service.dart';
import 'features/auth/controllers/auth_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put(StorageService(), permanent: true);
  }
}