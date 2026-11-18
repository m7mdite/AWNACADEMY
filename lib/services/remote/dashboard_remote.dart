import 'crud.dart';
import '../../api_link.dart';

class DashboardRemote {
  final Crud crud;
  DashboardRemote(this.crud);

  Future<ApiResult> getDashboard() => crud.getData(ApiLink.dashboard);
}
