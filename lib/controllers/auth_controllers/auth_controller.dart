import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

/// وسيط بسيط بين شاشة الدخول و LoginControllerImp (التطبيق تسجيل دخول فقط).
class AuthController extends GetxController {
  final LoginControllerImp loginController = Get.find();

  TextEditingController get loginEmailController => loginController.email;
  TextEditingController get loginPasswordController => loginController.password;
  GlobalKey<FormState> get loginFormKey => loginController.formStateLogin;
  RxBool get isLoading => loginController.isLoading;

  void login() => loginController.login();
}
