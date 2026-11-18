import '../../../api_link.dart';
import '../crud.dart';

class PostRemote {
  final Crud crud;
  PostRemote(this.crud);

  Future<ApiResult> getAllPosts({
    int page = 1,
    int limit = 10,
    String? filter,
    String sort = 'createdAt',
    String order = 'desc',
  }) {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
      'order': order,
      'filter': ?filter,
    };
    final uri = Uri.parse(ApiLink.posts).replace(queryParameters: queryParams);
    return crud.getData(uri.toString());
  }

  /// منشورات المستخدم الحالي فقط (GET /posts/my).
  Future<ApiResult> getMyPosts() => crud.getData('${ApiLink.posts}/my');

  /// المنشورات المعلّقة (بانتظار الموافقة) التي تظهر في زر "المنشورات المعلقة".
  Future<ApiResult> getPendingPosts() => crud.getData(ApiLink.getPendingPosts);

  Future<ApiResult> getPostDetails(String postId) =>
      crud.getData('${ApiLink.posts}/$postId');

  Future<ApiResult> createPost(String content, List<String> imagePaths) =>
      crud.postDataWithFiles(
        ApiLink.posts,
        {'content': content},
        imagePaths,
        'images',
      );

  Future<ApiResult> updatePost({
    required String postId,
    required String content,
    List<String>? newImagePaths,
    List<String>? deleteImageIds,
  }) {
    final data = <String, String>{
      'content': content,
      'deleteImages': (deleteImageIds ?? []).toString(),
    };
    return crud.putDataWithFiles(
      '${ApiLink.posts}/$postId',
      data,
      newImagePaths ?? [],
      'images',
    );
  }

  Future<ApiResult> deletePost(String postId) =>
      crud.deleteData(ApiLink.posts, postId);

  Future<ApiResult> likePost(String postId) =>
      crud.postData('${ApiLink.posts}/$postId/like', {});

  Future<ApiResult> dislikePost(String postId) =>
      crud.postData('${ApiLink.posts}/$postId/dislike', {});

  Future<ApiResult> addComment(String postId, String content) =>
      crud.postData('${ApiLink.comments}/$postId', {'content': content});

  Future<ApiResult> likeComment(String commentId) =>
      crud.postData('${ApiLink.comments}/comments/$commentId/like', {});

  /// الموافقة على منشور معلّق (للأدمن).
  Future<ApiResult> acceptPendingPost(String postId) =>
      crud.postData('${ApiLink.acceptPendingPosts}/$postId', {});
}
