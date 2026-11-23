import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/public_controllers/appointment_controller.dart';
import '../../../controllers/public_controllers/unified_setting_controller.dart';
import '../../../models/requests_models/appointment_model.dart';
import '../../../models/requests_models/treatment_request_model.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../../utils/date_format_ar.dart';

/// قسم "الموعد" داخل تفاصيل الطلب (يظهر للجميع على الطلبات قيد المعالجة).
/// - الطالب: يحدد الموعد الأول وموعد المراجعة بعد كل تقييم مرحلي، ويقترح تغيير موعد قائم.
/// - المريض: يقبل أو يرفض الموعد المقترح.
/// - المشرف/الأدمن: عرض فقط.
class AppointmentSection extends StatefulWidget {
  final TreatmentRequestModel requestModel;
  const AppointmentSection({super.key, required this.requestModel});

  @override
  State<AppointmentSection> createState() => _AppointmentSectionState();
}

class _AppointmentSectionState extends State<AppointmentSection> {
  bool _busy = false;

  TreatmentRequestModel get _r => widget.requestModel;
  AppointmentInfo? get _apt => _r.appointment;

  String get _role {
    if (!Get.isRegistered<UnifiedSettingController>()) return '';
    return Get.find<UnifiedSettingController>().role.value;
  }

  bool get _isStudent => _role == 'student';
  bool get _isPatient => _role == 'patient';

  AppointmentController get _ctrl => Get.isRegistered<AppointmentController>()
      ? Get.find<AppointmentController>()
      : Get.put(AppointmentController());

  Future<String?> _askText(String title, String hint) {
    final tc = TextEditingController();
    return Get.dialog<String>(
      AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 15)),
        content: TextField(
          controller: tc,
          maxLines: 2,
          maxLength: 200,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Get.back(result: tc.text.trim()),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  Future<void> _studentAction() async {
    final id = _r.sId;
    if (id == null) return;

    final direct = _apt?.hasDate != true || _apt?.needsNext == true;

    final picked = await _ctrl.pickDateTime();
    if (picked == null) return;

    final text = await _askText(
      direct ? 'ملاحظة للمريض (اختياري)' : 'سبب تغيير الموعد (اختياري)',
      direct ? 'مثال: الرجاء الحضور صائماً' : 'مثال: تعارض مع دوام الجامعة',
    );
    if (text == null) return; // إلغاء

    setState(() => _busy = true);
    final res = await _ctrl.setAppointment(
      requestId: id,
      date: picked,
      note: direct ? text : null,
      reason: direct ? null : text,
    );
    if (res != null) _r.appointment = res;
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _patientRespond(bool accept) async {
    final id = _r.sId;
    if (id == null) return;

    setState(() => _busy = true);
    final res = await _ctrl.respond(requestId: id, accept: accept);
    if (res != null) _r.appointment = res;
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_r.status != 'processing') return const SizedBox.shrink();

    final apt = _apt;
    final pending = apt?.pendingChange;
    final needsNext = apt?.needsNext == true;
    final hasDate = apt?.hasDate == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'الموعد',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          const SizedBox(height: 10),

          // ===== بعد تقييم مرحلي: بانتظار موعد المراجعة =====
          if (needsNext) ...[
            _banner(
              _isStudent
                  ? 'أضاف المشرف تقييماً مرحلياً. حدد موعد المراجعة القادمة للمريض.'
                  : 'تم إجراء تقييم مرحلي، بانتظار تحديد الطالب لموعد المراجعة القادمة.',
            ),
            const SizedBox(height: 8),
          ],

          // ===== الموعد الحالي =====
          if (hasDate)
            _currentAppointment(apt!)
          else
            Text(
              _isStudent
                  ? 'لم تحدد موعداً لهذه الحالة بعد. حدد موعداً ليصل إشعار للمريض والمشرف.'
                  : 'لم يُحدد موعد بعد.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),

          // ===== اقتراح تغيير معلّق =====
          if (pending != null) ...[
            const SizedBox(height: 10),
            _pendingChange(pending),
          ],

          // ===== إجراءات الطالب =====
          if (_isStudent) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _studentAction,
                icon: Icon(
                  (!hasDate || needsNext) ? Icons.add_alarm : Icons.edit_calendar_outlined,
                  size: 18,
                ),
                label: Text(
                  needsNext
                      ? 'تحديد موعد المراجعة القادمة'
                      : !hasDate
                          ? 'تحديد الموعد'
                          : pending != null
                              ? 'تعديل الاقتراح'
                              : 'اقتراح تغيير الموعد',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _currentAppointment(AppointmentInfo apt) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDateTimeAr(apt.date!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  apt.kindLabel,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                if (apt.note != null && apt.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    apt.note!,
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingChange(PendingChange p) {
    final reason = (p.reason != null && p.reason!.isNotEmpty) ? p.reason! : null;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقتراح تغيير الموعد',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warning.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatDateTimeAr(p.date!),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (reason != null) ...[
            const SizedBox(height: 2),
            Text(
              'السبب: $reason',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          if (_isPatient) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy ? null : () => _patientRespond(true),
                    child: const Text('قبول'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _patientRespond(false),
                    child: const Text('رفض'),
                  ),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'بانتظار موافقة المريض',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _banner(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.warning.shade700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
