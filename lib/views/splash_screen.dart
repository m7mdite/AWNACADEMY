import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_route.dart';
import '../services/local_storge/local_user_storage.dart';
import '../services/notification/websocket_service.dart';
import '../utils/app_constants/colors_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final storage = Get.find<LocalUserStorage>();
    final token = await storage.getToken();
    final role = await storage.getRole();

    final bool hasToken = token != null && token.isNotEmpty;
    final bool isAllowedRole = role == 'admin' || role == 'overseer';

    if (hasToken && isAllowedRole) {
      // أعد الاتصال بالـ WebSocket إذا في توكن
      final userId = storage.getId();
      if (userId != null && userId.isNotEmpty) {
        Get.find<WebSocketService>().connect(userId);
      }
      _navigateToHome(role);
    } else {
      Get.offAllNamed(AppRroute.auth);
    }
  }

  void _navigateToHome(String? role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed(AppRroute.mainScreenAdmin);
        break;
      case 'overseer':
        Get.offAllNamed(AppRroute.mainScreenOverseer);
        break;
      default:
        Get.offAllNamed(AppRroute.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary700, AppColors.primary300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // هنا يمكنك وضع شعار التطبيق
              Icon(
                Icons.health_and_safety,
                size: 80,
                color: AppColors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'My Tooth',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                color: AppColors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'جاري التحميل...',
                style: TextStyle(color: AppColors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
