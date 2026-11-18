import '../../../services/remote/crud.dart';
import '../../../api_link.dart';

class PublicRemote {
  final Crud crud;
  PublicRemote(this.crud);

  Future<ApiResult> getOtherProfile(String id) =>
      crud.getData('${ApiLink.getOtherProfile}/$id');

  Future<ApiResult> reportUser(
    String userId,
    String reason,
    String description,
  ) =>
      crud.postData('${ApiLink.report}/$userId', {
        'type': reason,
        'reason': description,
      });

  Future<ApiResult> changePassword(String oldPassword, String newPassword) =>
      crud.postData(ApiLink.changePassword, {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
}
