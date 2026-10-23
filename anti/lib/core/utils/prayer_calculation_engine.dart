import 'dart:math' as math;

/// إعدادات طريقة الحساب
enum AsrMadhab {
  shafii, // الشافعي والمالكي والحنبلي (ظل المثل = 1) - المعتمد رسمياً في مصر
  hanafi, // الحنفي (ظل المثلين = 2)
}

enum DstMode {
  autoEgypt, // تحديد تلقائي وفق القانون المصري (آخر جمعة من أبريل إلى آخر خميس من أكتوبر)
  alwaysWinterUtc2, // توقيت شتوي دائماً (UTC+2)
  alwaysSummerUtc3, // توقيت صيفي دائماً (UTC+3)
}

/// نموذج مواقيت الصلاة ليوم واحد
class CalculatedPrayerTimes {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final int timezoneOffsetHours;
  final bool isDstActive;

  const CalculatedPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.timezoneOffsetHours,
    required this.isDstActive,
  });

  Map<String, DateTime> toMap() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  /// تحديد الصلاة القادمة بالنسبة لوقت معين (أو الوقت الحالي)
  PrayerTimeSlot getNextPrayer([DateTime? now]) {
    final current = now ?? DateTime.now();

    if (current.isBefore(fajr)) {
      return PrayerTimeSlot(
        nameAr: 'الفجر',
        time: fajr,
        type: PrayerType.fajr,
        remaining: fajr.difference(current),
      );
    } else if (current.isBefore(sunrise)) {
      return PrayerTimeSlot(
        nameAr: 'الشروق',
        time: sunrise,
        type: PrayerType.sunrise,
        remaining: sunrise.difference(current),
      );
    } else if (current.isBefore(dhuhr)) {
      return PrayerTimeSlot(
        nameAr: 'الظهر',
        time: dhuhr,
        type: PrayerType.dhuhr,
        remaining: dhuhr.difference(current),
      );
    } else if (current.isBefore(asr)) {
      return PrayerTimeSlot(
        nameAr: 'العصر',
        time: asr,
        type: PrayerType.asr,
        remaining: asr.difference(current),
      );
    } else if (current.isBefore(maghrib)) {
      return PrayerTimeSlot(
        nameAr: 'المغرب',
        time: maghrib,
        type: PrayerType.maghrib,
        remaining: maghrib.difference(current),
      );
    } else if (current.isBefore(isha)) {
      return PrayerTimeSlot(
        nameAr: 'العشاء',
        time: isha,
        type: PrayerType.isha,
        remaining: isha.difference(current),
      );
    } else {
      // بعد العشاء، الصلاة القادمة هي فجر اليوم التالي
      final tomorrowFajr = fajr.add(const Duration(days: 1));
      return PrayerTimeSlot(
        nameAr: 'الفجر',
        time: tomorrowFajr,
        type: PrayerType.fajr,
        remaining: tomorrowFajr.difference(current),
      );
    }
  }

  /// الصلاة الحالية
  PrayerType getCurrentPrayer([DateTime? now]) {
    final current = now ?? DateTime.now();
    if (current.isBefore(fajr)) return PrayerType.isha;
    if (current.isBefore(sunrise)) return PrayerType.fajr;
    if (current.isBefore(dhuhr)) return PrayerType.sunrise;
    if (current.isBefore(asr)) return PrayerType.dhuhr;
    if (current.isBefore(maghrib)) return PrayerType.asr;
    if (current.isBefore(isha)) return PrayerType.maghrib;
    return PrayerType.isha;
  }
}

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

class PrayerTimeSlot {
  final String nameAr;
  final DateTime time;
  final PrayerType type;
  final Duration remaining;

  const PrayerTimeSlot({
    required this.nameAr,
    required this.time,
    required this.type,
    required this.remaining,
  });
}

