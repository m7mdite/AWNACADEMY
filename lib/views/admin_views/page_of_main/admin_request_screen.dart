// lib/views/admin_views/page_of_main/admin_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controllers/admin_request_controller.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../widgets/custom_app_bar.dart';
import '../widgets/admin_menu_widgets.dart';

class AdminRequestScreen extends StatelessWidget {
  final AdminRequestControllerImpl controller =
      Get.put(AdminRequestControllerImpl());

  AdminRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "إدارة الطلبات",
        automaticallyImplyLeading: false,
      ),
      body: AdminPageBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            controller.onInit();
          },
          child: AnimationLimiter(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== الطلبات =====
                  AdminAnimatedItem(
                    position: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AdminSectionHeader(
                          icon: Icons.request_page,
                          title: "الطلبات",
                        ),
                        AdminMenuGrid(
                          children: [
                            AdminMenuCard(
                              title: "قيد الانتظار",
                              icon: Icons.hourglass_empty,
                              color: AppColors.warning,
                              onTap: controller.toViewPendingRequestsPage,
                            ),
                            AdminMenuCard(
                              title: "قيد المعالجة",
                              icon: Icons.settings,
                              color: AppColors.primaryAccent,
                              onTap: controller.toViewInProcessingRequestsPage,
                            ),
                            AdminMenuCard(
                              title: "المكتملة",
                              icon: Icons.check_circle,
                              color: AppColors.success,
                              onTap: controller.toViewFinishedRequestsPage,
                            ),
                            AdminMenuCard(
                              title: "المرفوضة",
                              icon: Icons.cancel,
                              color: AppColors.error,
                              onTap: controller.toViewRejectedRequestsPage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ===== المعالجات =====
                  AdminAnimatedItem(
                    position: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AdminSectionHeader(
                          icon: Icons.medical_services,
                          title: "المعالجات",
                        ),
                        AdminMenuGrid(
                          children: [
                            AdminMenuCard(
                              title: "عرض المعالجات",
                              icon: Icons.visibility,
                              color: AppColors.teal,
                              onTap: controller.toViewTreatmentsPage,
                            ),
                            AdminMenuCard(
                              title: "إضافة معالجة",
                              icon: Icons.add,
                              color: AppColors.success,
                              onTap: controller.toAddTreatmentPage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ===== المواد الدراسية =====
                  AdminAnimatedItem(
                    position: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AdminSectionHeader(
                          icon: Icons.book,
                          title: "المواد الدراسية",
                        ),
                        AdminMenuGrid(
                          children: [
                            AdminMenuCard(
                              title: "عرض المواد",
                              icon: Icons.visibility,
                              color: AppColors.indigo,
                              onTap: controller.toViewCoursesPage,
                            ),
                            AdminMenuCard(
                              title: "إضافة مادة",
                              icon: Icons.add,
                              color: AppColors.primaryAccent,
                              onTap: controller.toAddCoursePage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ===== الدروس =====
                  AdminAnimatedItem(
                    position: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AdminSectionHeader(
                          icon: Icons.video_library,
                          title: "الدروس",
                        ),
                        AdminMenuGrid(
                          children: [
                            AdminMenuCard(
                              title: "إضافة درس",
                              icon: Icons.add,
                              color: AppColors.warning,
                              onTap: controller.toAddLessonsPage,
                            ),
                            AdminMenuCard(
                              title: "عرض البرنامج",
                              icon: Icons.calendar_month,
                              color: AppColors.warning,
                              onTap: controller.toViewLessons,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ===== الفئات =====
                  AdminAnimatedItem(
                    position: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AdminSectionHeader(
                          icon: Icons.category,
                          title: "الفئات",
                        ),
                        AdminMenuGrid(
                          children: [
                            AdminMenuCard(
                              title: "عرض الفئات",
                              icon: Icons.visibility,
                              color: AppColors.purple,
                              onTap: controller.toViewCategorysPage,
                            ),
                            AdminMenuCard(
                              title: "إضافة فئة",
                              icon: Icons.add,
                              color: AppColors.deepPurple,
                              onTap: controller.toAddCategoryPage,
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
      ),
    );
  }
}
