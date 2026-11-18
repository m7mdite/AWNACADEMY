import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_constants/status_request.dart';
import '../local_storge/local_user_storage.dart';
import 'api_result.dart';

export 'api_result.dart';

class Crud {
  final LocalUserStorage localStorage = Get.find<LocalUserStorage>();

  /// يُستدعى عند وصول 401 (جلسة منتهية أو مبطلة). يُضبط في main.dart.
  static Future<void> Function()? onSessionExpired;

  static const Duration _timeout = Duration(seconds: 20);
  static const Duration _uploadTimeout = Duration(seconds: 60);

  // ============================================================
  // أدوات داخلية
  // ============================================================

  /// يضيف التوكن دائمًا، ويدمج أي headers إضافية بدل استبدالها.
  Future<Map<String, String>> _headers({
    Map<String, String>? extra,
    bool json = true,
  }) async {
    final token = await localStorage.getToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  /// يحوّل http.Response إلى ApiResult.
  ApiResult _handle(http.Response response) {
    final code = response.statusCode;
    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(response.body);
      body = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : {'data': decoded};
    } catch (_) {
      // الرد ليس JSON (مثل صفحة 502)
      return ApiFailure(
        StatusRequest.serverFailure,
        message: 'رد غير صالح من الخادم',
        statusCode: code,
      );
    }

    if (code >= 200 && code < 300) {
      return ApiSuccess(body, statusCode: code);
    }
    return ApiFailure(
      StatusRequest.serverFailure,
      message: body['message']?.toString(),
      statusCode: code,
    );
  }

  /// المنفذ الوحيد لكل الطلبات: timeout + تمييز أنواع الفشل.
  Future<ApiResult> _send(
    Future<http.Response> Function() request, {
    Duration timeout = _timeout,
    bool handleUnauthorized = true,
  }) async {
    try {
      final response = await request().timeout(timeout);
      final result = _handle(response);
      if (handleUnauthorized &&
          result is ApiFailure &&
          result.statusCode == 401) {
        onSessionExpired?.call();
      }
      return result;
    } on SocketException {
      return const ApiFailure(
        StatusRequest.offlineFailure,
        message: 'لا يوجد اتصال بالإنترنت',
      );
    } on TimeoutException {
      return const ApiFailure(
        StatusRequest.serverFailure,
        message: 'انتهت مهلة الاتصال',
      );
    } on http.ClientException {
      return const ApiFailure(
        StatusRequest.offlineFailure,
        message: 'تعذر الاتصال بالخادم',
      );
    } catch (_) {
      return const ApiFailure(StatusRequest.serverFailure);
    }
  }

  Future<ApiResult> _sendMultipart(
    String method,
    String url,
    Map<String, String> data,
    List<String> filePaths,
    String fileField,
  ) async {
    for (final path in filePaths) {
      if (!await File(path).exists()) {
        return const ApiFailure(
          StatusRequest.serverFailure,
          message: 'الملف غير موجود',
        );
      }
    }
    final headers = await _headers(json: false);

    return _send(() async {
      final request = http.MultipartRequest(method, Uri.parse(url));
      request.fields.addAll(data);
      request.headers.addAll(headers);
      for (final path in filePaths) {
        request.files.add(await http.MultipartFile.fromPath(fileField, path));
      }
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    }, timeout: _uploadTimeout);
  }

  // ============================================================
  // GET
  // ============================================================
  Future<ApiResult> getData(String url, {Map<String, String>? header}) async {
    final headers = await _headers(extra: header);
    return _send(() => http.get(Uri.parse(url), headers: headers));
  }

  // ============================================================
  // POST
  // ============================================================
  Future<ApiResult> postData(
    String url,
    Map data, {
    Map<String, String>? header,
    Duration? timeout, // اختياري: مثلًا لطلبات الذكاء الاصطناعي البطيئة
    bool handleUnauthorized = true, // false لمسار الدخول والخروج
  }) async {
    final headers = await _headers(extra: header);
    return _send(
      () => http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      ),
      timeout: timeout ?? _timeout,
      handleUnauthorized: handleUnauthorized,
    );
  }

  Future<ApiResult> postManyData(
    String url,
    List<Map<String, dynamic>> data, {
    Map<String, String>? header,
  }) async {
    final headers = await _headers(extra: header);
    return _send(() => http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        ));
  }

  // ============================================================
  // PUT  (id اختياري: يُلحق بالرابط إن وُجد)
  // ============================================================
  Future<ApiResult> putData(
    String url,
    Map data, {
    String? id,
    Map<String, String>? header,
  }) async {
    final headers = await _headers(extra: header);
    final uri = Uri.parse(id == null || id.isEmpty ? url : '$url/$id');
    return _send(() => http.put(
          uri,
          headers: headers,
          body: jsonEncode(data),
        ));
  }

  // ============================================================
  // DELETE
  // ============================================================
  /// id اختياري: بدونه يُحذف المسار نفسه (مثل DELETE /ai/history).
  Future<ApiResult> deleteData(
    String url,
    String? id, {
    Map<String, String>? header,
  }) async {
    final headers = await _headers(extra: header);
    final uri = Uri.parse(id == null || id.isEmpty ? url : '$url/$id');
    return _send(() => http.delete(uri, headers: headers));
  }

  // ============================================================
  // Multipart
  // ============================================================
  Future<ApiResult> postDataWithFiles(
    String url,
    Map<String, String> data,
    List<String> filePaths,
    String fileField,
  ) =>
      _sendMultipart('POST', url, data, filePaths, fileField);

  Future<ApiResult> putDataWithFiles(
    String url,
    Map<String, String> data,
    List<String> filePaths,
    String fileField,
  ) =>
      _sendMultipart('PUT', url, data, filePaths, fileField);
}
