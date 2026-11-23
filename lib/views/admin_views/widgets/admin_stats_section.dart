// lib/views/admin_views/widgets/admin_stats_section.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_route.dart';
import '../../../controllers/admin_controllers/admin_request_controller.dart';
import '../../../controllers/admin_controllers/admin_stats_controller.dart';
import '../../../controllers/post_controllers/post_controller.dart';
import '../../../models/admin_models/stats_model.dart';
import '../../../utils/app_constants/app_theme_constants.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../users/admin_reports_screen.dart';
import 'admin_menu_widgets.dart';

/// قسم الإحصاءات الذي يُعرض داخل الصفحة الرئيسية للأدمن
/// (كان سابقًا شاشة مستقلة AdminStatsScreen).
class AdminStatsSection extends StatelessWidget {
  AdminStatsSection({super.key});

  final AdminStatsController controller = Get.put(AdminStatsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.stats.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: AdminSectionHeader(
                    icon: Icons.bar_chart,
                    title: 'الإحصاءات',
                  ),
                ),
                IconButton(
                  onPressed: () => controller.fetchStats(),
                  icon: Icon(Icons.refresh, color: AppColors.primaryAccent),
                ),
              ],
            ),
          ),
          if (s == null)
            _stateCard()
          else ...[
            _periodSelector(),
            _attentionSection(s.attention),
            _overviewSection(s),
            _statusSection(s.requests),
            _weeklySection(s.weekly),
            _topTreatmentsSection(s.topTreatments),
            _topStudentsSection(s.topStudents),
            _overseersSection(s.overseerLoad),
            if (s.generatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'آخر تحديث: ${s.generatedAt!.day}/${s.generatedAt!.month} '
                    '${s.generatedAt!.hour.toString().padLeft(2, '0')}:'
                    '${s.generatedAt!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        ],
      );
    });
  }

  // ===== حالة التحميل / الخطأ =====
  Widget _stateCard() {
    final loading = controller.isLoading.value;
    final error = controller.error.value;
    return _card(
      title: 'الإحصاءات',
      icon: Icons.bar_chart,
      child: Center(
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Text(
                    error.isEmpty ? 'لا توجد بيانات' : error,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => controller.fetchStats(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
      ),
    );
  }

  // ===== اختيار الفترة =====
  Widget _periodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [4,  8]
            .map((w) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$w أسابيع'),
                    selected: controller.weeks.value == w,
                    onSelected: (_) => controller.setWeeks(w),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ===== التنقل (يضمن تسجيل الكونترولرات قبل فتح الصفحات) =====
  void _openPendingRequests() {
    Get.put(AdminRequestControllerImpl()).toViewPendingRequestsPage();
  }

  void _openPendingPosts() {
    Get.put(PostController());
    Get.toNamed(AppRroute.pendingPosts);
  }

  // ===== يحتاج إجراء =====
  Widget _attentionSection(StatsAttention a) {
    final items = <_AttentionItem>[
      _AttentionItem('طلبات بانتظار القبول', a.pendingRequests,
          Icons.hourglass_top, _openPendingRequests),
      _AttentionItem('طلبات توثيق الطلاب', a.pendingVerifications,
          Icons.verified_user, () => Get.toNamed(AppRroute.verifyStudents)),
      _AttentionItem('بلاغات غير مراجعة', a.pendingReports, Icons.flag,
          () => Get.to(() => AdminReportsScreen())),
      _AttentionItem('منشورات معلّقة', a.pendingPosts, Icons.pending_actions,
          _openPendingPosts),
    ];
    return _card(
      title: 'يحتاج إجراءً منك',
      icon: Icons.notification_important,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.1,
        children: items.map(_attentionTile).toList(),
      ),
    );
  }

  Widget _attentionTile(_AttentionItem it) {
    final Color color = it.count > 0 ? AppColors.warning : AppColors.success;
    return InkWell(
      onTap: it.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          children: [
            Icon(it.icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                it.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
              ),
            ),
            Text(
              '${it.count}',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ===== نظرة عامة =====
  Widget _overviewSection(AdminStats s) {
    final u = s.users;
    final r = s.requests;
    return _card(
      title: 'نظرة عامة',
      icon: Icons.dashboard,
      child: Column(
        children: [
          Row(
            children: [
              _kpi('مرضى', '${u.patients}', Icons.personal_injury),
              _kpi('طلاب موثّقون', '${u.verifiedStudents}/${u.students}',
                  Icons.school),
              _kpi('مشرفون', '${u.overseers}', Icons.health_and_safety),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kpi('نسبة الإنجاز', '${r.completionRate}%', Icons.task_alt),
              _kpi('متوسط مدة المعالجة',
                  s.avgDays == null ? '—' : '${s.avgDays} يوم', Icons.timer),
              _kpi('متوسط التقييم',
                  s.avgRating == null ? '—' : '${s.avgRating}/5', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryAccent, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ===== توزيع الحالات (مخطط دائري) =====
  Widget _statusSection(StatsRequests r) {
    final parts = <_Part>[
      _Part('انتظار', r.pending, AppColors.warning),
      _Part('معالجة', r.processing, AppColors.primaryAccent),
      _Part('مكتملة', r.finished, AppColors.success),
      _Part('مرفوضة', r.rejected, AppColors.error),
    ];
    return _card(
      title: 'توزيع الطلبات حسب الحالة (${r.total})',
      icon: Icons.pie_chart,
      child: r.total == 0
          ? _empty('لا توجد طلبات بعد')
          : Column(
              children: [
                SizedBox(
                  height: 190,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: [
                        for (final p in parts)
                          if (p.value > 0)
                            PieChartSectionData(
                              value: p.value.toDouble(),
                              color: p.color,
                              radius: 54,
                              title: '${p.value}',
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children:
                      parts.map((p) => _legend(p.label, p.color)).toList(),
                ),
              ],
            ),
    );
  }

  // ===== الطلبات الأسبوعية =====
  Widget _weeklySection(List<WeekPoint> w) {
    if (w.isEmpty) {
      return _card(
          title: 'الطلبات الأسبوعية',
          icon: Icons.bar_chart,
          child: _empty('لا توجد بيانات'));
    }
    int maxV = 0;
    for (final p in w) {
      if (p.newRequests > maxV) maxV = p.newRequests;
      if (p.completed > maxV) maxV = p.completed;
    }
    final double maxY = (maxV < 4 ? 4 : maxV + 1).toDouble();
    final double rodWidth = w.length > 10 ? 5 : 8;

    return _card(
      title: 'الطلبات خلال آخر ${w.length} أسبوعًا',
      icon: Icons.bar_chart,
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (v, meta) => v % 1 == 0
                          ? Text('${v.toInt()}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary))
                          : const SizedBox.shrink(),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= w.length || w[i].weekStart == null) {
                          return const SizedBox.shrink();
                        }
                        final d = w[i].weekStart!;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${d.day}/${d.month}',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < w.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: w[i].newRequests.toDouble(),
                          color: AppColors.primaryAccent,
                          width: rodWidth,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: w[i].completed.toDouble(),
                          color: AppColors.success,
                          width: rodWidth,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend('جديدة', AppColors.primaryAccent),
              const SizedBox(width: 16),
              _legend('مكتملة', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  // ===== أكثر أنواع المعالجة طلبًا =====
  Widget _topTreatmentsSection(List<NamedCount> t) {
    final int maxC = t.isEmpty ? 1 : t.first.count;
    return _card(
      title: 'أكثر أنواع المعالجة طلبًا',
      icon: Icons.medical_services,
      child: t.isEmpty
          ? _empty('لا توجد بيانات')
          : Column(
              children: t
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary),
                                  ),
                                ),
                                Text(
                                  '${e.count}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryAccent),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: maxC == 0 ? 0 : e.count / maxC,
                                minHeight: 8,
                                backgroundColor: AppColors.grey200,
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }

  // ===== أفضل الطلاب =====
  Widget _topStudentsSection(List<StudentStat> list) {
    return _card(
      title: 'الطلاب الأكثر إنجازًا',
      icon: Icons.emoji_events,
      child: list.isEmpty
          ? _empty('لا توجد حالات مكتملة بعد')
          : Column(
              children: [
                for (var i = 0; i < list.length; i++)
                  _rankRow(
                    i + 1,
                    list[i].name,
                    '${list[i].finished} حالة',
                    sub: list[i].avgRating == null
                        ? null
                        : 'متوسط التقييم ${list[i].avgRating}',
                  ),
              ],
            ),
    );
  }

  // ===== حمل المشرفين =====
  Widget _overseersSection(List<OverseerStat> list) {
    return _card(
      title: 'حمل المشرفين',
      icon: Icons.supervisor_account,
      child: list.isEmpty
          ? _empty('لا توجد بيانات')
          : Column(
              children: [
                for (var i = 0; i < list.length; i++)
                  _rankRow(
                    i + 1,
                    list[i].name,
                    'قيد المعالجة: ${list[i].processing}',
                    sub: 'منتهية: ${list[i].finished}',
                  ),
              ],
            ),
    );
  }

  Widget _rankRow(int rank, String name, String trailing, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.primary500,
            child: Text('$rank',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary),
                ),
                if (sub != null)
                  Text(sub,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(trailing,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primaryAccent)),
        ],
      ),
    );
  }

  // ===== عناصر مساعدة =====
  Widget _card({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor.withValues(alpha: 0.95),
        borderRadius: AppThemeConstants.borderRadius,
        border: Border.all(color: AppColors.primaryAccent, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: AppColors.primaryAccent, size: 18),
              if (icon != null) const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _empty(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(text, style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}

class _AttentionItem {
  final String label;
  final int count;
  final IconData icon;
  final VoidCallback onTap;
  _AttentionItem(this.label, this.count, this.icon, this.onTap);
}

class _Part {
  final String label;
  final int value;
  final Color color;
  _Part(this.label, this.value, this.color);
}
