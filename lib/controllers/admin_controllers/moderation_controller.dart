import 'package:get/get.dart';

import '../../api_link.dart';
import '../../models/admin_models/moderation_model.dart';
import '../../services/functions/show_snack.dart';
import '../../services/remote/crud.dart';

/// حالة حساب مستخدم وتنفيذ الإجراءات (تحذير / إيقاف / حظر / رفع).
class ModerationController extends GetxController {
  final Crud _crud = Get.find<Crud>();

  ModerationInfo? info;
  bool loading = false;
  bool saving = false;
  String? error;

  String _url(String userId) => '${ApiLink.servere}/admin/users/$userId/moderation';

  Future<void> load(String userId) async {
    loading = true;
    error = null;
    update();

    final result = await _crud.getData(_url(userId));
    switch (result) {
      case ApiSuccess(data: final body):
        final data = body['data'];
        if (data is Map) {
          info = ModerationInfo.fromJson(Map<String, dynamic>.from(data));
        } else {
          error = 'تعذر قراءة بيانات المستخدم';
        }
      case ApiFailure(:final message):
        error = message ?? 'تعذر تحميل بيانات المستخدم';
    }

    loading = false;
    update();
  }

  /// ينفذ الإجراء. يرجع النتيجة أو null عند الفشل (مع رسالة السيرفر).
  Future<ModerationResult?> apply({
    required String userId,
    required String action,
    String? reason,
    int? days,
    String? reportId,
  }) async {
    saving = true;
    update();

    final result = await _crud.putData(_url(userId), {
      'action': action,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
      if (days != null) 'days': days,
      if (reportId != null) 'reportId': reportId,
    });

    ModerationResult? out;
    switch (result) {
      case ApiSuccess(data: final body):
        showsnack(title: 'تم', message: body['message']?.toString() ?? 'تم تنفيذ الإجراء');
        final data = body['data'];
        if (data is Map) out = ModerationResult.fromJson(Map<String, dynamic>.from(data));
      case ApiFailure(:final message):
        showsnack(title: 'خطأ', message: message ?? 'تعذر تنفيذ الإجراء');
    }

    saving = false;
    update();
    return out;
  }
}
