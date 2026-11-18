import 'package:get/get.dart';
import '../../models/public_models/admin_model.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/admins_remote.dart';
import '../../utils/app_constants/status_request.dart';

class AdminsController extends GetxController {
  final AdminsRemote _adminsRemote = AdminsRemote();

  RxList<AdminModel> admins = <AdminModel>[].obs;
  final RxBool isLoading = false.obs;
  late StatusRequest statusRequest;

  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    isLoading.value = true;
    statusRequest = StatusRequest.loading;
    try {
      final result = await _adminsRemote.getAllAdmins();
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          admins.value = (body['data'] as List)
              .map((item) => AdminModel.fromJson(item))
              .toList();
        case ApiFailure(:final status):
          statusRequest = status;
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
    } finally {
      isLoading.value = false;
    }
  }
}
