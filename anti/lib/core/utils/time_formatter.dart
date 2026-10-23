import 'package:intl/intl.dart';

class TimeFormatter {
  /// تنسيق الوقت إما بنظام 12 ساعة (ص / م) أو بنظام 24 ساعة
  static String formatPrayerTime(DateTime time, {bool is24Hours = false}) {
    if (is24Hours) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      var hour = time.hour % 12;
      if (hour == 0) hour = 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'م' : 'ص';
      return '$hour:$minute $period';
    }
  }

  /// تنسيق المدة المتبقية (ساعات:دقائق:ثواني)
  static String formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// تنسيق التاريخ الميلادي بالعربية
  static String formatGregorian(DateTime date) {
    const monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${monthsAr[date.month - 1]} ${date.year} م';
  }
}
