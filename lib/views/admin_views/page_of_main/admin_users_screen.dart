// lib/views/admin_views/page_of_main/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controllers/admin_users_controller.dart';
import '../../../services/functions/reset_server.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_app_bar.dart';
import '../widgets/admin_menu_widgets.dart';

class AdminUsersScreen extends StatelessWidget {
  final AdminUsersControllerImpl controller = Get.put(
    AdminUsersControllerImpl(),
  );

  AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "إدارة المستخدمين",
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          CustomIconAppBar(
            iconData: Icons.logout_outlined,
            reverseColors: true,
            onTap: () => controller.logout(),
          ),
        ],
      ),
      body: AdminPageBackground(
        child: AnimationLimiter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== المشرفون =====
                AdminAnimatedItem(
                  position: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminSectionHeader(
                        icon: Icons.admin_panel_settings,
                        title: "المشرفون",
                      ),
                      AdminMenuGrid(
                        children: [
                          AdminMenuCard(
                            title: 'إضافة مشرف',
                            icon: Icons.person_add,
                            color: AppColors.success,
                            onTap: () => controller.toAddOverSeerPage(),
                          ),
                          AdminMenuCard(
                            title: 'عرض المشرفين',
                            icon: Icons.people,
                            color: AppColors.primaryAccent,
                            onTap: () {
                              controller.getAllOverSeers();
                              controller.toViewOverSeersPage();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== الطلاب =====
                AdminAnimatedItem(
                  position: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminSectionHeader(
                        icon: Icons.school,
                        title: "الطلاب",
                      ),
                      AdminMenuGrid(
                        children: [
                          AdminMenuCard(
                            title: 'عرض الطلاب',
                            icon: Icons.school,
                            color: AppColors.warning,
                            onTap: () {
                              controller.getAllStudents();
                              controller.toViewStudentsPage();
                            },
                          ),
                          AdminMenuCard(
                            title: 'طلبات التوثيق',
                            icon: Icons.verified,
                            color: AppColors.purple,
                            onTap: () {
                              controller.getAllVerifyStudents();
                              controller.toViewVerifyStudentsPage();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== المرضى والبلاغات =====
                AdminAnimatedItem(
                  position: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminSectionHeader(
                        icon: Icons.health_and_safety,
                        title: "المرضى والبلاغات",
                      ),
                      AdminMenuGrid(
                        children: [
                          AdminMenuCard(
                            title: 'عرض المرضى',
                            icon: Icons.health_and_safety,
                            color: AppColors.teal,
                            onTap: () {
                              controller.getAllPatientes();
                              controller.toViewPatientesPage();
                            },
                          ),
                          AdminMenuCard(
                            title: 'البلاغات',
                            icon: Icons.report_problem,
                            color: AppColors.error,
                            onTap: () => controller.toReportsPage(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== النظام =====
                AdminAnimatedItem(
                  position: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminSectionHeader(
                        icon: Icons.settings,
                        title: "النظام",
                      ),
                      AdminMenuGrid(
                        children: [
                          AdminMenuCard(
                            title: 'تغيير عنوان السيرفر',
                            icon: Icons.dns_rounded,
                            color: Colors.blueGrey,
                            onTap: confirmResetServer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
