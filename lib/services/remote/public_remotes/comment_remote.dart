import '../../../services/remote/crud.dart';
import '../../../api_link.dart';

class CommentRemote {
  final Crud crud;
  CommentRemote(this.crud);

  Future<ApiResult> getCommentsByPost(String postId) =>
      crud.getData('${ApiLink.comments}?post=$postId');

  Future<ApiResult> addComment(String postId, String content) =>
      crud.postData(ApiLink.comments, {
        'post': postId,
        'content': content,
      });
}
