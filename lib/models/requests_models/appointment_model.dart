import '../../utils/date_format_ar.dart';

/// اقتراح تغيير موعد (من الطالب) بانتظار موافقة المريض.
class PendingChange {
  final DateTime? date;
  final String? reason;

  const PendingChange({this.date, this.reason});

  static PendingChange? tryParse(dynamic json) {
    if (json is! Map) return null;
    final d = parseServerDate(json['date']?.toString());
    if (d == null) return null;
    return PendingChange(date: d, reason: json['reason']?.toString());
  }
}

/// موعد الحالة كما يحدده الطالب.
class AppointmentInfo {
  final DateTime? date; // الموعد الحالي (بتوقيت الجهاز)
  final String? note;
  final String? kind; // initial | review | changed
  final bool needsNext; // بعد تقييم مرحلي: الطالب لم يحدد موعد المراجعة بعد
  final PendingChange? pendingChange;

  const AppointmentInfo({
    this.date,
    this.note,
    this.kind,
    this.needsNext = false,
    this.pendingChange,
  });

  static AppointmentInfo? tryParse(dynamic json) {
    if (json is! Map) return null;
    return AppointmentInfo(
      date: parseServerDate(json['date']?.toString()),
      note: json['note']?.toString(),
      kind: json['kind']?.toString(),
      needsNext: json['needs_next'] == true,
      pendingChange: PendingChange.tryParse(json['pending_change']),
    );
  }

  bool get hasDate => date != null;

  String get kindLabel {
    switch (kind) {
      case 'review':
        return 'موعد مراجعة';
      case 'changed':
        return 'موعد معدّل';
      default:
        return 'موعد المعالجة';
    }
  }
}
