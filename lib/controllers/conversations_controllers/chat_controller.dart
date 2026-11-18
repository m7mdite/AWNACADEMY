import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/conversations_models/conversation_model.dart';
import '../../models/conversations_models/message_model.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/conversations_remotes/chat_remote.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/status_request.dart';

class ChatController extends GetxController {
  final String conversationId;
  final OtherPartyProfile otherPartyProfile;
  final ChatRemote _chatRemote = ChatRemote();

  RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  ChatController({
    required this.conversationId,
    required this.otherPartyProfile,
  });

  late StatusRequest statusRequest;

  @override
  void onInit() {
    super.onInit();
    fetchMessages(otherPartyProfile.userId!);
  }

  Future<void> fetchMessages(String otherUserId) async {
    isLoading.value = true;
    statusRequest = StatusRequest.loading;
    try {
      final result = await _chatRemote.getConversationMessages(otherUserId);
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          messages.value = (body['data']['messages'] as List)
              .map((item) => MessageModel.fromJson(item))
              .toList();
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          _showError(message ?? 'تعذر تحميل الرسائل');
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      _showError('حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
    }
  }

  void handleIncomingMessage(Map data) {
    final content = data['content'];
    if (content is! Map) return;

    final senderId = content['sender']?.toString();
    final msgConversationId = content['conversationId']?.toString();

    final isForThisConversation =
        (senderId != null && senderId == otherPartyProfile.userId) ||
            (msgConversationId != null && msgConversationId == conversationId);

    if (isForThisConversation) {
      fetchMessages(otherPartyProfile.userId!);
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();
    statusRequest = StatusRequest.loading;
    final result = await _chatRemote.sendTextMessage(conversationId, text);
    _handleSendResult(result, failedText: text);
  }

  Future<void> pickAndSendImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    statusRequest = StatusRequest.loading;
    final result =
        await _chatRemote.sendFileMessage(conversationId, File(pickedFile.path));
    _handleSendResult(result);
  }

  /// معالجة مشتركة لنتيجة إرسال نص أو صورة.
  /// عند فشل إرسال نص نعيده لحقل الكتابة حتى لا يضيع ما كتبه المستخدم.
  void _handleSendResult(ApiResult result, {String? failedText}) {
    switch (result) {
      case ApiSuccess(data: final body):
        statusRequest = StatusRequest.success;
        messages.insert(0, MessageModel.fromJson(body['data']));
      case ApiFailure(:final status, :final message):
        statusRequest = status;
        if (failedText != null && textController.text.isEmpty) {
          textController.text = failedText;
        }
        _showError(message ?? 'تعذر إرسال الرسالة');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
