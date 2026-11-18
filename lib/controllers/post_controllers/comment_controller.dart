import 'package:get/get.dart';

import '../../models/posts_models/comment_model.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/comment_remote.dart';

class CommentController extends GetxController {
  final CommentRemote remote = CommentRemote(Get.find());
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> fetchComments(String postId) async {
    isLoading.value = true;
    try {
      final result = await remote.getCommentsByPost(postId);
      switch (result) {
        case ApiSuccess(data: final body):
          final List<dynamic> data = body['data'] ?? [];
          comments.value =
              data.map((json) => CommentModel.fromJson(json)).toList();
        case ApiFailure(:final message):
          Get.snackbar('خطأ', message ?? 'فشل تحميل التعليقات');
      }
    } catch (_) {
      Get.snackbar('خطأ', 'فشل تحميل التعليقات');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment(String postId, String content) async {
    if (content.trim().isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء كتابة تعليق');
      return;
    }
    isLoading.value = true;
    try {
      final result = await remote.addComment(postId, content);
      switch (result) {
        case ApiSuccess():
          await fetchComments(postId);
          Get.snackbar('نجاح', 'تم إضافة التعليق');
        case ApiFailure(:final message):
          Get.snackbar('خطأ', message ?? 'فشل الإضافة');
      }
    } catch (_) {
      Get.snackbar('خطأ', 'فشل الإضافة');
    } finally {
      isLoading.value = false;
    }
  }
}
