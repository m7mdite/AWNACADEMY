import 'package:get/get.dart';
import '../../api_link.dart';
import 'crud.dart';

/// المساعد الذكي عبر الباك إند (الباك هو الذي يتصل بـ Ollama).
class AiRemote {
  final Crud _crud = Get.find<Crud>();

  // أطول قليلًا من مهلة السيرفر لـ Ollama (120 ثانية)
  static const Duration _chatTimeout = Duration(seconds: 130);

  Future<ApiResult> chat(String message) => _crud.postData(
        ApiLink.aiChat,
        {'message': message},
        timeout: _chatTimeout,
      );

  Future<ApiResult> getHistory({int limit = 50}) =>
      _crud.getData('${ApiLink.aiHistory}?limit=$limit');

  Future<ApiResult> clearHistory() => _crud.deleteData(ApiLink.aiHistory, null);
}
