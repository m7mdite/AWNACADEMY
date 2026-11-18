import 'dart:io';

import 'package:get/get.dart';

import '../../models/admin_models/advertisement_model.dart';
import '../../services/remote/admin_remotes/admin_remote.dart';
import '../../services/remote/crud.dart';
import '../../utils/app_constants/status_request.dart';

abstract class AdminHomeCntr extends GetxController {}

class AdminHomeController extends AdminHomeCntr {
  final AdminRemote remote = AdminRemote(Get.find<Crud>());
  RxList<AdvertisementModel> advertisements = <AdvertisementModel>[].obs;
  RxBool isLoading = false.obs;
  Rx<StatusRequest> statusRequest = StatusRequest.none.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdvertisements();
  }

  Future<void> fetchAdvertisements() async {
    isLoading.value = true;
    statusRequest.value = StatusRequest.loading;
    try {
      final result = await remote.getAllAdvertisements();
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest.value = StatusRequest.success;
          final List<dynamic> data = body['data'] ?? [];
          advertisements.value =
              data.map((json) => AdvertisementModel.fromJson(json)).toList();
        case ApiFailure(:final status, :final message):
          statusRequest.value = status;
          Get.snackbar('خطأ', message ?? 'فشل تحميل الإعلانات');
      }
    } catch (_) {
      statusRequest.value = StatusRequest.serverFailure;
      Get.snackbar('خطأ', 'فشل تحميل الإعلانات');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAdvertisement(String content, File imageFile) async {
    if (content.trim().isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء كتابة محتوى الإعلان');
      return;
    }
    isLoading.value = true;
    try {
      final result = await remote.createAdvertisement(
          content: content, imageFile: imageFile);
      switch (result) {
        case ApiSuccess():
          Get.back(); // إغلاق الحوار
          await fetchAdvertisements();
          Get.snackbar('نجاح', 'تم إضافة الإعلان بنجاح');
        case ApiFailure(:final message):
          Get.snackbar('خطأ', message ?? 'فشل الإضافة');
      }
    } catch (_) {
      Get.snackbar('خطأ', 'فشل الإضافة');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAdvertisement(String id) async {
    isLoading.value = true;
    try {
      final result = await remote.deleteAdvertisement(id);
      switch (result) {
        case ApiSuccess():
          advertisements.removeWhere((adv) => adv.sId == id);
          Get.snackbar('نجاح', 'تم حذف الإعلان بنجاح');
        case ApiFailure(:final message):
          Get.snackbar('خطأ', message ?? 'فشل الحذف');
      }
    } catch (_) {
      Get.snackbar('خطأ', 'فشل الحذف');
    } finally {
      isLoading.value = false;
    }
  }
}
