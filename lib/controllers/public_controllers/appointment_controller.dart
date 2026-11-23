import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api_link.dart';
import '../../models/requests_models/appointment_model.dart';
import '../../services/functions/show_snack.dart';
import '../../services/remote/crud.dart';

/// مواعيد الحالة: الطالب يحدد/يقترح تغيير، والمريض يقبل أو يرفض.
class AppointmentController extends GetxController {
  final Crud _crud = Get.find<Crud>();

  /// يختار تاريخاً ثم وقتاً. يرجع null عند الإلغاء أو إذا كان الموعد غير مستقبلي.
  Future<DateTime?> pickDateTime({DateTime? initial}) async {
    final ctx = Get.context;
    if (ctx == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: ctx,
      helpText: 'اختر تاريخ الموعد',
      initialDate: (initial != null && initial.isAfter(today))
          ? initial
          : today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: Get.context ?? ctx,
      helpText: 'اختر وقت الموعد',
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return null;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (picked.isBefore(now.add(const Duration(minutes: 5)))) {
      showsnack(title: 'تنبيه', message: 'اختر موعداً في المستقبل');
      return null;
    }
    return picked;
  }

  /// الطالب: تحديد موعد (أول موعد / موعد المراجعة) أو اقتراح تغيير موعد قائم.
  Future<AppointmentInfo?> setAppointment({
    required String requestId,
    required DateTime date,
    String? note,
    String? reason,
  }) async {
    final result = await _crud.putData(
      '${ApiLink.requests}/processing/$requestId/appointment',
      {
        'date': date.toUtc().toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return _parse(result, failText: 'تعذر حفظ الموعد');
  }

  /// المريض: قبول أو رفض الموعد المقترح.
  Future<AppointmentInfo?> respond({
    required String requestId,
    required bool accept,
  }) async {
    final result = await _crud.putData(
      '${ApiLink.requests}/processing/$requestId/appointment/respond',
      {'accept': accept},
    );
    return _parse(result, failText: 'تعذر إرسال الرد');
  }

  AppointmentInfo? _parse(ApiResult result, {required String failText}) {
    AppointmentInfo? out;
    switch (result) {
      case ApiSuccess(data: final body):
        showsnack(title: 'تم', message: body['message']?.toString() ?? 'تم');
        final data = body['data'];
        if (data is Map) out = AppointmentInfo.tryParse(data['appointment']);
      case ApiFailure(:final message):
        showsnack(title: 'خطأ', message: message ?? failText);
    }
    return out;
  }
}
