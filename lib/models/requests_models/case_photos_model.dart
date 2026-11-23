import '../../server_config.dart';

/// صورة واحدة من صور الحالة (قبل أو بعد المعالجة).
class CasePhoto {
  final String url;
  final String? role; // patient | student | overseer
  final String? uploadedAt;

  const CasePhoto({required this.url, this.role, this.uploadedAt});

  /// يرجع null إذا ما في صورة صالحة.
  static CasePhoto? tryParse(dynamic json) {
    if (json is! Map) return null;
    final url = ServerConfig.fixUrl(json['url']?.toString());
    if (url == null || url.isEmpty) return null;
    return CasePhoto(
      url: url,
      role: json['role']?.toString(),
      uploadedAt: json['uploaded_at']?.toString(),
    );
  }
}

/// صورتا الحالة: قبل وبعد المعالجة.
class CasePhotos {
  CasePhoto? before;
  CasePhoto? after;

  CasePhotos({this.before, this.after});

  bool get hasBefore => before != null;
  bool get hasAfter => after != null;

  factory CasePhotos.fromJson(Map json) => CasePhotos(
        before: CasePhoto.tryParse(json['before']),
        after: CasePhoto.tryParse(json['after']),
      );
}

/// طلب المشرف من الطالب إعادة تصوير صورة.
class RetakeRequest {
  final String which; // before | after
  final String? note;
  final String? date;

  const RetakeRequest({required this.which, this.note, this.date});

  static RetakeRequest? tryParse(dynamic json) {
    if (json is! Map) return null;
    final which = json['which']?.toString();
    if (which != 'before' && which != 'after') return null;
    return RetakeRequest(
      which: which!,
      note: json['note']?.toString(),
      date: json['date']?.toString(),
    );
  }

  String get whichLabel => which == 'before' ? 'قبل المعالجة' : 'بعد المعالجة';
}

/// نتيجة رفع صورة (الصور المحدثة + حالة طلب إعادة التصوير).
class CasePhotosUpdate {
  final CasePhotos photos;
  final RetakeRequest? retake;

  const CasePhotosUpdate({required this.photos, this.retake});
}
