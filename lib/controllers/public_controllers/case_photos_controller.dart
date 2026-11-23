import 'package:get/get.dart';

import '../../api_link.dart';
import '../../models/requests_models/case_photos_model.dart';
import '../../services/functions/show_snack.dart';
import '../../services/remote/crud.dart';

/// طلب إعادة تصوير صورة (قبل / بعد) من طرف المشرف.
class CasePhotosController extends GetxController {
  final Crud _crud = Get.find<Crud>();

  /// يرجع طلب إعادة التصوير المحفوظ، أو null عند الفشل (مع إظهار رسالة السيرفر).
  Future<RetakeRequest?> requestRetake({
    required String requestId,
    required String which,
    required String note,
  }) async {
    final result = await _crud.putData(
      '${ApiLink.servere}/overseer/treatment/request-retake/$requestId',
      {'which': which, 'note': note},
    );

    RetakeRequest? out;
    switch (result) {
      case ApiSuccess(data: final body):
        showsnack(
          title: 'تم',
          message: body['message']?.toString() ?? 'تم إرسال طلب إعادة التصوير',
        );
        final data = body['data'];
        if (data is Map) out = RetakeRequest.tryParse(data['retake_request']);
      case ApiFailure(:final message):
        showsnack(title: 'خطأ', message: message ?? 'تعذر إرسال الطلب');
    }
    return out;
  }
}
