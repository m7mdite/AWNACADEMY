import 'package:get/get.dart';
import '../../models/public_models/profile_model.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/public_remote.dart';
import '../../utils/app_constants/status_request.dart';

class PublicController extends GetxController {
  late StatusRequest statusRequest;
  PublicRemote publicRemote = PublicRemote(Get.find());
  ProfileModel? otherProfile;

  Future<void> getOtherProfile(String id) async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await publicRemote.getOtherProfile(id);
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          otherProfile = ProfileModel.fromJson(body['data']);
        case ApiFailure(:final status):
          statusRequest = status;
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
    }
    update();
  }

  Future<bool> reportUser({
    required String userId,
    required String reason,
    required String description,
  }) async {
    return _submit(
      () => publicRemote.reportUser(userId, reason, description),
      fallbackError: 'تعذر إرسال البلاغ',
    );
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    return _submit(
      () => publicRemote.changePassword(oldPassword, newPassword),
      fallbackError: 'تعذر تغيير كلمة المرور',
    );
  }

  /// تنفيذ طلب POST يرجع نجاح/فشل، مع عرض رسالة السيرفر عند الفشل.
  Future<bool> _submit(
    Future<ApiResult> Function() request, {
    required String fallbackError,
  }) async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await request();
      switch (result) {
        case ApiSuccess():
          statusRequest = StatusRequest.success;
          update();
          return true;
        case ApiFailure(:final message):
          statusRequest = StatusRequest.failure;
          Get.snackbar('خطأ', message ?? fallbackError);
          update();
          return false;
      }
    } catch (_) {
      statusRequest = StatusRequest.failure;
      update();
      return false;
    }
  }
}
