import 'package:get/get.dart';
import '../../controllers/theme_controller.dart'; // عدّل المسار حسب مكان الملف عندك

/// AppImages
/// -----------------------------------------------------------------
/// نفس فكرة AppColors بالضبط: الصور اللي المفروض تختلف حسب الثيم
/// (Dark / Pink / Blue) صارت static get بترجع المسار المناسب.
/// أي مكان بالكود يستخدم AppImages.authBackground بيضل هو هو،
/// بس الصورة يلي بترجع بتتغير حسب الثيم المختار.
/// -----------------------------------------------------------------
class AppImages {
  AppImages._();

  static AppThemeType get _theme => Get.isRegistered<ThemeController>()
      ? ThemeController.instance.currentTheme
      : AppThemeType.blue;

  /// خلفية شاشة تسجيل الدخول / إنشاء الحساب
  static String get authBackground {
    switch (_theme) {
      case AppThemeType.dark:
        return "images/images_asnan/back_dark.png";
      case AppThemeType.pink:
        return "images/images_asnan/back_pink.png";
      case AppThemeType.blue:
        return "images/images_asnan/back_blue.png"; 

    }
  }


}
