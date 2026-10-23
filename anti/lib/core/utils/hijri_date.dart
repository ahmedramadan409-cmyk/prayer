/// نظام تحويل التقويم الهجري والمناسبات الإسلامية
/// يدعم التعديل اليدوي لرؤية الهلال وفق دار الإفتاء المصرية
class HijriDate {
  final int hYear;
  final int hMonth;
  final int hDay;
  final String monthNameAr;
  final String dayNameAr;

  const HijriDate({
    required this.hYear,
    required this.hMonth,
    required this.hDay,
    required this.monthNameAr,
    required this.dayNameAr,
  });

  static const List<String> hijriMonthNames = [
    'المُحَرَّم',
    'صَفَر',
    'رَبِيع الأوَّل',
    'رَبِيع الآخِر',
    'جُمَادَى الأُولَى',
    'جُمَادَى الآخِرَة',
    'رَجَب',
    'شَعْبَان',
    'رَمَضَان',
    'شَوَّال',
    'ذُو القَعْدَة',
    'ذُو الحِجَّة',
  ];

  static const List<String> arabicDays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  /// تحويل تاريخ ميلادي إلى هجري مع تطبيق تعديل رؤية الهلال بالأيام (-2 إلى +2)
  static HijriDate fromGregorian(DateTime date, {int adjustmentDays = 0}) {
    final adjusted = date.add(Duration(days: adjustmentDays));
    final jd = _gregorianToJulianDay(adjusted.year, adjusted.month, adjusted.day);

    // حساب التاريخ الهجري من اليوم اليولياني
    final l = (jd - 1948440 + 10632).floor();
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    final l3 = l2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final m = ((24 * l3) / 709).floor();
    final d = (l3 - ((709 * m) / 24).floor()).floor();
    final y = (30 * n + j - 30).floor();

    final monthIndex = (m - 1).clamp(0, 11);
    final monthName = hijriMonthNames[monthIndex];
    final dayIndex = (adjusted.weekday - 1).clamp(0, 6);
    final dayName = arabicDays[dayIndex];

    return HijriDate(
      hYear: y,
      hMonth: m,
      hDay: d,
      monthNameAr: monthName,
      dayNameAr: dayName,
    );
  }

  static double _gregorianToJulianDay(int year, int month, int day) {
    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  /// فحص المناسبة الإسلامية المقترنة بهذا اليوم
  String? getIslamicEvent() {
    // المحرم
    if (hMonth == 1 && hDay == 1) return 'رأس السنة الهجرية';
    if (hMonth == 1 && hDay == 9) return 'تاسوعاء';
    if (hMonth == 1 && hDay == 10) return 'يوم عاشوراء';

    // ربيع الأول
    if (hMonth == 3 && hDay == 12) return 'المولد النبوي الشريف';

    // رجب
    if (hMonth == 7 && hDay == 27) return 'ذكرى الإسراء والمعراج';

    // شعبان
    if (hMonth == 8 && hDay == 15) return 'ليلة النصف من شعبان';

    // رمضان
    if (hMonth == 9 && hDay == 1) return 'أول أيام شهر رمضان المبارك';
    if (hMonth == 9 && hDay == 27) return 'ليلة 27 رمضان (ليلة القدر المرجوة)';

    // شوال
    if (hMonth == 10 && hDay == 1) return 'عيد الفطر المبارك (اليوم الأول)';
    if (hMonth == 10 && hDay == 2) return 'عيد الفطر المبارك (اليوم الثاني)';
    if (hMonth == 10 && hDay == 3) return 'عيد الفطر المبارك (اليوم الثالث)';

    // ذو الحجة
    if (hMonth == 12 && hDay == 1) return 'بداية العشر الأوائل من ذي الحجة';
    if (hMonth == 12 && hDay == 9) return 'يوم عرفة (وقفة عيد الأضحى)';
    if (hMonth == 12 && hDay == 10) return 'عيد الأضحى المبارك (اليوم الأول)';
    if (hMonth == 12 && hDay >= 11 && hDay <= 13) return 'أيام التشريق';

    return null;
  }

  String formatFullArabic() {
    return '$dayNameAr، $hDay $monthNameAr $hYear هـ';
  }

  String formatShort() {
    return '$hDay $monthNameAr $hYear هـ';
  }
}
