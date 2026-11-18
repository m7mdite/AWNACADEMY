import 'package:get/get.dart';
import '../controllers/auth_controllers/auth_controller.dart';
import '../controllers/auth_controllers/login_controller.dart';
import '../services/remote/public_remotes/auth_remote.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemote>(() => AuthRemote(Get.find()), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<LoginControllerImp>(() => LoginControllerImp(), fenix: true);
  }
}
