import 'server_config.dart';

class ApiLink {
  // ===== العنوان الأساسي (يتغير وقت التشغيل من شاشة الإعداد) =====
  static String get servere => '${ServerConfig.baseUrl}/api';
  static String get kSocketBaseUrl => ServerConfig.baseUrl;

  /// للتوافق مع الموديلات اللي تستدعي ApiLink.fixUrl
  static String? fixUrl(String? url) => ServerConfig.fixUrl(url);

  static String get aiChat => '$servere/ai/chat';
  static String get aiHistory => '$servere/ai/history';

  // ========================auth
  static String get login => '$servere/auth/login';
  static String get register => '$servere/auth/register';
  static String get logout => '$servere/auth/logout';

  // ===========================all user
  static String get profile => '$servere/profile';
  static String get photo => '$servere/users/photo';
  static String get conversations => '$servere/conversations';
  static String get getOtherProfile => '$servere/users';
  static String get report => '$servere/reports';
  static String get supportMessage => '$servere/support';
  static String get requests => '$servere/request';
  static String get posts => '$servere/posts';
  static String get getPendingPosts => '$servere/posts/pending';
  static String get comments => '$servere/posts/comments';
  static String get changePassword => '$servere/auth/change-password';
  static String get dashboard => '$servere/dashboard';

  // =========================== patient
  static String get treatments => '$servere/admin/treatment';

  // =========================== student
  static String get acceptRequest => '$servere/request/accept';
  static String get dunningOverseer => '$servere/request/reassign-overseer';
  static String get verify => '$servere/auth/verify';
  static String get getOverSeerForCourse => '$servere/request/course-overseers';

  // =========================== requests
  static String get getPendingRequest => '$servere/request/pending';
  static String get getCompletedRequests => '$servere/request/finished';
  static String get getRejectedRequests => '$servere/request/rejected';
  static String get getProcessingRequests => '$servere/request/processing';

  // =========================== ml
  static String get predictTreatment => '$servere/ml/predict';
  static String get predictCaseType =>
      '$servere/treatment-ml/predict-with-image';

  // ================================================= overseer
  static String get treatmentRequestsForOverseer =>
      '$servere/overseer/treatment';
  static String get rejectRequest => '$servere/overseer/treatment/reject';
  static String get changeCaseRequest => '$servere/overseer/treatment/reject';
  static String get complateRequest => '$servere/overseer/treatment/complete';
  static String get addEvaluationRequest =>
      '$servere/overseer/add-evaluation';

  // =========================== admin
  static String get addOverSeer => '$servere/admin/overseer';
  static String get getAllOverSeers => '$servere/admin/overseers';
  static String get getAllStudents => '$servere/admin/students';
  static String get getAllPatientes => '$servere/admin/patients';
  static String get getAllRequests => '$servere/admin/requests';
  static String get getAllVerifyStudents => '$servere/admin/verify';
  static String get acceptVerifyStudent => '$servere/admin/verify/accept';
  static String get rejectVerifyStudent => '$servere/admin/verify/reject';
  static String get addCourse => '$servere/admin/course';
  static String get addTreatment => '$servere/admin/treatment';
  static String get addCategory => '$servere/admin/category';
  static String get weeklySchedule => '$servere/admin/practical-lessons';
  static String get getAllCourses => '$servere/admin/course';
  static String get getAllTreatments => '$servere/admin/treatment';
  static String get getAllCategory => '$servere/admin/category';
  static String get advertisements => '$servere/advertisements';
  static String get adminReports => '$servere/reports';
  static String reviewReport(String id) => '$servere/reports/$id';
  static String get deleteOverSeer => '$servere/admin/overseer/delete';
  static String get notifyAll => '$servere/admin/notify';
  static String get categories => '$servere/admin/categories';
  static String get acceptPendingPosts => '$servere/posts/pending/accept';
  static String get reassignOverseer => '$servere/request/reassign-overseer';
  static String get courseOverseers => '$servere/request/course-overseers';
  static String get adminStats => '$servere/admin/stats';
}