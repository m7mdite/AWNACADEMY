import 'package:get/get.dart';
import '../../app_route.dart';
import '../../models/conversations_models/conversation_model.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/conversations_remotes/conversation_remote.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/status_request.dart';

class ConversationsController extends GetxController {
  final ConversationRemote _conversationRemote = ConversationRemote();
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  ConversationModel? newConversation;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  late StatusRequest statusRequest;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    errorMessage.value = '';
    statusRequest = StatusRequest.loading;
    try {
      final result = await _conversationRemote.getUserConversations();
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          conversations.value = (body['data'] as List)
              .map((item) => ConversationModel.fromJson(item))
              .toList();
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          // الشاشة تعرض errorMessage مع زر "إعادة المحاولة"
          errorMessage.value = message ?? 'تعذر تحميل المحادثات';
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      errorMessage.value = 'حدث خطأ غير متوقع';
    } finally {
      isLoading.value = false;
    }
  }

  void goToChat(String conversationId, OtherPartyProfile otherPartyProfile) {
    Get.toNamed(AppRroute.chat, arguments: {
      'conversationId': conversationId,
      'otherPartyProfile': otherPartyProfile,
    });
  }

  Future<void> openConversation(String otherUserId) async {
    statusRequest = StatusRequest.loading;
    try {
      final result = await _conversationRemote.openConversation(otherUserId);
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          newConversation = ConversationModel.fromJson(body['data']);
          goToChat(
            newConversation!.conversationId!,
            newConversation!.otherPartyProfile!,
          );
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          Get.snackbar(
            'خطأ',
            message ?? 'تعذر فتح المحادثة',
            backgroundColor: AppColors.error,
            colorText: AppColors.white,
          );
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
    }
  }

  Future<void> refreshConversations() => fetchConversations();
}
