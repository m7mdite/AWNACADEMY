import 'package:get/get.dart';

import '../../api_link.dart';
import '../../models/requests_models/portfolio_item_model.dart';
import '../../services/remote/crud.dart';

/// يجلب معرض الحالات المكتملة لمستخدم معيّن ([userId] أو 'me' لملفي).
/// - صاحب الملف: كل الحالات مع صفحات.
/// - غيره: آخر 3 حالات فقط (السيرفر يحدد ذلك).
class PortfolioController extends GetxController {
  final String userId;
  PortfolioController(this.userId);

  final Crud _crud = Get.find<Crud>();

  final List<PortfolioItem> items = <PortfolioItem>[];
  bool loading = false;
  bool loaded = false;
  bool failed = false;
  bool hasMore = false;
  bool isOwner = false;
  int total = 0;
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

    final result = await _crud
        .getData('${ApiLink.getOtherProfile}/$userId/portfolio?page=$_page');

    switch (result) {
      case ApiSuccess(data: final body):
        final raw = body['data'];
        final list = raw is List
            ? raw
                .whereType<Map>()
                .map((e) => PortfolioItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <PortfolioItem>[];
        if (_page == 1) items.clear();
        items.addAll(list);
        total = (body['total'] as num?)?.toInt() ?? items.length;
        hasMore = body['has_more'] == true;
        isOwner = body['is_owner'] == true;
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
