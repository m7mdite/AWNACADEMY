import '../../utils/date_format_ar.dart';

String moderationActionLabel(String? action) {
  switch (action) {
    case 'warn':
      return 'تحذير';
    case 'suspend':
      return 'إيقاف مؤقت';
    case 'ban':
      return 'حظر';
    case 'reactivate':
      return 'رفع الإيقاف/الحظر';
    default:
      return action ?? '';
  }
}

String accountStatusLabel(String? status) {
  switch (status) {
    case 'suspended':
      return 'موقوف مؤقتاً';
    case 'banned':
      return 'محظور';
    default:
      return 'نشط';
  }
}

class ModerationActionItem {
  final String id;
  final String action;
  final String? reason;
  final int? days;
  final DateTime? createdAt;

  const ModerationActionItem({
    required this.id,
    required this.action,
    this.reason,
    this.days,
    this.createdAt,
  });

  factory ModerationActionItem.fromJson(Map<String, dynamic> json) =>
      ModerationActionItem(
        id: json['_id']?.toString() ?? '',
        action: json['action']?.toString() ?? '',
        reason: json['reason']?.toString(),
        days: (json['days'] as num?)?.toInt(),
        createdAt: parseServerDate(json['created_at']?.toString()),
      );
}

/// حالة حساب مستخدم + سجله (GET /admin/users/:id/moderation).
class ModerationInfo {
  final String name;
  final String role;
  final bool isAdmin;
  final String accountStatus; // active | suspended | banned
  final DateTime? suspendedUntil;
  final String? banReason;
  final int warningsCount;
  final int openReports;
  final int activeCases;
  final List<ModerationActionItem> recentActions;

  const ModerationInfo({
    required this.name,
    required this.role,
    required this.isAdmin,
    required this.accountStatus,
    this.suspendedUntil,
    this.banReason,
    this.warningsCount = 0,
    this.openReports = 0,
    this.activeCases = 0,
    this.recentActions = const [],
  });

  bool get isBlocked => accountStatus != 'active';

  factory ModerationInfo.fromJson(Map<String, dynamic> json) {
    final actions = json['recent_actions'];
    return ModerationInfo(
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isAdmin: json['is_admin'] == true,
      accountStatus: json['account_status']?.toString() ?? 'active',
      suspendedUntil: parseServerDate(json['suspended_until']?.toString()),
      banReason: json['ban_reason']?.toString(),
      warningsCount: (json['warnings_count'] as num?)?.toInt() ?? 0,
      openReports: (json['open_reports'] as num?)?.toInt() ?? 0,
      activeCases: (json['active_cases'] as num?)?.toInt() ?? 0,
      recentActions: actions is List
          ? actions
              .whereType<Map>()
              .map((e) => ModerationActionItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

/// نتيجة تنفيذ إجراء.
class ModerationResult {
  final String status;
  final String role;
  final int affectedCases;
  final int unassignedCases;

  const ModerationResult({
    required this.status,
    required this.role,
    this.affectedCases = 0,
    this.unassignedCases = 0,
  });

  factory ModerationResult.fromJson(Map<String, dynamic> json) => ModerationResult(
        status: json['status']?.toString() ?? 'active',
        role: json['role']?.toString() ?? '',
        affectedCases: (json['affected_cases'] as num?)?.toInt() ?? 0,
        unassignedCases: (json['unassigned_cases'] as num?)?.toInt() ?? 0,
      );
}

/// عنصر من سجل إجراءات الأدمن.
class AdminActionLogItem {
  final String id;
  final String action;
  final String? reason;
  final int? days;
  final int affectedCases;
  final DateTime? createdAt;
  final String adminName;
  final String targetName;
  final String? targetRole;

  const AdminActionLogItem({
    required this.id,
    required this.action,
    this.reason,
    this.days,
    this.affectedCases = 0,
    this.createdAt,
    this.adminName = '',
    this.targetName = '',
    this.targetRole,
  });

  factory AdminActionLogItem.fromJson(Map<String, dynamic> json) => AdminActionLogItem(
        id: json['_id']?.toString() ?? '',
        action: json['action']?.toString() ?? '',
        reason: json['reason']?.toString(),
        days: (json['days'] as num?)?.toInt(),
        affectedCases: (json['affected_cases'] as num?)?.toInt() ?? 0,
        createdAt: parseServerDate(json['created_at']?.toString()),
        adminName: json['admin_name']?.toString() ?? '',
        targetName: json['target_name']?.toString() ?? '',
        targetRole: json['target_role']?.toString(),
      );
}
