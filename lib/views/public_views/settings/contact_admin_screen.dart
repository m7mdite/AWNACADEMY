// views/screens/.../contact_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/conversations_controllers/conversations_controller.dart';
import '../../../controllers/public_controllers/admins_controller.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../widgets/custom_app_bar.dart';
class ContactAdminScreen extends StatelessWidget {
  final AdminsController controller = Get.put(AdminsController());

  ContactAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ConversationsController مفروض مسجل مسبقاً (Global Binding)
    final conversationsController = Get.isRegistered<ConversationsController>()
        ? Get.find<ConversationsController>()
        : Get.put(ConversationsController());

    return Scaffold(
      appBar: CustomAppBar(title: "مراسلة المشرفين", automaticallyImplyLeading: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.admins.isEmpty) {
          return const Center(child: Text('لا يوجد مشرفون متاحون حالياً'));
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAdmins,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.admins.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final admin = controller.admins[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage: admin.profilePhoto != null
                        ? NetworkImage(admin.profilePhoto!)
                        : null,
                    child: admin.profilePhoto == null
                        ? Icon(Icons.admin_panel_settings, color: AppColors.primary)
                        : null,
                  ),
                  title: Text(
                    admin.fullName.trim().isNotEmpty
                        ? admin.fullName
                        : '${admin.firstName} ${admin.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: admin.bio != null && admin.bio!.isNotEmpty
                      ? Text(admin.bio!, maxLines: 1, overflow: TextOverflow.ellipsis)
                      : const Text('مشرف'),
                  trailing: Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                  onTap: () => conversationsController.openConversation(admin.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}