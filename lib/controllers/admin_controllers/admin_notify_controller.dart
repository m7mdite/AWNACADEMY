// controllers/admin_controllers/admin_notify_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/remote/admin_remotes/admin_remote.dart';
import '../../services/remote/crud.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/status_request.dart';

class AdminNotifyController extends GetxController {
  final AdminRemote adminRemote = AdminRemote(Get.find<Crud>());

  // Controllers للنصوص
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  // الأدوار المختارة
  RxList<String> selectedRoles = <String>[].obs;
  RxBool isLoading = false.obs;
  Rx<StatusRequest> statusRequest = StatusRequest.none.obs;

  // قائمة الأدوار المتاحة مع تسمياتها
  final List<Map<String, dynamic>> availableRoles = [
    {'value': 'student', 'label': 'طلاب', 'icon': Icons.school},
    {'value': 'patient', 'label': 'مرضى', 'icon': Icons.health_and_safety},
    {'value': 'overseer', 'label': 'مشرفين', 'icon': Icons.verified_user},
    {'value': 'admin', 'label': 'مديرين', 'icon': Icons.admin_panel_settings},
  ];

  @override
  void onInit() {
    super.onInit();
    // تحديد دور "student" كافتراضي
    selectedRoles.add('student');
  }

  void toggleRole(String role) {
    if (selectedRoles.contains(role)) {
      selectedRoles.remove(role);
    } else {
      selectedRoles.add(role);
    }
    update();
  }

  bool isRoleSelected(String role) {
    return selectedRoles.contains(role);
  }

  Future<void> sendNotification() async {
    if (isLoading.value) return;
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء كتابة عنوان الإشعار');
      return;
    }
    if (body.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء كتابة محتوى الإشعار');
      return;
    }
    if (selectedRoles.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء اختيار دور واحد على الأقل');
      return;
    }

    isLoading.value = true;
    statusRequest.value = StatusRequest.loading;
    update();

    try {
      final result = await adminRemote.notifyUsersByRoles(
        title: title,
        body: body,
        roles: selectedRoles,
      );
      switch (result) {
        case ApiSuccess(data: final data):
          statusRequest.value = StatusRequest.success;
          titleController.clear();
          bodyController.clear();
          // لا نغلق الديالوج تلقائياً لنعرض للمستخدم النتيجة
          Get.snackbar(
            'نجاح',
            data['message']?.toString() ?? 'تم إرسال الإشعار بنجاح',
            backgroundColor: AppColors.background,
            duration: const Duration(seconds: 4),
          );
        case ApiFailure(:final status, :final message):
          statusRequest.value = status;
          _showError(message ?? 'فشل إرسال الإشعار');
      }
    } catch (_) {
      statusRequest.value = StatusRequest.serverFailure;
      _showError('فشل إرسال الإشعار');
    } finally {
      isLoading.value = false;
      update();
    }
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
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }
}
