import '../../../api_link.dart';
import '../crud.dart';

class AuthRemote {
  final Crud crud;
  AuthRemote(this.crud);

  Future<ApiResult> register(Map data) => crud.postData(ApiLink.register, data);

  Future<ApiResult> login(Map data) => crud.postData(ApiLink.login, data);
}
