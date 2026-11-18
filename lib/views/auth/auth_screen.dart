import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controllers/auth_controller.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/app_images_constant.dart';
import 'login_form.dart';

class AuthScreen extends StatelessWidget {
  final AuthController controller = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.authBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: const SafeArea(child: LoginForm()),
      ),
    );
  }
}
