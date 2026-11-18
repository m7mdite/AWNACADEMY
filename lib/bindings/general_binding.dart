import 'package:get/get.dart';

import '../controllers/conversations_controllers/conversations_controller.dart';
import '../controllers/public_controllers/public_controller.dart';
import '../controllers/public_controllers/unified_setting_controller.dart';
import '../services/remote/crud.dart';
import '../services/local_storge/secure_storage_service.dart';

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SecureStorageService(), permanent: true);
    Get.put(Crud(), permanent: true);
    Get.lazyPut<UnifiedSettingController>(() => UnifiedSettingController(),fenix: true);
    Get.lazyPut<PublicController>(() => PublicController(), fenix: true);
    Get.lazyPut<ConversationsController>(() => ConversationsController(), fenix: true);
  }
}