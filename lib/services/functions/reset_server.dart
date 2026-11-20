import 'package:get/get.dart';
import '../../server_config.dart';
import '../../views/public_views/server_setup_screen.dart';
import '../../views/splash_screen.dart';
import '../../views/widgets/dialog/submit_dialog.dart';
import '../local_storge/local_user_storage.dart';
import '../notification/websocket_service.dart';

void confirmResetServer() {
  Get.dialog(
    SubmitDialog(
      title: "تغيير عنوان السيرفر",
      question:
          "سيتم تسجيل خروجك وحذف عنوان السيرفر المحفوظ لإدخال عنوان جديد.\nمتابعة؟",
      agreeBottontitle: "متابعة",
      onTapSubmit: () async {
        // SubmitDialog يغلق نفسه قبل هالاستدعاء، فلا نعمل Get.back() هون
        if (Get.isRegistered<WebSocketService>()) {
          await Get.delete<WebSocketService>(force: true);
        }
        // توكن السيرفر القديم ما بينفع مع الجديد
        await Get.find<LocalUserStorage>().clearAll();
        await ServerConfig.reset();
        Get.offAll(() => ServerSetupScreen(next: () => const SplashScreen()));
      },
    ),
  );
}