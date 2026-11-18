import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/local_storge/local_user_storage.dart';
import '../../services/remote/ai_remote.dart';
import '../../services/remote/crud.dart';
import '../../utils/app_constants/ai_constants.dart';

abstract class AiChatContr extends GetxController {
  void sendMessage();
  void clearChat();
  void copyMessage(String text);
  void retryMessage(int index);
  dynamic getRoleFromLocal();
  void setFirstMessag();
}

class AiChatController extends AiChatContr {
  final AiRemote _aiRemote = AiRemote();

  // قائمة الرسائل (السجل محفوظ في السيرفر لكل مستخدم)
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  ChatMessage? firstUserMessage;
  String? role; // للترحيب فقط؛ تعليمات النظام يركّبها الباك حسب الدور

  final TextEditingController messageController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    await getRoleFromLocal();
    setFirstMessag();
    await loadHistory();
  }

  /// تحميل سجل المحادثة من السيرفر؛ إن كان فارغًا أو تعذّر التحميل نعرض الترحيب.
  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final result = await _aiRemote.getHistory();
      switch (result) {
        case ApiSuccess(data: final body):
          final list = (body['data'] as List?) ?? [];
          messages.value = list
              .map((j) => ChatMessage(
                    text: (j['content'] ?? '').toString(),
                    isUser: j['role'] == 'user',
                    timestamp:
                        DateTime.tryParse((j['createdAt'] ?? '').toString())
                                ?.toLocal() ??
                            DateTime.now(),
                  ))
              .toList();
        case ApiFailure():
          break;
      }
    } catch (_) {
      // نكتفي بالترحيب
    }
    if (messages.isEmpty) addWelcomeMessage();
    isLoading.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  void addWelcomeMessage() {
    messages.add(firstUserMessage ??
        ChatMessage(
          text: "مرحباً! كيف يمكنني مساعدتك اليوم؟",
          isUser: false,
          timestamp: DateTime.now(),
        ));
  }

  @override
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    messageController.clear();
    scrollToBottom();

    isLoading.value = true;
    isTyping.value = true;

    try {
      final result = await _aiRemote.chat(text);
      switch (result) {
        case ApiSuccess(data: final body):
          final reply = (body['data']?['reply']?['content'] ?? '').toString();
          messages.add(ChatMessage(
            text: reply.isEmpty ? "لم أستطع فهم طلبك." : reply,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        case ApiFailure(:final message):
          // رسالة السيرفر (حد الرسائل، المساعد مشغول، انتهت المهلة...)
          messages.add(ChatMessage(
            text: message ?? "عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.",
            isUser: false,
            isError: true,
            timestamp: DateTime.now(),
          ));
      }
    } catch (_) {
      messages.add(ChatMessage(
        text: "عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.",
        isUser: false,
        isError: true,
        timestamp: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
      isTyping.value = false;
      scrollToBottom();
    }
  }

  @override
  void clearChat() async {
    final result = await _aiRemote.clearHistory();
    switch (result) {
      case ApiSuccess():
        messages.clear();
        addWelcomeMessage();
      case ApiFailure(:final message):
        Get.snackbar('خطأ', message ?? 'تعذر مسح المحادثة');
    }
  }

  @override
  void copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ الرسالة إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  getRoleFromLocal() async {
    final storage = Get.find<LocalUserStorage>();
    role = await storage.getRole();
    role ??= "patient";
  }

  @override
  void setFirstMessag() {
    final String? text = switch (role) {
      "patient" => AiConstants.helloPatient,
      "student" => AiConstants.helloStudent,
      "overseer" => AiConstants.helloOverseer,
      "admin" => AiConstants.helloAdmin,
      _ => null,
    };
    firstUserMessage = ChatMessage(
      text: text ?? "مرحباً! كيف يمكنني مساعدتك اليوم؟",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  @override
  void retryMessage(int index) {
    final message = messages[index];
    if (message.isUser) {
      messageController.text = message.text;
      sendMessage();
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

// نموذج الرسالة
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    required this.timestamp,
  });
}
