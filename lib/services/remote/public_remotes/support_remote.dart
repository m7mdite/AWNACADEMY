import '../../../services/remote/crud.dart';
import '../../../api_link.dart';

class SupportRemote {
  final Crud crud;
  SupportRemote(this.crud);

  Future<ApiResult> sendSupportMessage({
    required String subject,
    required String message,
  }) =>
      crud.postData(ApiLink.supportMessage, {
        'subject': subject,
        'message': message,
      });
}
