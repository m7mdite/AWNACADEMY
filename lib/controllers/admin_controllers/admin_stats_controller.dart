import 'package:get/get.dart';

import '../../models/admin_models/stats_model.dart';
import '../../services/remote/admin_remotes/admin_remote.dart';
import '../../services/remote/crud.dart';

class AdminStatsController extends GetxController {
  final AdminRemote _remote = AdminRemote(Get.find<Crud>());

  final Rxn<AdminStats> stats = Rxn<AdminStats>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt weeks = 8.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _remote.getStats(weeks: weeks.value);
      switch (result) {
        case ApiSuccess(data: final body):
          stats.value =
              AdminStats.fromJson(Map<String, dynamic>.from(body['data'] ?? {}));
        case ApiFailure(:final message):
          error.value = message ?? 'تعذر تحميل الإحصاءات';
      }
    } catch (_) {
      error.value = 'تعذر تحميل الإحصاءات';
    } finally {
      isLoading.value = false;
    }
  }

  void setWeeks(int w) {
    if (weeks.value == w) return;
    weeks.value = w;
    fetchStats();
  }
}
