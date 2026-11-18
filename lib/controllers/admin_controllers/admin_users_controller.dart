import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_route.dart';
import '../../models/public_models/profile_model.dart';
import '../../models/admin_models/veify_student_model.dart';
import '../../services/functions/show_snack.dart';
import '../../services/local_storge/local_user_storage.dart';
import '../../services/remote/admin_remotes/admin_remote.dart';
import '../../services/remote/crud.dart';
import '../../utils/app_constants/status_request.dart';
import '../../views/admin_views/submit_verify_student.dart';
import '../../views/admin_views/users/admin_reports_screen.dart';
import '../../views/widgets/dialog/submit_dialog.dart';

abstract class AdminUsersController extends GetxController {
 void toAddOverSeerPage();
 void toViewOverSeersPage();
 void toViewStudentsPage();
 void toViewPatientesPage();
 void toViewVerifyStudentsPage();
 void toReportsPage();
 void acceptVerifyStudent(String studentId);
 void rejectVerifyStudent(String studentId);
 void addOverSeer();
 Future<void> getAllOverSeers();
 Future<void> getAllStudents();
 Future<void> getAllPatientes();
 void getAllVerifyStudents();
 void toSubmitVerifyStudentPage(VeifyStudentModel student);
 void logout();
}

class AdminUsersControllerImpl extends AdminUsersController {
  RxBool isLoading = false.obs;

  List<ProfileModel> overSeers = [];
  List<ProfileModel> students = [];
  List<ProfileModel> patients = [];
  List<VeifyStudentModel> verifyStudents = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController rejectReasonController =
      TextEditingController(text: "خطأ بالمعلومات ");
  AdminRemote adminRemote = AdminRemote(Get.find());
  late StatusRequest statusRequest;

  /// ينفّذ الطلب ويحدّث statusRequest، ولا يرمي استثناء أبدًا.
  Future<ApiResult> _call(Future<ApiResult> Function() request) async {
    ApiResult result;
    try {
      result = await request();
    } catch (_) {
      result = const ApiFailure(StatusRequest.serverFailure);
    }
    statusRequest = switch (result) {
      ApiSuccess() => StatusRequest.success,
      ApiFailure(:final status) => status,
    };
    return result;
  }

  @override
  void onInit() {
    getAllOverSeers();
    super.onInit();
  }

  @override
  toAddOverSeerPage() {
    Get.toNamed(AppRroute.addOverSeer);
  }

  @override
  addOverSeer() async {
    if (isLoading.value) return;
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    final Map data = {
      "email": emailController.text,
      "password": passwordController.text,
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "father_name": fatherNameController.text,
    };
    statusRequest = StatusRequest.loading;
    update();

    final result = await _call(() => adminRemote.addOverSeer(data));
    switch (result) {
      case ApiSuccess(data: final body):
        showsnack(
            title: "${body['status'] ?? 'تم'}",
            message: "${body['message'] ?? ''}");
      case ApiFailure(:final message):
        showsnack(title: "خطأ", message: message ?? "فشل إضافة المشرف");
    }
    update();
    isLoading.value = false;
  }

  @override
  toViewOverSeersPage() {
    Get.toNamed(AppRroute.viewOverSeers);
  }

