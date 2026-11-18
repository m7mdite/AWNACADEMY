import '../../utils/app_constants/status_request.dart';

/// نتيجة أي طلب شبكة. إما نجاح أو فشل، والمترجم يجبرك على معالجة الحالتين.
sealed class ApiResult {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess;

  /// البيانات عند النجاح، أو null عند الفشل.
  Map<String, dynamic>? get dataOrNull =>
      switch (this) {
        ApiSuccess(:final data) => data,
        ApiFailure() => null,
      };
}

class ApiSuccess extends ApiResult {
  final Map<String, dynamic> data;
  final int statusCode;
  const ApiSuccess(this.data, {this.statusCode = 200});
}

class ApiFailure extends ApiResult {
  final StatusRequest status;

  /// رسالة جاهزة للعرض (من السيرفر إن وُجدت).
  final String? message;
  final int? statusCode;
  const ApiFailure(this.status, {this.message, this.statusCode});
}
