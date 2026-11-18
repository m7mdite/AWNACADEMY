import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../api_link.dart';
import '../app_route.dart';
import '../controllers/theme_controller.dart';
import 'local_storge/local_user_storage.dart';
import 'notification/websocket_service.dart';
import 'remote/crud.dart';

/// إدارة نهاية الجلسة في مكان واحد: خروج يدوي، انتهاء جلسة (401)، أو بعد تغيير كلمة المرور.
class SessionService {
  static bool _busy = false;

  /// يُستدعى من Crud عند 401. لا يفعل شيئًا إن لم يكن هناك توكن محلي (مثل الضيف).
  static Future<void> expireSession() async {
    if (_busy) return;
    if (!await Get.find<LocalUserStorage>().hasToken()) return;
    await endSessionLocally(message: 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
  }

  /// تسجيل خروج يدوي: يبطل التوكن في السيرفر (إن أمكن) ثم يمسح البيانات محليًا.
  static Future<void> logout() async {
    try {
      await Get.find<Crud>().postData(
        ApiLink.logout,
        {},
        handleUnauthorized: false,
        timeout: const Duration(seconds: 5),
      );
    } catch (_) {
      // حتى لو فشل الاتصال نُكمل الخروج المحلي
    }
    await endSessionLocally();
  }

  /// مسح كل شيء محليًا والعودة إلى شاشة الدخول.
  static Future<void> endSessionLocally({String? message}) async {
    if (_busy) return;
    _busy = true;
    try {
      if (Get.isRegistered<WebSocketService>()) {
        await Get.find<WebSocketService>().disconnect();
      }
      await Get.find<LocalUserStorage>().clearAll();
      GetStorage().remove('app_theme');
      if (Get.isRegistered<ThemeController>()) {
        Get.find<ThemeController>().currentTheme = AppThemeType.blue;
        Get.forceAppUpdate();
      }
      Get.offAllNamed(AppRroute.auth);
      if (message != null) Get.snackbar('تنبيه', message);
    } finally {
      _busy = false;
    }
  }
}
