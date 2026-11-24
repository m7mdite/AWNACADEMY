import 'package:get/get.dart';

import '../../api_link.dart';
import '../../models/admin_models/moderation_model.dart';
import '../../services/remote/crud.dart';

/// سجل إجراءات الأدمن مع صفحات.
class AdminActionsController extends GetxController {
  final Crud _crud = Get.find<Crud>();

  final List<AdminActionLogItem> items = <AdminActionLogItem>[];
  bool loading = false;
  bool loaded = false;
  bool failed = false;
  bool hasMore = false;
  int _page = 1;

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    failed = false;
    update();

    final result = await _crud.getData('${ApiLink.servere}/admin/actions?page=$_page');
    switch (result) {
      case ApiSuccess(data: final body):
        final raw = body['data'];
        final list = raw is List
            ? raw
                .whereType<Map>()
                .map((e) => AdminActionLogItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <AdminActionLogItem>[];
        if (_page == 1) items.clear();
        items.addAll(list);
        hasMore = body['has_more'] == true;
      case ApiFailure():
        failed = true;
        if (_page > 1) _page--;
    }

    loaded = true;
    loading = false;
    update();
  }

  Future<void> refreshAll() async {
    _page = 1;
    await load();
  }

  Future<void> loadMore() async {
    if (!hasMore || loading) return;
    _page++;
    await load();
  }
}
