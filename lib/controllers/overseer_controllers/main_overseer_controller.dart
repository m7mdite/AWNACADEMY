import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../views/public_views/home_screen.dart';
import '../../views/overseer_views/overseer_request_screen.dart';
import '../../views/public_views/posts/feed_screen.dart';
import '../../views/public_views/settings/setting_screen.dart';

abstract class MainOverseerController extends GetxController {}

class MainOverseerControllerImp extends MainOverseerController {
  PageController pageController = PageController(initialPage: 0);
    String titleAppBar = "";

  // قائمة الصفحات مع بياناتها
  final List<Map<String, dynamic>> listPage = [
    {
      "title": "الصفحة الرئيسية",
      "icon": Icons.home,
      "page": HomeScreen()
    },
    {
      "title": "الطلبات",
      "icon": Icons.history_edu_sharp,
      "page": OverseerRequestScreen()
    },
    {
      "title": "المنشورات",
      "icon": Icons.post_add_sharp,
      "page": FeedScreen()
    },
    {
      "title": "الملف الشخصي",
      "icon": Icons.account_circle,
      "page": SettingScreen()
    },
  ];

  int selectedPage = 0;
  
  // دالة مساعدة للحصول على عناصر الـ BottomNavigationBar
  List<Map<String, dynamic>> get bottomNavItems {
    return listPage.map((item) => {
      "title": item["title"],
      "icon": item["icon"],
    }).toList();
  }
  
  void toPage(int index) {
        titleAppBar = listPage[index]["title"];

    pageController.animateToPage(index,
        curve: Curves.easeIn, duration: const Duration(milliseconds: 100));
  }

  Map<String, dynamic> getPage() {
    return listPage[selectedPage];
  }

  void onPageChanged(int index) {
    selectedPage = index;
    update();
  }
}
