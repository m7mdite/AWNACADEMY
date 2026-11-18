import '../../api_link.dart';
import 'crud.dart';

class AuthRemote {
  final Crud crud;
  AuthRemote(this.crud);

  // 401 هنا تعني بيانات دخول خاطئة وليست جلسة منتهية، فلا نعالجها كانتهاء جلسة
  Future<ApiResult> register(Map data) =>
      crud.postData(ApiLink.register, data, handleUnauthorized: false);

  Future<ApiResult> login(Map data) =>
      crud.postData(ApiLink.login, data, handleUnauthorized: false);
}
