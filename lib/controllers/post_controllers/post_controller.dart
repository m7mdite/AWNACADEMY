import 'package:get/get.dart';
import '../../models/posts_models/post_model.dart';
import '../../models/posts_models/comment_model.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/post_remote.dart';
import '../../utils/app_constants/status_request.dart';

class PostController extends GetxController {
  final PostRemote remote = PostRemote(Get.find());
  RxList<PostModel> posts = <PostModel>[].obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxBool hasMore = true.obs;
  RxBool isLoadingMore = false.obs;

  Rx<String?> currentFilter = Rx<String?>(null);

  RxBool isLoading = false.obs;
  RxBool isCreating = false.obs;
  Rx<StatusRequest> statusRequest = StatusRequest.none.obs;

  // ===== المنشورات الشخصية (منشوراتي) =====
  RxList<PostModel> myPosts = <PostModel>[].obs;
  RxBool isLoadingMy = false.obs;

  // ===== المنشورات المعلّقة =====
  RxList<PostModel> pendingPosts = <PostModel>[].obs;
  RxBool isLoadingPending = false.obs;

  // ===== تفاصيل منشور وتعليقاته =====
  Rx<PostModel?> selectedPost = Rx<PostModel?>(null);
  RxList<CommentModel> postComments = <CommentModel>[].obs;
  RxBool isLoadingDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts(refresh: true);
  }

  void _error(String? message, String fallback) =>
      Get.snackbar('خطأ', message ?? fallback);

  // ============================================================
  // الفيد العام
  // ============================================================
  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      posts.clear();
      hasMore.value = true;
      isLoadingMore.value = false;
    }
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    statusRequest.value = StatusRequest.loading;
    update();

    try {
      final result = await remote.getAllPosts(
        page: currentPage.value,
        limit: 10,
        filter: currentFilter.value,
      );
      switch (result) {
        case ApiSuccess(data: final body):
          final List<dynamic> data = body['data'] ?? [];
          final newPosts =
              data.map((json) => PostModel.fromJson(json)).toList();

          if (refresh) {
            posts.value = newPosts;
          } else {
            posts.addAll(newPosts);
          }
          totalPages.value = body['pagination']?['total_pages'] ?? 1;
          hasMore.value = currentPage.value < totalPages.value;
          if (hasMore.value) currentPage.value++;
          posts.refresh();
          statusRequest.value = StatusRequest.success;
        case ApiFailure(:final status, :final message):
          statusRequest.value = status;
          _error(message, 'فشل تحميل البوستات');
      }
    } catch (_) {
      statusRequest.value = StatusRequest.serverFailure;
      _error(null, 'فشل تحميل البوستات');
    } finally {
      isLoadingMore.value = false;
      update();
    }
  }

  Future<void> loadMorePosts() async {
    if (hasMore.value && !isLoadingMore.value) {
      await fetchPosts(refresh: false);
    }
  }

  /// جلب المنشورات الشخصية (بدون pagination، GET /posts/my).
  Future<void> fetchMyPosts() async {
    isLoadingMy.value = true;
    try {
      final result = await remote.getMyPosts();
      switch (result) {
        case ApiSuccess(data: final body):
          final List<dynamic> data = body['data'] ?? [];
          myPosts.value = data.map((json) => PostModel.fromJson(json)).toList();
        case ApiFailure(:final message):
          _error(message, 'فشل تحميل منشوراتك');
      }
    } catch (_) {
      _error(null, 'فشل تحميل منشوراتك');
    } finally {
      isLoadingMy.value = false;
    }
  }

  Future<void> fetchPendingPosts() async {
    isLoadingPending.value = true;
    try {
      final result = await remote.getPendingPosts();
      switch (result) {
        case ApiSuccess(data: final body):
          final List<dynamic> data = body['data'] ?? [];
          pendingPosts.value =
              data.map((json) => PostModel.fromJson(json)).toList();
        case ApiFailure(:final message):
          _error(message, 'فشل جلب البوستات المعلقة');
      }
    } catch (_) {
      _error(null, 'فشل جلب البوستات المعلقة');
    } finally {
      isLoadingPending.value = false;
    }
  }

  /// filter == 'me' → منشوراتي الشخصية. غير ذلك → فلترة الفيد العام.
  void setFilter(String? filter) {
    currentFilter.value = filter;
    if (filter == 'me') {
      fetchMyPosts();
    } else {
      fetchPosts(refresh: true);
    }
  }

  // ============================================================
  // إنشاء / تعديل / حذف
  // ============================================================
  Future<void> createPost(String content, List<String> imagePaths) async {
    isCreating.value = true;
    try {
      final result = await remote.createPost(content, imagePaths);
      switch (result) {
        case ApiSuccess():
          Get.back();
          await fetchPosts(refresh: true);
          fetchPendingPosts();
          Get.snackbar('نجاح', 'تم نشر البوست بنجاح');
        case ApiFailure(:final message):
          _error(message, 'فشل النشر');
      }
    } catch (_) {
      _error(null, 'فشل النشر');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> updatePost({
    required String postId,
    required String newContent,
    List<String>? newImagePaths,
    List<String>? deleteImageIds,
  }) async {
    isLoading.value = true;
    try {
      final result = await remote.updatePost(
        postId: postId,
        content: newContent,
        newImagePaths: newImagePaths,
        deleteImageIds: deleteImageIds,
      );
      switch (result) {
        case ApiSuccess(data: final body):
          final updatedPost = PostModel.fromJson(body['data']);

          final feedIndex = posts.indexWhere((p) => p.sId == postId);
          if (feedIndex != -1) {
            posts[feedIndex] = updatedPost;
            posts.refresh();
          }
          final myIndex = myPosts.indexWhere((p) => p.sId == postId);
          if (myIndex != -1) {
            myPosts[myIndex] = updatedPost;
            myPosts.refresh();
          }

          Get.back(); // إغلاق شاشة التعديل
          Get.snackbar('نجاح', 'تم تحديث المنشور');
        case ApiFailure(:final message):
          _error(message, 'فشل التعديل');
      }
    } catch (_) {
      _error(null, 'فشل التعديل');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePost(String postId) async {
    isLoading.value = true;
    try {
      final result = await remote.deletePost(postId);
      switch (result) {
        case ApiSuccess():
          posts.removeWhere((p) => p.sId == postId);
          posts.refresh();
          myPosts.removeWhere((p) => p.sId == postId);
          myPosts.refresh();
          Get.snackbar('نجاح', 'تم حذف المنشور');
        case ApiFailure(:final message):
          _error(message, 'فشل الحذف');
      }
    } catch (_) {
      _error(null, 'فشل الحذف');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // لايك / ديسلايك
  // ============================================================
  Future<void> likePost(String postId) => _react(remote.likePost(postId), postId);

  Future<void> dislikePost(String postId) =>
      _react(remote.dislikePost(postId), postId);

  Future<void> _react(Future<ApiResult> request, String postId) async {
    try {
      final result = await request;
      switch (result) {
        case ApiSuccess(data: final body):
          _updateLikeCountsEverywhere(
            postId,
            body['data']['count_likes'],
            body['data']['count_dislikes'],
          );
        case ApiFailure(:final message):
          _error(message, 'فشل التفاعل');
      }
    } catch (_) {
      _error(null, 'فشل التفاعل');
    }
  }

  /// تحديث العدّادات في كل القوائم التي قد يظهر فيها البوست
  /// (الفيد العام + منشوراتي) لتجنب التضارب.
  void _updateLikeCountsEverywhere(String postId, int? likes, int? dislikes) {
    final feedIndex = posts.indexWhere((p) => p.sId == postId);
    if (feedIndex != -1) {
      posts[feedIndex].countLikes = likes;
      posts[feedIndex].countDislikes = dislikes;
      posts.refresh();
    }

    final myIndex = myPosts.indexWhere((p) => p.sId == postId);
    if (myIndex != -1) {
      myPosts[myIndex].countLikes = likes;
      myPosts[myIndex].countDislikes = dislikes;
      myPosts.refresh();
    }
  }

  // ============================================================
  // التفاصيل والتعليقات
  // ============================================================
  Future<void> fetchPostDetails(String postId) async {
    isLoadingDetails.value = true;
    try {
      final result = await remote.getPostDetails(postId);
      switch (result) {
        case ApiSuccess(data: final body):
          final data = body['data'];
          selectedPost.value = PostModel.fromJson(data['post']);
          final List<dynamic> commentsJson = data['comments'] ?? [];
          postComments.value =
              commentsJson.map((c) => CommentModel.fromJson(c)).toList();
        case ApiFailure(:final message):
          _error(message, 'فشل تحميل تفاصيل البوست');
      }
    } catch (_) {
      _error(null, 'فشل تحميل تفاصيل البوست');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> addComment(String postId, String content) async {
    if (content.trim().isEmpty) return;
    isLoadingDetails.value = true;
    try {
      final result = await remote.addComment(postId, content);
      switch (result) {
        case ApiSuccess():
          await fetchPostDetails(postId);
          Get.snackbar('نجاح', 'تم إضافة التعليق');
        case ApiFailure(:final message):
          _error(message, 'فشل إضافة التعليق');
      }
    } catch (_) {
      _error(null, 'فشل إضافة التعليق');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      final result = await remote.likeComment(commentId);
      switch (result) {
        case ApiSuccess(data: final body):
          final index = postComments.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            final old = postComments[index];
            postComments[index] = CommentModel(
              id: old.id,
              content: old.content,
              likesCount: body['data']?['likesCount'] ?? old.likesCount,
              createdAt: old.createdAt,
              user: old.user,
            );
            postComments.refresh();
          }
        case ApiFailure(:final message):
          _error(message, 'فشل التفاعل');
      }
    } catch (_) {
      _error(null, 'فشل التفاعل');
    }
  }

  // ===== الموافقة على منشور معلّق (للأدمن) =====
  Future<void> acceptPendingPost(String postId) async {
    isLoadingPending.value = true;
    try {
      final result = await remote.acceptPendingPost(postId);
      switch (result) {
        case ApiSuccess():
          pendingPosts.removeWhere((p) => p.sId == postId);
          pendingPosts.refresh();
          await fetchPosts(refresh: true);
          Get.snackbar('نجاح', 'تم الموافقة على المنشور ونشره للعامة');
        case ApiFailure(:final message):
          _error(message, 'فشل الموافقة على البوست');
      }
    } catch (_) {
      _error(null, 'فشل الموافقة على البوست');
    } finally {
      isLoadingPending.value = false;
    }
  }
}
