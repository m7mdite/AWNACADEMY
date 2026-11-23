/// تنسيق التواريخ والأوقات بالعربية (بدون الحاجة لحزمة intl).

const List<String> _arDays = [
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

/// يحول نص التاريخ القادم من السيرفر (ISO) إلى توقيت الجهاز. يرجع null إذا غير صالح.
DateTime? parseServerDate(String? s) {
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s)?.toLocal();
}

/// مثال: الأحد 22/11/2026
String formatDateAr(DateTime d) =>
    '${_arDays[d.weekday - 1]} ${d.day}/${d.month}/${d.year}';

/// مثال: 9:30 ص
String formatTimeAr(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final p = d.hour < 12 ? 'ص' : 'م';
  return '$h12:$m $p';
}

/// مثال: الأحد 22/11/2026 - 9:30 ص
String formatDateTimeAr(DateTime d) => '${formatDateAr(d)} - ${formatTimeAr(d)}';

/// نسخة قصيرة للكروت: 22/11 - 9:30 ص
String formatShortDateTimeAr(DateTime d) =>
    '${d.day}/${d.month} - ${formatTimeAr(d)}';