  @override
  getAllOverSeers() async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(adminRemote.getAllOverSeers);
    switch (result) {
      case ApiSuccess(data: final body):
        if (body['data'] == null) {
          overSeers = [];
        } else {
          overSeers = (body['data'] as List)
              .map<ProfileModel>((json) => ProfileModel.fromJson(json))
              .toList();
        }
      case ApiFailure(:final message):
        showsnack(title: "خطأ", message: message ?? "فشل تحميل المشرفين");
    }
    update();
  }

  @override
  getAllStudents() async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(adminRemote.getAllStudents);
    switch (result) {
      case ApiSuccess(data: final body):
        students = (body['data'] as List)
            .map<ProfileModel>((json) => ProfileModel.fromJson(json))
            .toList();
      case ApiFailure(:final message):
        showsnack(title: "خطأ", message: message ?? "فشل تحميل الطلاب");
    }
    update();
  }

  @override
  toViewStudentsPage() {
    Get.toNamed(AppRroute.viewStudents);
  }

  @override
  getAllPatientes() async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(adminRemote.getAllPatientes);
    switch (result) {
      case ApiSuccess(data: final body):
        patients = (body['data'] as List)
            .map<ProfileModel>((json) => ProfileModel.fromJson(json))
            .toList();
      case ApiFailure(:final message):
        Get.snackbar("Error", message ?? "Failed to fetch Patients");
    }
    update();
  }

  @override
  toViewPatientesPage() {
    Get.toNamed(AppRroute.viewPatientes);
  }

  @override
  toViewVerifyStudentsPage() {
    Get.toNamed(AppRroute.verifyStudents);
  }

  @override
  getAllVerifyStudents() async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(adminRemote.getAllVerifyStudents);
    switch (result) {
      case ApiSuccess(data: final body):
        verifyStudents = (body['data'] as List)
            .map<VeifyStudentModel>((json) => VeifyStudentModel.fromJson(json))
            .toList();
      case ApiFailure(:final message):
        Get.snackbar("Error", message ?? "Failed to fetch Verify Students");
    }
    update();
  }

  @override
  toSubmitVerifyStudentPage(VeifyStudentModel student) {
    Get.dialog(SubmitVerifyStudent(
      studentModel: student,
    ));
  }

  @override
  void toReportsPage() {
    Get.to(() => AdminReportsScreen());
  }

  @override
  acceptVerifyStudent(String studentId) {
    Get.dialog(
      SubmitDialog(
        title: "تأكيد التوثيق",
        question: "هل أنت متأكد أنك تريد توثيق هذا الطالب؟",
        onTapSubmit: () async {
          statusRequest = StatusRequest.loading;
          update();
          final result =
              await _call(() => adminRemote.acceptVerifyStudent(studentId));
          switch (result) {
            case ApiSuccess(data: final body):
              Get.snackbar("${body['status'] ?? 'تم'}",
                  "${body['message'] ?? ''}");
              getAllVerifyStudents();
              Get.close(1);
            case ApiFailure(:final message):
              Get.snackbar("Error", message ?? "Failed to verify Student");
          }
          update();
        },
      ),
    );
  }

  @override
  rejectVerifyStudent(String studentId) async {
    if (rejectReasonController.text == "") {
      Get.snackbar("فشل", "ادخل سبب الرفض");
      return;
    }
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(() => adminRemote.rejectVerifyStudent(studentId,
        data: {"reject_reason": rejectReasonController.text}));
    switch (result) {
      case ApiSuccess(data: final body):
        Get.snackbar("${body['status'] ?? 'تم'}", "${body['message'] ?? ''}");
        getAllVerifyStudents();
        Get.close(1);
      case ApiFailure(:final message):
        Get.snackbar("خطأ", message ?? "حدث خطأ ما ");
    }
    update();
  }

  Future<void> deleteOverSeer(String id) async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(() => adminRemote.deleteOverSeer(id));
    switch (result) {
      case ApiSuccess(data: final body):
        // إزالة المشرف من القائمة المحلية
        overSeers.removeWhere((overSeer) => overSeer.user == id);
        showsnack(
            title: 'نجاح',
            message: body['message']?.toString() ?? 'تم حذف المشرف بنجاح');
      case ApiFailure(:final message):
        showsnack(title: 'خطأ', message: message ?? 'فشل حذف المشرف');
    }
    update();
  }

  @override
  logout() async {
    Get.dialog(
      SubmitDialog(
        title: "تسجيل الخروج",
        question: "هل أنت متأكد من رغبتك بتسجيل الخروج؟",
        onTapSubmit: () async {
          await Get.find<LocalUserStorage>().deleteToken();
          await Get.find<LocalUserStorage>().deleteRole();
          await Get.find<LocalUserStorage>().clearAll();
          Get.offAllNamed(AppRroute.auth);
        },
      ),
    );
  }
}