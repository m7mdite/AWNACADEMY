import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/public_controllers/unified_setting_controller.dart';
import '../../../models/requests_models/treatment_request_model.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../../utils/date_format_ar.dart';

/// شريط معلومات تقدّم الحالة داخل الكرت:
/// الموعد القادم، عدد التقييمات، حالة الصورتين، والأطراف (حسب دور المشاهد).
class CaseProgressStrip extends StatelessWidget {
  final TreatmentRequestModel requestModel;
  const CaseProgressStrip({super.key, required this.requestModel});

  String get _role {
    if (!Get.isRegistered<UnifiedSettingController>()) return '';
    return Get.find<UnifiedSettingController>().role.value;
  }

  String _name(Patient? p) {
    if (p == null) return '';
    return [p.firstName, p.lastName].where((e) => e != null && e.isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final r = requestModel;
    final status = r.status;
    if (status != 'processing' && status != 'finished') {
      return const SizedBox.shrink();
    }

    final role = _role;
    final chips = <Widget>[];

    // ----- الموعد (للقيد المعالجة فقط) -----
    if (status == 'processing') {
      final apt = r.appointment;
      if (apt?.needsNext == true) {
        chips.add(_chip(Icons.event_busy, 'بانتظار موعد المراجعة', warn: true));
      } else if (apt?.date != null) {
        chips.add(_chip(Icons.event, formatShortDateTimeAr(apt!.date!)));
      } else {
        chips.add(_chip(Icons.event_busy, 'بدون موعد', warn: true));
      }
      if (apt?.pendingChange != null) {
        chips.add(_chip(Icons.hourglass_top, 'تغيير موعد معلّق', warn: true));
      }
    }

    // ----- التقييمات -----
    final evals = r.stageEvaluations?.length ?? 0;
    if (evals > 0) {
      chips.add(_chip(Icons.fact_check_outlined, 'تقييمات: $evals'));
    }

    // ----- الصور -----
    final hasBefore = r.photos?.hasBefore == true;
    final hasAfter = r.photos?.hasAfter == true;
    chips.add(_chip(
      hasBefore ? Icons.check_circle_outline : Icons.photo_camera_outlined,
      'قبل',
      warn: !hasBefore && status == 'processing',
    ));
    chips.add(_chip(
      hasAfter ? Icons.check_circle_outline : Icons.photo_camera_outlined,
      'بعد',
    ));

    // ----- الأطراف حسب الدور -----
    final people = <MapEntry<String, String>>[];
    void add(String label, Patient? p) {
      final n = _name(p);
      if (n.isNotEmpty) people.add(MapEntry(label, n));
    }

    switch (role) {
      case 'student':
        add('المريض', r.patient);
        add('المشرف', r.overseer);
      case 'patient':
        add('الطالب', r.student);
        add('المشرف', r.overseer);
      case 'overseer':
        add('الطالب', r.student);
        add('المريض', r.patient);
      default:
        add('الطالب', r.student);
        add('المشرف', r.overseer);
        add('المريض', r.patient);
    }
    for (final p in people) {
      chips.add(_chip(Icons.person_outline, '${p.key}: ${p.value}'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: chips,
      ),
    );
  }

  Widget _chip(IconData icon, String text, {bool warn = false}) {
    final color = warn ? AppColors.warning.shade700 : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warn ? AppColors.warning : AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
