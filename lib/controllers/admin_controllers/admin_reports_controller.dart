// controllers/admin_controller/admin_reports_controller.dart
import 'package:get/get.dart';
import '../../models/admin_models/report_model.dart';
import '../../services/remote/admin_remotes/admin_reports_remote.dart';
import '../../services/remote/crud.dart';
import '../../utils/app_constants/status_request.dart';

class AdminReportsController extends GetxController {
  final AdminReportsRemote remote = AdminReportsRemote(Get.find<Crud>());
  List<ReportModel> reports = [];
  RxBool isLoading = false.obs;
  StatusRequest statusRequest = StatusRequest.none;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  Future<void> fetchReports() async {
    isLoading.value = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await remote.getPendingReports();
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          // الباك يعيد { status: 'success', data: [...] }
          final List<dynamic> data = body['data'] ?? [];
          reports = data.map((json) => ReportModel.fromJson(json)).toList();
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          Get.snackbar('خطأ', message ?? 'فشل تحميل البلاغات');
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      Get.snackbar('خطأ', 'فشل تحميل البلاغات');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // تعليم البلاغ كمقروء (بدون ملاحظة)
  Future<void> markAsRead(String reportId) async {
    final result = await _review(reportId);
    switch (result) {
      case ApiSuccess():
        _markReviewedLocally(reportId);
        Get.snackbar('تم', 'تم تحديث حالة البلاغ');
      case ApiFailure(:final message):
        Get.snackbar('خطأ', message ?? 'فشل تحديث البلاغ');
    }
  }

  // إضافة ملاحظة (ثم تعليم كمقروء)
  Future<void> addNote(String reportId, String note) async {
    if (note.trim().isEmpty) return;
    final result = await _review(reportId, note: note);
    switch (result) {
      case ApiSuccess():
        _markReviewedLocally(reportId, note: note);
        Get.snackbar('تم', 'تم إضافة الملاحظة وتحديث الحالة');
      case ApiFailure(:final message):
        Get.snackbar('خطأ', message ?? 'فشل إضافة الملاحظة');
    }
  }

  Future<ApiResult> _review(String reportId, {String? note}) async {
    try {
      return await remote.reviewReport(reportId, note: note);
    } catch (_) {
      return const ApiFailure(StatusRequest.serverFailure);
    }
  }

  /// تحديث محلي: تغيير الحالة إلى reviewed وإضافة reviewedAt
  void _markReviewedLocally(String reportId, {String? note}) {
    final index = reports.indexWhere((r) => r.sId == reportId);
    if (index == -1) return;
    final old = reports[index];
    reports[index] = ReportModel(
      sId: old.sId,
      reason: old.reason,
      type: old.type,
      status: 'reviewed',
      adminNote: note ?? old.adminNote,
      reviewedAt: DateTime.now(),
      reviewedBy: 'admin',
      createdAt: old.createdAt,
      reporter: old.reporter,
      reported: old.reported,
    );
    update();
  }

  // الحذف غير مدعوم في الباك، يمكن إزالته أو تجاهله
  void deleteReport(String reportId) {
    Get.snackbar('غير متاح', 'حذف البلاغات غير مدعوم حالياً');
  }
}
