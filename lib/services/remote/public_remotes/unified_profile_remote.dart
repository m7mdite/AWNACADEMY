import 'dart:io';
import '../../../services/remote/crud.dart';
import '../../../api_link.dart';

class UnifiedProfileRemote {
  final Crud crud;
  UnifiedProfileRemote(this.crud);

  Future<ApiResult> getMyProfile() => crud.getData(ApiLink.profile);

  Future<ApiResult> updateProfile(Map<String, dynamic> data) =>
      crud.putData(ApiLink.profile, data);

  /// رفع صورة البروفايل (PUT مع ملف).
  Future<ApiResult> uploadProfilePicture(File image) =>
      crud.putDataWithFiles(ApiLink.photo, {}, [image.path], 'profile_photo');

  /// إرسال وثيقة التوثيق (POST مع ملف واحد).
  Future<ApiResult> sendVerifyDocument(File image) =>
      crud.postDataWithFiles(ApiLink.verify, {}, [image.path], 'document');
}
