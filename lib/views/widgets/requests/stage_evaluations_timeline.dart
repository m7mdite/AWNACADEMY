import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mytoothadmin/utils/app_constants/app_constants.dart';
import 'package:mytoothadmin/utils/app_constants/app_theme_constants.dart';

import '../../../models/requests_models/treatment_request_model.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../../utils/date_format_ar.dart';

/// عرض التقييمات المرحلية كخط زمني (الأحدث أولاً).
/// يظهر تلقائياً للطلبات قيد المعالجة/المكتملة التي فيها تقييم واحد على الأقل.
class StageEvaluationsTimeline extends StatefulWidget {
  final TreatmentRequestModel requestModel;

  /// true: يعرض كل التقييمات بدون زر "عرض الكل" (يُستخدم داخل النافذة).
  final bool showAll;

  const StageEvaluationsTimeline({
    super.key,
    required this.requestModel,
    this.showAll = false,
  });

  @override
  State<StageEvaluationsTimeline> createState() => _StageEvaluationsTimelineState();
}

class _StageEvaluationsTimelineState extends State<StageEvaluationsTimeline> {
  static const int _collapsedCount = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.requestModel;
    if (r.status != 'processing' && r.status != 'finished') {
      return const SizedBox.shrink();
    }

    final all = r.stageEvaluations ?? <StageEvaluation>[];
    if (all.isEmpty) return const SizedBox.shrink();

    // الأحدث أولاً، والترقيم حسب الترتيب الزمني
    final newestFirst = all.reversed.toList();
    final total = newestFirst.length;
    final expanded = widget.showAll || _expanded;
    final shown = expanded ? newestFirst : newestFirst.take(_collapsedCount).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppThemeConstants.borderRadius,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'التقييمات المرحلية',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppThemeConstants.borderRadius,
                ),
                child: Text(
                  '$total',
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < shown.length; i++)
            _item(
              number: total - i,
              eval: shown[i],
              isLatest: i == 0,
              isLast: i == shown.length - 1,
            ),
          if (!widget.showAll && total > _collapsedCount)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'عرض أقل' : 'عرض الكل ($total)'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _item({
    required int number,
    required StageEvaluation eval,
    required bool isLatest,
    required bool isLast,
  }) {
    final when = parseServerDate(eval.date);
    final railColor = isLatest ? AppColors.primary : AppColors.borderColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLatest ? AppColors.primary : AppColors.cardColor,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isLatest ? AppColors.white : AppColors.primary,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: railColor)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLatest
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : AppColors.cardColor,
                  borderRadius: AppThemeConstants.borderRadius,
                  border: Border.all(
                    color: isLatest
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'التقييم $number',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (isLatest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppThemeConstants.borderRadius,
                            ),
                            child: const Text(
                              'الأحدث',
                              style: TextStyle(fontSize: 9, color: AppColors.white),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (when != null)
                          Flexible(
                            child: Text(
                              formatDateTimeAr(when),
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      eval.text ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// يفتح كل التقييمات داخل نافذة (مفيد بنافذة إدارة المشرف).
void showStageEvaluationsDialog(TreatmentRequestModel requestModel) {
  Get.dialog(
    Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(6),
          child: StageEvaluationsTimeline(requestModel: requestModel, showAll: true),
        ),
      ),
    ),
  );
}
