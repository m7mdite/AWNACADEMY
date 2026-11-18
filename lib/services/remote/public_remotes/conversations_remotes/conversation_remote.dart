import 'package:get/get.dart';
import '../../../../api_link.dart';
import '../../crud.dart';

class ConversationRemote {
  final Crud crud = Get.find<Crud>();

  Future<ApiResult> getUserConversations() => crud.getData(ApiLink.conversations);

  Future<ApiResult> openConversation(String otherUserId) =>
      crud.getData('${ApiLink.conversations}/$otherUserId');
}
