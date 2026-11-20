int _i(dynamic v) => v is num ? v.toInt() : 0;
double? _d(dynamic v) => v is num ? v.toDouble() : null;
Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<dynamic> _l(dynamic v) => v is List ? v : const [];

class AdminStats {
  final StatsUsers users;
  final StatsRequests requests;
  final double? avgRating;
  final double? avgDays;
  final List<WeekPoint> weekly;
  final List<NamedCount> topTreatments;
  final List<StudentStat> topStudents;
  final List<OverseerStat> overseerLoad;
  final StatsAttention attention;
  final DateTime? generatedAt;

  AdminStats({
    required this.users,
    required this.requests,
    required this.avgRating,
    required this.avgDays,
    required this.weekly,
    required this.topTreatments,
    required this.topStudents,
    required this.overseerLoad,
    required this.attention,
    required this.generatedAt,
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) {
    final perf = _m(j['performance']);
    return AdminStats(
      users: StatsUsers.fromJson(_m(j['users'])),
      requests: StatsRequests.fromJson(_m(j['requests'])),
      avgRating: _d(perf['avgRating']),
      avgDays: _d(perf['avgDays']),
      weekly: _l(j['weekly']).map((e) => WeekPoint.fromJson(_m(e))).toList(),
      topTreatments:
          _l(j['topTreatments']).map((e) => NamedCount.fromJson(_m(e))).toList(),
      topStudents:
          _l(j['topStudents']).map((e) => StudentStat.fromJson(_m(e))).toList(),
      overseerLoad:
          _l(j['overseerLoad']).map((e) => OverseerStat.fromJson(_m(e))).toList(),
      attention: StatsAttention.fromJson(_m(j['attention'])),
      generatedAt: DateTime.tryParse('${j['generatedAt'] ?? ''}')?.toLocal(),
    );
  }
}

class StatsUsers {
  final int patients, students, verifiedStudents, overseers, admins;
  StatsUsers(this.patients, this.students, this.verifiedStudents,
      this.overseers, this.admins);
  factory StatsUsers.fromJson(Map<String, dynamic> j) => StatsUsers(
        _i(j['patients']),
        _i(j['students']),
        _i(j['verifiedStudents']),
        _i(j['overseers']),
        _i(j['admins']),
      );
}

class StatsRequests {
  final int total, pending, processing, finished, rejected;
  final double completionRate, rejectionRate;
  StatsRequests(this.total, this.pending, this.processing, this.finished,
      this.rejected, this.completionRate, this.rejectionRate);
  factory StatsRequests.fromJson(Map<String, dynamic> j) => StatsRequests(
        _i(j['total']),
        _i(j['pending']),
        _i(j['processing']),
        _i(j['finished']),
        _i(j['rejected']),
        _d(j['completionRate']) ?? 0,
        _d(j['rejectionRate']) ?? 0,
      );
}

class WeekPoint {
  final DateTime? weekStart;
  final int newRequests, completed;
  WeekPoint(this.weekStart, this.newRequests, this.completed);
  factory WeekPoint.fromJson(Map<String, dynamic> j) => WeekPoint(
        DateTime.tryParse('${j['weekStart'] ?? ''}')?.toLocal(),
        _i(j['newRequests']),
        _i(j['completed']),
      );
}

class NamedCount {
  final String name;
  final int count;
  NamedCount(this.name, this.count);
  factory NamedCount.fromJson(Map<String, dynamic> j) =>
      NamedCount('${j['name'] ?? ''}', _i(j['count']));
}

class StudentStat {
  final String name;
  final int finished;
  final double? avgRating;
  StudentStat(this.name, this.finished, this.avgRating);
  factory StudentStat.fromJson(Map<String, dynamic> j) => StudentStat(
      '${j['name'] ?? ''}', _i(j['finished']), _d(j['avgRating']));
}

class OverseerStat {
  final String name;
  final int processing, finished;
  OverseerStat(this.name, this.processing, this.finished);
  factory OverseerStat.fromJson(Map<String, dynamic> j) => OverseerStat(
      '${j['name'] ?? ''}', _i(j['processing']), _i(j['finished']));
}

class StatsAttention {
  final int pendingRequests, pendingVerifications, pendingReports, pendingPosts;
  StatsAttention(this.pendingRequests, this.pendingVerifications,
      this.pendingReports, this.pendingPosts);
  factory StatsAttention.fromJson(Map<String, dynamic> j) => StatsAttention(
        _i(j['pendingRequests']),
        _i(j['pendingVerifications']),
        _i(j['pendingReports']),
        _i(j['pendingPosts']),
      );
}
