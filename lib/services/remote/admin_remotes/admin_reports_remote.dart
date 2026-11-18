import '../../../api_link.dart';
import '../crud.dart';

class AdminReportsRemote {
  final Crud crud;
  AdminReportsRemote(this.crud);

  Future<ApiResult> getPendingReports() => crud.getData(ApiLink.adminReports);

  /// مراجعة البلاغ (تعليم كمقروء + إضافة ملاحظة اختيارية).
  Future<ApiResult> reviewReport(String reportId, {String? note}) =>
      crud.putData(
        ApiLink.reviewReport(reportId),
        note != null ? {'note': note} : {},
      );

  // ملاحظة: لا يوجد حذف في الباك.
}
