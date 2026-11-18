import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app_route.dart';
import 'bindings/general_binding.dart';
import 'controllers/notifications_controllers/notification_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/local_storge/local_user_storage.dart';
import 'services/local_storge/secure_storage_service.dart';
import 'services/remote/crud.dart';
// import 'services/my_services.dart';
import 'services/remote/public_remotes/unified_profile_remote.dart';
import 'services/notification/websocket_service.dart';
import 'services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SecureStorageService(), permanent: true);
  Get.put(LocalUserStorage(), permanent: true);
  await GetStorage.init();
  Get.put(ThemeController(), permanent: true);
  Get.put(Crud(), permanent: true);
  Crud.onSessionExpired = SessionService.expireSession;

  Get.put(NotificationController(), permanent: true);
  Get.put(WebSocketService(), permanent: true);
  Get.put(UnifiedProfileRemote(Get.find()), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
     
      builder: (_) {
        return GetMaterialApp(
          locale: Locale('ar'),
          initialBinding: GeneralBinding(),
          initialRoute: AppRroute.splash,
          getPages: routes,
          debugShowCheckedModeBanner: false,
          title: 'final',
        );
      },
    );
  }
}
