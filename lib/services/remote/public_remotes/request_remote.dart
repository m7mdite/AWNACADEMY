import '../../../api_link.dart';
import '../crud.dart';

class RequestRemote {
  final Crud crud;
  RequestRemote(this.crud);

  // ========== GET ==========
  Future<ApiResult> getTreatments() => crud.getData(ApiLink.treatments);

  Future<ApiResult> getTreatmentRequestsForOverseer() =>
      crud.getData(ApiLink.treatmentRequestsForOverseer);

  Future<ApiResult> getPendingRequests() =>
      crud.getData(ApiLink.getPendingRequest);

  Future<ApiResult> getPendingPatientRequest() =>
      crud.getData(ApiLink.getPendingRequest);

  Future<ApiResult> getProcessingRequest() =>
      crud.getData(ApiLink.getProcessingRequests);

  Future<ApiResult> getCompletedRequest() =>
      crud.getData(ApiLink.getCompletedRequests);

  Future<ApiResult> getRejectedPatientRequest() =>
      crud.getData(ApiLink.getRejectedRequests);

  Future<ApiResult> getOverSeerForCourse(String id) =>
      crud.getData('${ApiLink.getOverSeerForCourse}/$id');

  // ========== POST / PUT / DELETE ==========
  Future<ApiResult> acceptRequestData(Map data, String idR, String idO) =>
      crud.postData('${ApiLink.acceptRequest}/$idR/$idO', data);

  Future<ApiResult> dunningOverseerData(Map data, String idR, String idO) =>
      crud.putData('${ApiLink.dunningOverseer}/$idR', data, id: idO);

  Future<ApiResult> changeCaseRequestData(Map data, String idR, String idC) =>
      crud.putData('${ApiLink.changeCaseRequest}/$idR', data, id: idC);

  Future<ApiResult> rejectRequestData(Map data, String id) =>
      crud.putData(ApiLink.rejectRequest, data, id: id);

  Future<ApiResult> complateRequestData(Map data, String id) =>
      crud.putData(ApiLink.complateRequest, data, id: id);

  Future<ApiResult> addEvaluationRequestData(Map data, String id) =>
      crud.putData(ApiLink.addEvaluationRequest, data, id: id);

  Future<ApiResult> deleteRequest(String id) =>
      crud.deleteData(ApiLink.requests, id);
}
