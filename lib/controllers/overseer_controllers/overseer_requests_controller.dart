import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/requests_models/treatment_model.dart';
import '../../models/requests_models/treatment_request_model.dart';
import '../../services/functions/show_snack.dart';
import '../../services/remote/crud.dart';
import '../../services/remote/public_remotes/request_remote.dart';
import '../../utils/app_constants/status_request.dart';
import '../../views/overseer_views/overseer_view_request_processing.dart';
import '../../views/widgets/dialog/submit_dialog.dart';
import '../../views/widgets/requests/overseer_manage_request.dart';
import '../../views/widgets/requests/overseer_reject_request.dart';

abstract class OverseerRequestsController extends GetxController {
  // تعريف الدوال التي ستستخدم في التحكم في الطلبات
 void getProcessingRequest();
 void showRequest(TreatmentRequestModel request);
 void toRejectRequest(TreatmentRequestModel request);
 void rejectRequest(TreatmentRequestModel request);
 void manageRequest(TreatmentRequestModel request);
 Future<void> changeCaseRequest(TreatmentRequestModel request);
 void toManageRequest(TreatmentRequestModel request);
 Future<void> addEvaluationRequest(TreatmentRequestModel request);
 Future<void> finishRequest(TreatmentRequestModel request);
  void getAllTreatment();
}

class OverseerRequestsControllerImpl extends OverseerRequestsController {
  List<TreatmentRequestModel> requestList = <TreatmentRequestModel>[];
  TreatmentRequestModel selectRequest = TreatmentRequestModel();
  List<TreatmentModel> treatments = <TreatmentModel>[];
  RequestRemote requestRemote = RequestRemote(Get.find());
  late StatusRequest statusRequest;
  late TextEditingController textEditingControllerReject;
  late TextEditingController textEditingControllerFeedback;
  late TextEditingController textEditingControllerNote;
  late TextEditingController textEditingControllerAddEvaluation;

  bool rejectBool = false;
  bool finishBool = false;
  TreatmentModel? selectnewTreatment;
  RxInt selectedRating = 1.obs;

  void formatTextEditing() {
    textEditingControllerAddEvaluation = TextEditingController();
    textEditingControllerFeedback = TextEditingController();
    textEditingControllerNote = TextEditingController();
    textEditingControllerReject = TextEditingController();
  }

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

  /// نتيجة طلب تعديل: رسالة + إغلاق الحوار + إعادة تحميل الطلبات عند النجاح.
  void _handleActionResult(ApiResult result) {
    switch (result) {
      case ApiSuccess(data: final body):
        showsnack(
          title: "${body['status'] ?? 'تم'}",
          message: "${body['message'] ?? ''}",
        );
        Get.close(1);
        getProcessingRequest();
      case ApiFailure(:final message):
        showsnack(title: "خطأ", message: message ?? "فشلت العملية");
    }
  }

  @override
  void onInit() {
    formatTextEditing();
    getAllTreatment();
    getProcessingRequest();
    update();
    super.onInit();
  }

  @override
  getProcessingRequest() async {
    requestList = [];
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(requestRemote.getTreatmentRequestsForOverseer);
    switch (result) {
      case ApiSuccess(data: final body):
        requestList = (body['data'] as List)
            .map((e) => TreatmentRequestModel.fromJson(e))
            .toList();
      case ApiFailure(:final message):
        showsnack(title: "خطأ", message: message ?? "تعذر تحميل الطلبات");
    }
    update();
  }

  @override
  showRequest(TreatmentRequestModel request) {
    selectRequest = request;
    Get.dialog(
      OverseerViewRequestProcessing(requestModel: request),
    );
  }

  @override
  toRejectRequest(TreatmentRequestModel request) {
    Get.dialog(
      SubmitDialog(
        title: "رفض هذا الطلب",
        children: [
          Flexible(
            child: OverseerRejectRequest(),
          ),
        ],
        onTapSubmit: () {
          rejectRequest(request);
        },
      ),
    );
  }

  @override
  toManageRequest(TreatmentRequestModel request) {
    Get.dialog(
      SubmitDialog(
        title: "متابعة حالة الطلب",
        children: [
          Flexible(child: OverseerManageRequest()),
        ],
        onTapSubmit: () {
          manageRequest(request);
        },
      ),
    );
  }

  @override
  rejectRequest(TreatmentRequestModel request) async {
    if (rejectBool == false) {
      statusRequest = StatusRequest.loading;
      update();
      final result = await _call(() => requestRemote.rejectRequestData(
          {"note": textEditingControllerReject.text}, request.sId!));
      _handleActionResult(result);
    } else {
      await changeCaseRequest(request);
    }
    update();
  }

  @override
  manageRequest(TreatmentRequestModel request) async {
    if (finishBool) {
      // انتهاء الحالة
      await finishRequest(request);
    } else {
      await addEvaluationRequest(request);
    }
    onInit();
  }

  @override
  changeCaseRequest(TreatmentRequestModel request) async {
    final newTreatment = selectnewTreatment;
    if (newTreatment == null) {
      showsnack(title: "تنبيه", message: "اختر نوع المعالجة الجديد");
      return;
    }
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(() => requestRemote.changeCaseRequestData(
        {"note": textEditingControllerNote.text},
        request.sId!,
        newTreatment.caseType!.sId!));
    _handleActionResult(result);
    update();
  }

  @override
  getAllTreatment() async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(requestRemote.getTreatments);
    switch (result) {
      case ApiSuccess(data: final body):
        treatments = (body['data'] as List)
            .map((item) => TreatmentModel.fromJson(item))
            .toList();
        selectnewTreatment = treatments.isNotEmpty ? treatments[0] : null;
      case ApiFailure():
        break;
    }
    update();
  }

  @override
  addEvaluationRequest(TreatmentRequestModel request) async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(() => requestRemote.addEvaluationRequestData({
          "evaluationText": textEditingControllerAddEvaluation.text,
        }, request.sId!));
    _handleActionResult(result);
    update();
  }

  @override
  finishRequest(TreatmentRequestModel request) async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _call(() => requestRemote.complateRequestData({
          "rating": selectedRating.value.toString(),
          "feedback": textEditingControllerFeedback.text,
        }, request.sId!));
    _handleActionResult(result);
    update();
  }
}