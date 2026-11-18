import 'package:get/get.dart';
import '../../../api_link.dart';
import '../crud.dart';

class AdminsRemote {
  final Crud _crud = Get.find<Crud>();

  Future<ApiResult> getAllAdmins() => _crud.getData('${ApiLink.report}/admins');
}
