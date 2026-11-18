import 'dart:io';
import 'package:get/get.dart';
import '../../../../api_link.dart';
import '../../crud.dart';

class ChatRemote {
  final Crud _crud = Get.find<Crud>();

  /// جلب رسائل محادثة مع مستخدم آخر.
  Future<ApiResult> getConversationMessages(String otherUserId) =>
      _crud.getData('${ApiLink.conversations}/$otherUserId');

  Future<ApiResult> sendTextMessage(String conversationId, String text) =>
      _crud.postData('${ApiLink.conversations}/$conversationId', {'text': text});

  Future<ApiResult> sendFileMessage(String conversationId, File file) =>
      _crud.postDataWithFiles(
        '${ApiLink.conversations}/$conversationId',
        {},
        [file.path],
        'file',
      );
}
