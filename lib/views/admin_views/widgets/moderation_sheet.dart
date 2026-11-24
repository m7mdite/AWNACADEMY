import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controllers/moderation_controller.dart';
import '../../../models/admin_models/moderation_model.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../../utils/date_format_ar.dart';

String _roleLabel(String role) {
  switch (role) {
    case 'student':
      return 'طالب';
    case 'overseer':
      return 'مشرف';
    case 'patient':
      return 'مريض';
    default:
      return role;
  }
}

/// يفتح لوحة الإجراءات على مستخدم: تحذير / إيقاف مؤقت / حظر / رفع.
/// إذا مرّرت [reportId] فالبلاغ يُغلق تلقائياً مع تسجيل الإجراء.
Future<void> showModerationSheet({
  required String userId,
  String? displayName,
  String? reportId,
  VoidCallback? onDone,
}) async {
  Get.put(ModerationController(), tag: userId).load(userId);

  await Get.bottomSheet(
    _ModerationSheet(
      userId: userId,
      displayName: displayName,
      reportId: reportId,
      onDone: onDone,
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  );

  Get.delete<ModerationController>(tag: userId);
}

class _ModerationSheet extends StatefulWidget {
  final String userId;
  final String? displayName;
  final String? reportId;
  final VoidCallback? onDone;

  const _ModerationSheet({
    required this.userId,
    this.displayName,
    this.reportId,
    this.onDone,
  });

  @override
  State<_ModerationSheet> createState() => _ModerationSheetState();
}

class _ModerationSheetState extends State<_ModerationSheet> {
  final TextEditingController _reason = TextEditingController();
  String? _action;
  int _days = 3;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  List<String> _allowed(ModerationInfo info) {
    if (info.isAdmin) return const [];
    switch (info.accountStatus) {
      case 'banned':
        return const ['reactivate'];
      case 'suspended':
        return const ['ban', 'reactivate'];
      default:
        return const ['warn', 'suspend', 'ban'];
    }
  }

  Future<void> _submit(ModerationController c, ModerationInfo info) async {
    final action = _action;
    if (action == null) return;

    final reason = _reason.text.trim();
    if (action != 'reactivate' && reason.length < 3) {
      Get.snackbar('تنبيه', 'اكتب سبب الإجراء (3 أحرف على الأقل)');
      return;
    }

    if (action == 'ban' || action == 'suspend') {
      final ok = await Get.dialog<bool>(
        AlertDialog(
          title: Text(action == 'ban' ? 'تأكيد الحظر' : 'تأكيد الإيقاف'),
          content: Text(
            action == 'ban'
                ? 'سيتم حظر ${info.name} ولن يستطيع تسجيل الدخول حتى ترفع الحظر.'
                : 'سيتم إيقاف ${info.name} لمدة $_days يوم/أيام.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('إلغاء')),
            TextButton(onPressed: () => Get.back(result: true), child: const Text('تأكيد')),
          ],
        ),
      );
      if (ok != true) return;
    }

    final res = await c.apply(
      userId: widget.userId,
      action: action,
      reason: reason,
      days: action == 'suspend' ? _days : null,
      reportId: widget.reportId,
    );
    if (res == null) return;

    widget.onDone?.call();
    Get.back(); // إغلاق اللوحة

    if (res.affectedCases > 0 && (action == 'ban' || action == 'suspend')) {
      final extra = res.role == 'overseer' && res.unassignedCases > 0
          ? 'تم فك ارتباط المشرف بـ ${res.unassignedCases} حالة، وسيختار الطلاب مشرفاً بديلاً.'
          : res.role == 'student'
              ? 'هذه الحالات تحتاج إعادة إسناد يدوي من شاشة الطلبات.'
              : 'تم إشعار الأطراف المعنية.';
      Get.dialog(
        AlertDialog(
          title: const Text('حالات متأثرة'),
          content: Text('لهذا المستخدم ${res.affectedCases} حالة قيد المعالجة.\n$extra'),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('حسناً'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return GetBuilder<ModerationController>(
      tag: widget.userId,
      builder: (c) {
        final info = c.info;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: Get.height * 0.85),
            child: c.loading && info == null
                ? const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
                : info == null
                    ? SizedBox(
                        height: 120,
                        child: Center(child: Text(c.error ?? 'تعذر تحميل البيانات')),
                      )
                    : SingleChildScrollView(child: _content(c, info)),
          ),
        );
      },
    );
  }

  Widget _content(ModerationController c, ModerationInfo info) {
    final allowed = _allowed(info);
    final name = info.name.isNotEmpty ? info.name : (widget.displayName ?? 'مستخدم');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _statusChip(info),
          ],
        ),
        const SizedBox(height: 2),
        Text(_roleLabel(info.role), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        if (info.isBlocked) ...[
          const SizedBox(height: 6),
          Text(
            [
              if (info.accountStatus == 'suspended' && info.suspendedUntil != null)
                'حتى ${formatDateTimeAr(info.suspendedUntil!)}',
              if (info.banReason != null && info.banReason!.isNotEmpty) 'السبب: ${info.banReason}',
            ].join(' — '),
            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            _stat('تحذيرات', info.warningsCount),
            _stat('بلاغات مفتوحة', info.openReports),
            _stat('حالات جارية', info.activeCases),
          ],
        ),
        const SizedBox(height: 12),

        if (info.isAdmin)
          Text(
            'لا يمكن اتخاذ إجراء ضد حساب أدمن.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else ...[
          Text('الإجراء', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final a in allowed)
                ChoiceChip(
                  label: Text(moderationActionLabel(a)),
                  selected: _action == a,
                  onSelected: (_) => setState(() => _action = a),
                ),
            ],
          ),
          if (_action == 'suspend') ...[
            const SizedBox(height: 10),
            Text('مدة الإيقاف', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final d in const [1, 3, 7, 14, 30])
                  ChoiceChip(
                    label: Text('$d ${d == 1 ? 'يوم' : 'أيام'}'),
                    selected: _days == d,
                    onSelected: (_) => setState(() => _days = d),
                  ),
              ],
            ),
          ],
          if (_action != null && _action != 'reactivate') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _reason,
              maxLines: 2,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'السبب (يصل للمستخدم)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (_action == 'ban' && info.role == 'overseer' && info.activeCases > 0)
            _note('سيُفك ارتباط المشرف بحالاته الجارية (${info.activeCases}) ليختار الطلاب مشرفاً بديلاً.'),
          if ((_action == 'ban' || _action == 'suspend') && info.role == 'student' && info.activeCases > 0)
            _note('لهذا الطالب ${info.activeCases} حالة قيد المعالجة؛ سيُشعَر المرضى وستحتاج إعادة إسناد يدوي.'),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_action == null || c.saving) ? null : () => _submit(c, info),
              child: c.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تنفيذ'),
            ),
          ),
        ],

        if (info.recentActions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('آخر الإجراءات', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          for (final a in info.recentActions)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${moderationActionLabel(a.action)}'
                '${a.days != null ? ' (${a.days} يوم)' : ''}'
                '${a.reason != null ? ' — ${a.reason}' : ''}'
                '${a.createdAt != null ? '  (${formatDateAr(a.createdAt!)})' : ''}',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
        ],
      ],
    );
  }

  Widget _statusChip(ModerationInfo info) {
    final color = info.accountStatus == 'banned'
        ? AppColors.error
        : info.accountStatus == 'suspended'
            ? AppColors.warning
            : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        accountStatusLabel(info.accountStatus),
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _note(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
    );
  }
}
