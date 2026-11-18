import 'dart:io';

import '../../../api_link.dart';
import '../crud.dart';

class AdminRemote {
  final Crud crud;
  AdminRemote(this.crud);

  // ========== المشرفون ==========
  Future<ApiResult> addOverSeer(Map data) =>
      crud.postData(ApiLink.addOverSeer, data);

  Future<ApiResult> deleteOverSeer(String id) =>
      crud.postData('${ApiLink.deleteOverSeer}/$id', {});

  Future<ApiResult> getAllOverSeers() => crud.getData(ApiLink.getAllOverSeers);

  // ========== الطلاب والمرضى ==========
  Future<ApiResult> getAllStudents() => crud.getData(ApiLink.getAllStudents);

  Future<ApiResult> getAllPatientes() => crud.getData(ApiLink.getAllPatientes);

  Future<ApiResult> getAllVerifyStudents() =>
      crud.getData(ApiLink.getAllVerifyStudents);

  Future<ApiResult> acceptVerifyStudent(String studentId) =>
      crud.postData('${ApiLink.acceptVerifyStudent}/$studentId', {});

  Future<ApiResult> rejectVerifyStudent(String studentId, {Map? data}) =>
      crud.postData(
        '${ApiLink.rejectVerifyStudent}/$studentId',
        data ?? {'reject_reason': 'خطأ بالبيانات!'},
      );

  // ========== المقررات والعلاجات والتصنيفات ==========
  Future<ApiResult> getAllCourses() => crud.getData(ApiLink.getAllCourses);

  Future<ApiResult> getAllTreatments() =>
      crud.getData(ApiLink.getAllTreatments);

  Future<ApiResult> getAllCategory() => crud.getData(ApiLink.getAllCategory);

  Future<ApiResult> addTreatment(Map data) =>
      crud.postData(ApiLink.addTreatment, data);

  Future<ApiResult> addCourse(Map data) =>
      crud.postData(ApiLink.addCourse, data);

  Future<ApiResult> addCategory(Map data) =>
      crud.postData(ApiLink.addCategory, data);

  Future<ApiResult> deleteCategory(String id) =>
      crud.postData('${ApiLink.categories}/$id/delete', {});

  // ========== الجدول الأسبوعي ==========
  Future<ApiResult> getWeeklySchedule() => crud.getData(ApiLink.weeklySchedule);

  Future<ApiResult> addLessons(List<Map<String, dynamic>> data) =>
      crud.postManyData(ApiLink.weeklySchedule, data);

  Future<ApiResult> updateLesson(String id, Map data) =>
      crud.postData('${ApiLink.weeklySchedule}/$id', data);

  // ========== الطلبات ==========
  Future<ApiResult> getAllPendingRequests() =>
      crud.getData(ApiLink.getPendingRequest);

  Future<ApiResult> getAllInProcessingRequests() =>
      crud.getData(ApiLink.getProcessingRequests);

  Future<ApiResult> getCompletedRequests() =>
      crud.getData(ApiLink.getCompletedRequests);

  Future<ApiResult> getAllRejectedRequests() =>
      crud.getData(ApiLink.getRejectedRequests);

  /// حذف طلب علاج: DELETE /api/request/:id
  Future<ApiResult> deleteTreatmentRequest(String id) =>
      crud.deleteData(ApiLink.requests, id);

  /// تحديث/رفض طلب.
  /// ⚠️ الراوت في الباك PUT حسب تعليقك القديم، لكن الكود كان يرسل POST
  /// وأبقيته كما هو. إن فشل التحديث فجرّب crud.putData(..., id: id).
  Future<ApiResult> updateTreatmentRequest(String id, Map data) =>
      crud.postData('${ApiLink.requests}/$id', data);

  /// قبول الطلب وتعيين مشرف: POST /api/request/accept/:id/:overseer
  Future<ApiResult> acceptRequest(String id, String overseerId) =>
      crud.postData('${ApiLink.acceptRequest}/$id/$overseerId', {});

  /// إعادة تعيين مشرف: PUT /api/request/reassign-overseer/:id/:overseer
  /// (تصحيح: كان الرابط القديم نسبيًا بدون عنوان السيرفر، وكان يرسل POST).
  Future<ApiResult> reassignOverseer(String id, String overseerId) =>
      crud.putData('${ApiLink.dunningOverseer}/$id', {}, id: overseerId);

  /// جلب مشرفي كورس معيّن: GET /api/request/course-overseers/:id
  /// (تصحيح: الرابط القديم كان نسبيًا بدون عنوان السيرفر).
  Future<ApiResult> getCourseOverseers(String courseId) =>
      crud.getData('${ApiLink.getOverSeerForCourse}/$courseId');

  // ========== الإعلانات ==========
  Future<ApiResult> getAllAdvertisements() =>
      crud.getData(ApiLink.advertisements);

  Future<ApiResult> createAdvertisement({
    required String content,
    required File imageFile,
  }) =>
      crud.postDataWithFiles(
        ApiLink.advertisements,
        {'content': content},
        [imageFile.path],
        'image', // اسم الحقل كما هو متوقع في الباك (upload.single('image'))
      );

  Future<ApiResult> deleteAdvertisement(String id) =>
      crud.deleteData(ApiLink.advertisements, id);

  // ========== الإشعارات ==========
  Future<ApiResult> notifyUsersByRoles({
    required String title,
    required String body,
    required List<String> roles,
  }) =>
      crud.postData(ApiLink.notifyAll, {
        'title': title,
        'body': body,
        'roles': roles,
      });
}
