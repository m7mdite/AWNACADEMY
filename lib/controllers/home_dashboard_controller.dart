import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/dashboard_model.dart';
import '../services/local_storge/local_user_storage.dart';
import '../services/remote/crud.dart';
import '../services/remote/dashboard_remote.dart';
import '../utils/app_constants/status_request.dart';

class HomeController extends GetxController {
  final DashboardRemote remote = DashboardRemote(Get.find());
  Rx<DashboardModel?> dashboard = Rx<DashboardModel?>(null);
  Rx<StatusRequest> statusRequest = StatusRequest.none.obs;
  RxBool isLoading = false.obs;

  RxInt currentAdvIndex = 0.obs;
  late PageController advPageController;
  Timer? _advAutoScrollTimer;
  final isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAdminStatus();
    advPageController = PageController(viewportFraction: 0.85);
    fetchDashboard();
  }

  Future<void> _checkAdminStatus() async {
    final role = await Get.find<LocalUserStorage>().getRole();
    isAdmin.value = (role == 'admin');
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    statusRequest.value = StatusRequest.loading;
    try {
      final result = await remote.getDashboard();
      switch (result) {
        case ApiSuccess(data: final body):
          dashboard.value = DashboardModel.fromJson(body['data']);
          statusRequest.value = StatusRequest.success;
          _startAdvAutoScroll();
        case ApiFailure(:final status, :final message):
          statusRequest.value = status;
          Get.snackbar('خطأ', message ?? 'فشل تحميل البيانات');
      }
    } catch (_) {
      statusRequest.value = StatusRequest.serverFailure;
      Get.snackbar('خطأ', 'فشل تحميل البيانات');
    } finally {
      isLoading.value = false;
    }
  }

  void _startAdvAutoScroll() {
    _advAutoScrollTimer?.cancel();
    final advs = dashboard.value?.adv?.data ?? [];
    if (advs.isEmpty) return;

    _advAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (advPageController.hasClients) {
        final next = (currentAdvIndex.value + 1) % advs.length;
        advPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        currentAdvIndex.value = next;
      }
    });
  }

  void onAdvPageChanged(int index) {
    currentAdvIndex.value = index;
  }

  @override
  void onClose() {
    _advAutoScrollTimer?.cancel();
    advPageController.dispose();
    super.onClose();
  }
}