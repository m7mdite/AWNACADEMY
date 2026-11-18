import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_route.dart';
import '../../services/notification/websocket_service.dart';
import '../../services/remote/crud.dart';
import '../../services/local_storge/local_user_storage.dart';
import '../../services/remote/public_remotes/auth_remote.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/status_request.dart';

abstract class LoginController extends GetxController {
  Future<void> login();
  Future<void> toHome(Map<String, dynamic> response);
}

class LoginControllerImp extends LoginController {
  late TextEditingController email;
  late TextEditingController password;

  final Map<String, String> data = <String, String>{};
  final GlobalKey<FormState> formStateLogin = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  late StatusRequest statusRequest;

  WebSocketService get webSocketService => Get.find<WebSocketService>();
  final LocalUserStorage storage = Get.find<LocalUserStorage>();
  final AuthRemote authRemote = AuthRemote(Get.find());

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  void fillMap() {
    data['email'] = email.text;
    data['password'] = password.text;
  }

  @override
  Future<void> login() async {
    if (isLoading.value) return;
    fillMap();
    final formData = formStateLogin.currentState;
    if (formData == null || !formData.validate()) return;

    isLoading.value = true;
    statusRequest = StatusRequest.loading;
    update();

    try {
      final result = await authRemote.login(data);
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          await toHome(body);
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          _showError(message ?? 'فشل في الاتصال بالخادم');
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      _showError('حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  Future<void> toHome(Map<String, dynamic> response) async {
    if (response['status'] != 'success') {
      _showError(response['message']?.toString() ?? 'حدث خطأ غير معروف');
      return;
    }

    final user = response['data'];
    final bool isAdmin = user['is_admin'] == true;
    final bool isOverseer = user['role'] == 'overseer';

    // نتحقق من الدور قبل حفظ أي شيء: هذا التطبيق للأدمن والمشرف فقط
    if (!isAdmin && !isOverseer) {
      _showError('هذا التطبيق غير مخصص لك');
      return;
    }

    await storage.saveAllFromJson(user);
    await storage.saveToken(response['token']);

    if (isAdmin) {
      await storage.saveRole('admin');
      Get.offAndToNamed(
        AppRroute.mainScreenAdmin,
        arguments: {'role': 'admin'},
      );
      Get.snackbar('نجاح التسجيل', 'اهلا بك مديري',
          backgroundColor: AppColors.success, colorText: AppColors.white);
    } else {
      Get.offAndToNamed(AppRroute.mainScreenOverseer);
      Get.snackbar('نجاح', 'اهلا بك ${user['first_name']}',
          backgroundColor: AppColors.success, colorText: AppColors.white);
    }

    webSocketService.connect(user['_id']);
  }

  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
