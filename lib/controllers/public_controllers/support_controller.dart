import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/support_remote.dart';

class SupportController extends GetxController {
  final SupportRemote supportRemote = SupportRemote(Get.find());
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final isLoading = false.obs;

  Future<void> sendMessage() async {
    if (!formKey.currentState!.validate()) return;
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final result = await supportRemote.sendSupportMessage(
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );
      switch (result) {
        case ApiSuccess():
          Get.back(); // العودة إلى الإعدادات
          Get.snackbar('تم', 'تم إرسال رسالتك بنجاح، سيتم الرد عليها قريباً',
              snackPosition: SnackPosition.BOTTOM);
        case ApiFailure(:final message):
          Get.snackbar('خطأ', message ?? 'فشل الإرسال، حاول مجدداً');
      }
    } catch (_) {
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
