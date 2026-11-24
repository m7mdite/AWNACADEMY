import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controllers/admin_actions_controller.dart';
import '../../../models/admin_models/moderation_model.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../../utils/date_format_ar.dart';
import '../../widgets/custom_app_bar.dart';

/// سجل إجراءات الأدمن (تحذير / إيقاف / حظر / رفع).
class AdminActionsScreen extends StatelessWidget {
  const AdminActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminActionsController());

    return Scaffold(
      appBar: CustomAppBar(title: 'سجل الإجراءات'),
      body: GetBuilder<AdminActionsController>(
        builder: (_) {
          if (!c.loaded) return const Center(child: CircularProgressIndicator());
          if (c.items.isEmpty) {
            return Center(child: Text(c.failed ? 'تعذر تحميل السجل' : 'لا توجد إجراءات بعد'));
          }
          return RefreshIndicator(
            onRefresh: c.refreshAll,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) c.loadMore();
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: c.items.length + (c.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  if (i >= c.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return _tile(c.items[i]);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tile(AdminActionLogItem a) {
    final color = a.action == 'ban'
        ? AppColors.error
        : a.action == 'suspend'
            ? AppColors.warning
            : a.action == 'reactivate'
                ? AppColors.success
                : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color),
                ),
                child: Text(
                  moderationActionLabel(a.action) + (a.days != null ? ' (${a.days} يوم)' : ''),
                  style: TextStyle(fontSize: 11, color: color),
                ),
              ),
              const Spacer(),
              if (a.createdAt != null)
                Text(
                  formatDateTimeAr(a.createdAt!),
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ضد: ${a.targetName.isEmpty ? 'مستخدم محذوف' : a.targetName}',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          Text(
            'بواسطة: ${a.adminName.isEmpty ? '—' : a.adminName}',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (a.reason != null && a.reason!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('السبب: ${a.reason}', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
            ),
          if (a.affectedCases > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'حالات متأثرة: ${a.affectedCases}',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
