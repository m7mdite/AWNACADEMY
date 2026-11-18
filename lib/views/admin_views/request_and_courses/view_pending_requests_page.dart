import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controllers/admin_request_controller.dart';
import '../../widgets/botton_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/dialog/submit_dialog.dart';
import '../../widgets/requests/card_request_processing.dart';
import '../../widgets/requests/show_request.dart';

class ViewPendingRequestsPage extends StatelessWidget {
  final AdminRequestControllerImpl controller =
      Get.find<AdminRequestControllerImpl>();
  ViewPendingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "قيد الانتظار",
      ),
      body: GetBuilder<AdminRequestControllerImpl>(builder: (_) {
        return RefreshIndicator(
          onRefresh: () async {
            controller.getAllPendingRequests();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  CardRequestProcessing(
                    requestModel: controller.pendingRequests[index],
                    onTap: () {
                      Get.dialog(
                        ShowRequest(
                          requestModel: controller.pendingRequests[index],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: BottonContainer(
                      body: "حذف ",onTap: () {
                      Get.dialog(
                        SubmitDialog(
                          title: 'تأكيد الحذف',
                          question: 'هل أنت متأكد من حذف هذا الطلب؟',
                          agreeBottontitle: 'حذف',
                          onTapSubmit: () {
                            Get.back();
                            controller.deleteRequest(
                                controller.pendingRequests[index].sId!);
                          },
                        ),
                      );
                    },
                    ),
                  ),
                ],
              );
            },
            itemCount: controller.pendingRequests.length,
          ),
        );
      }),
    );
  }
}