/// تعديلات الدقائق المخصصة لكل صلاة
class PrayerAdjustments {
  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const PrayerAdjustments({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  Map<String, dynamic> toJson() => {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

  factory PrayerAdjustments.fromJson(Map<String, dynamic> json) =>
      PrayerAdjustments(
        fajr: json['fajr'] ?? 0,
        sunrise: json['sunrise'] ?? 0,
        dhuhr: json['dhuhr'] ?? 0,
        asr: json['asr'] ?? 0,
        maghrib: json['maghrib'] ?? 0,
        isha: json['isha'] ?? 0,
      );
}

/// محرك الحساب الفلكي لمواقيت الصلاة
/// مطابق تماماً لمعايير الهيئة المصرية العامة للمساحة:
/// - الفجر: زاوية انخفاض الشمس 19.5 درجة تحت الأفق
/// - الشروق والغروب: انخفاض مركز الشمس 50 دقيقة قوسية (0.8333 درجة)
/// - الظهر: زوال الشمس + دقيقة احتياطية (احتياط الزوال الشرعي)
/// - العصر: المذهب الشافعي (ظل المثل = 1)
/// - المغرب: الغروب الظاهري + دقيقتان احتياط الغروب
/// - العشاء: زاوية انخفاض الشمس 17.5 درجة تحت الأفق
class EgyptianPrayerCalculator {
  static const double fajrAngle = 19.5;
  static const double ishaAngle = 17.5;
  static const double sunRefractionSunRadiusAngle = 0.8333333; // 50 دقيقة قوسية

  /// التحقق من التوقيت الصيفي المصري وفق القانون 24 لسنة 2023:
  /// يبدأ: الجمعة الأخيرة من شهر أبريل (الساعة 00:00)
  /// ينتهي: الخميس الأخير من شهر أكتوبر (الساعة 24:00 / 00:00 الجمعة)
  static bool isEgyptianDst(DateTime date) {
    final year = date.year;

    // إيجاد آخر جمعة من أبريل
    DateTime lastFridayApril = DateTime(year, 4, 30);
    while (lastFridayApril.weekday != DateTime.friday) {
      lastFridayApril = lastFridayApril.subtract(const Duration(days: 1));
    }
    final dstStart = DateTime(year, 4, lastFridayApril.day, 0, 0, 0);

    // إيجاد آخر خميس من أكتوبر (حتى نهاية ذلك اليوم 23:59:59)
    DateTime lastThursdayOctober = DateTime(year, 10, 31);
    while (lastThursdayOctober.weekday != DateTime.thursday) {
      lastThursdayOctober = lastThursdayOctober.subtract(const Duration(days: 1));
    }
    final dstEnd = DateTime(year, 10, lastThursdayOctober.day, 23, 59, 59);

    return date.isAfter(dstStart) && date.isBefore(dstEnd);
  }

  /// حساب فارق التوقيت عن UTC بالساعات لمصر
  static int resolveTimezone(DateTime date, DstMode dstMode) {
    switch (dstMode) {
      case DstMode.alwaysWinterUtc2:
        return 2;
      case DstMode.alwaysSummerUtc3:
        return 3;
      case DstMode.autoEgypt:
        return isEgyptianDst(date) ? 3 : 2;
    }
  }

  /// الحساب الرئيسي لمواقيت الصلاة ليوم وموقع محددين
  static CalculatedPrayerTimes calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
    AsrMadhab asrMadhab = AsrMadhab.shafii,
    DstMode dstMode = DstMode.autoEgypt,
    PrayerAdjustments adjustments = const PrayerAdjustments(),
  }) {
    final tzHours = resolveTimezone(date, dstMode);
    final isDst = tzHours == 3;

    // 1. حساب اليوم اليولياني عند منتصف النهار UTC
    final jd = _julianDay(date.year, date.month, date.day);

    // 2. العناصر الفلكية للشمس
    final sunCoords = _calculateSunCoordinates(jd);
    final declination = sunCoords.declination;
    final eqOfTime = sunCoords.equationOfTime; // بالدقائق

    // 3. وقت زوال الشمس (الظهر الفلكي) بالساعات
    // Noon = 12 + Timezone - Longitude/15 - EquationOfTime/60
    final solarNoonHours = 12.0 + tzHours - (longitude / 15.0) - (eqOfTime / 60.0);

    // الظهر الرسمي في مصر: زوال الشمس + دقيقة احتياطية شرعية
    final dhuhrHours = solarNoonHours + (1.0 / 60.0);

    // 4. زاوية الساعة للشروق والغروب (ارتفاع الشمس = -0.8333 درجة)
    final sunriseHourAngle = _hourAngle(latitude, declination, -sunRefractionSunRadiusAngle);
    final sunriseHours = solarNoonHours - (sunriseHourAngle / 15.0);
    // المغرب الرسمي: الغروب الفلكي + دقيقتان احتياطية
    final sunsetHours = solarNoonHours + (sunriseHourAngle / 15.0);
    final maghribHours = sunsetHours + (2.0 / 60.0);

    // 5. الفجر (انخفاض 19.5 درجة)
    final fajrHourAngle = _hourAngle(latitude, declination, -fajrAngle);
    final fajrHours = solarNoonHours - (fajrHourAngle / 15.0);

    // 6. العشاء (انخفاض 17.5 درجة)
    final ishaHourAngle = _hourAngle(latitude, declination, -ishaAngle);
    final ishaHours = solarNoonHours + (ishaHourAngle / 15.0);

    // 7. العصر: حساب ارتفاع الشمس عند ظل المثل (أو المثلين)
    final shadowFactor = (asrMadhab == AsrMadhab.shafii) ? 1.0 : 2.0;
    final latRad = _degToRad(latitude);
    final decRad = _degToRad(declination);
    final asrAltitudeRad = _arccot(shadowFactor + math.tan((latRad - decRad).abs()));
    final asrAltitudeDeg = _radToDeg(asrAltitudeRad);
    final asrHourAngle = _hourAngle(latitude, declination, asrAltitudeDeg);
    final asrHours = solarNoonHours + (asrHourAngle / 15.0);

    // تحويل الساعات الكسرية إلى أوقات DateTime دقيقة
    DateTime fajrTime = _hoursToDateTime(date, fajrHours, adjustments.fajr);
    DateTime sunriseTime = _hoursToDateTime(date, sunriseHours, adjustments.sunrise);
    DateTime dhuhrTime = _hoursToDateTime(date, dhuhrHours, adjustments.dhuhr);
    DateTime asrTime = _hoursToDateTime(date, asrHours, adjustments.asr);
    DateTime maghribTime = _hoursToDateTime(date, maghribHours, adjustments.maghrib);
    DateTime ishaTime = _hoursToDateTime(date, ishaHours, adjustments.isha);

    return CalculatedPrayerTimes(
      date: date,
      fajr: fajrTime,
      sunrise: sunriseTime,
      dhuhr: dhuhrTime,
      asr: asrTime,
      maghrib: maghribTime,
      isha: ishaTime,
      timezoneOffsetHours: tzHours,
      isDstActive: isDst,
    );
  }

  // --- دوال فلكية مساعدة ---

  static double _julianDay(int year, int month, int day) {
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

  static _SunCoordinates _calculateSunCoordinates(double jd) {
    final d = jd - 2451545.0; // الأيام منذ J2000.0
    final t = d / 36525.0; // القرون اليوليانية

    // متوسط خط طول الشمس
    var l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    l0 = _fixAngle(l0);

    // متوسط الشذوذ المداري
    var m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
    m = _fixAngle(m);
    final mRad = _degToRad(m);

    // معادلة المركز
    final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(mRad) +
        (0.019993 - 0.000101 * t) * math.sin(2 * mRad) +
        0.000289 * math.sin(3 * mRad);

    // خط طول الشمس الحقيقي
    var sunTrueLon = l0 + c;
    sunTrueLon = _fixAngle(sunTrueLon);
    final sunTrueLonRad = _degToRad(sunTrueLon);

    // ميل دائرة البروج
    final eps0 = 23.439291 - 0.0130042 * t;
    final epsRad = _degToRad(eps0);

    // المطلع المستقيم والميل الاستوائي للشمس
    final declinationRad = math.asin(math.sin(epsRad) * math.sin(sunTrueLonRad));
    final declination = _radToDeg(declinationRad);

    final rightAscensionRad = math.atan2(
      math.cos(epsRad) * math.sin(sunTrueLonRad),
      math.cos(sunTrueLonRad),
    );
    var rightAscension = _fixAngle(_radToDeg(rightAscensionRad));

    // معادلة الزمن بالدقائق
    // Equation of time: الفرق بين الوقت الشمسي الظاهري والوقت الشمسي المتوسط
    var eqTimeDeg = l0 - rightAscension;
    if (eqTimeDeg > 180.0) eqTimeDeg -= 360.0;
    if (eqTimeDeg < -180.0) eqTimeDeg += 360.0;
    final equationOfTimeMinutes = eqTimeDeg * 4.0; // كل درجة تساوي 4 دقائق

    return _SunCoordinates(
      declination: declination,
      equationOfTime: equationOfTimeMinutes,
    );
  }

  /// زاوية الساعة المقابلة لارتفاع محدد للشمس
  static double _hourAngle(double latitude, double declination, double altitude) {
    final latRad = _degToRad(latitude);
    final decRad = _degToRad(declination);
    final altRad = _degToRad(altitude);

    final cosH = (math.sin(altRad) - math.sin(latRad) * math.sin(decRad)) /
        (math.cos(latRad) * math.cos(decRad));

    if (cosH > 1.0) return 0.0; // الشمس لا تشرق
    if (cosH < -1.0) return 180.0; // الشمس لا تغرب

    return _radToDeg(math.acos(cosH));
  }

  static DateTime _hoursToDateTime(DateTime date, double hours, int minuteAdjustment) {
    final totalMinutes = (hours * 60.0).round() + minuteAdjustment;
    var h = (totalMinutes ~/ 60);
    var m = (totalMinutes % 60);

    // ضبط حالة تجاوز اليوم
    var dayOffset = 0;
    if (h >= 24) {
      dayOffset = h ~/ 24;
      h = h % 24;
    } else if (h < 0) {
      dayOffset = (h ~/ 24) - 1;
      h = (h % 24 + 24) % 24;
    }

    final adjustedDate = date.add(Duration(days: dayOffset));
    return DateTime(
      adjustedDate.year,
      adjustedDate.month,
      adjustedDate.day,
      h,
      m,
      0,
    );
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
  static double _arccot(double x) => (math.pi / 2.0) - math.atan(x);
  static double _fixAngle(double a) {
    var angle = a - 360.0 * (a / 360.0).floor();
    return angle < 0 ? angle + 360.0 : angle;
  }
}

class _SunCoordinates {
  final double declination;
  final double equationOfTime;

  const _SunCoordinates({
    required this.declination,
    required this.equationOfTime,
  });
}
