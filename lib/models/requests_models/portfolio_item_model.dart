import '../../server_config.dart';

/// حالة مكتملة داخل معرض الحالات (بورتفوليو).
class PortfolioItem {
  final String id;
  final String? caseType;
  final String? toothLocation;
  final String? completedAt;
  final String? beforeUrl;
  final String? afterUrl;
  final int? rating; // يظهر فقط ببورتفوليو الطالب

  const PortfolioItem({
    required this.id,
    this.caseType,
    this.toothLocation,
    this.completedAt,
    this.beforeUrl,
    this.afterUrl,
    this.rating,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) => PortfolioItem(
        id: json['_id']?.toString() ?? '',
        caseType: json['case_type']?.toString(),
        toothLocation: json['tooth_location']?.toString(),
        completedAt: json['completed_at']?.toString(),
        beforeUrl: ServerConfig.fixUrl(json['before_url']?.toString()),
        afterUrl: ServerConfig.fixUrl(json['after_url']?.toString()),
        rating: (json['rating'] as num?)?.toInt(),
      );

  /// التاريخ بصيغة yyyy-MM-dd (أو فارغ).
  String get dateLabel {
    final d = completedAt;
    if (d == null || d.length < 10) return '';
    return d.substring(0, 10);
  }
}
