import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/constants/egypt_cities.dart';
import '../../lib/core/utils/prayer_calculation_engine.dart';

void main() {
  group('اختبارات محرك مواقيت الصلاة (الهيئة المصرية العامة للمساحة)', () {
    test('التحقق من صحة مواقيت القاهرة في التوقيت الشتوي (UTC+2)', () {
      final cairo = EgyptCitiesDatabase.findById('cairo');
      final date = DateTime(2026, 1, 15); // يوم شتوي

      final times = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: cairo.latitude,
        longitude: cairo.longitude,
        asrMadhab: AsrMadhab.shafii,
        dstMode: DstMode.alwaysWinterUtc2,
      );

      expect(times.timezoneOffsetHours, equals(2));
      expect(times.isDstActive, isFalse);

      // التحقق من التسلسل المنطقي للصلوات
      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.sunrise.isBefore(times.dhuhr), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);

      // في القاهرة شتاءً: الفجر حوالي 5:20 ص، الظهر حوالي 12:05 م، المغرب حوالي 17:15 م
      expect(times.fajr.hour, inInclusiveRange(4, 6));
      expect(times.dhuhr.hour, equals(12));
      expect(times.maghrib.hour, equals(17));
    });

    test('التحقق من التوقيت الصيفي المصري (UTC+3) والانتقال التلقائي', () {
      final cairo = EgyptCitiesDatabase.findById('cairo');
      final summerDate = DateTime(2026, 7, 15); // يوم صيفي

      final times = EgyptianPrayerCalculator.calculate(
        date: summerDate,
        latitude: cairo.latitude,
        longitude: cairo.longitude,
        asrMadhab: AsrMadhab.shafii,
        dstMode: DstMode.autoEgypt,
      );

      // شهر يوليو يجب أن يكون خاضعاً للتوقيت الصيفي في مصر
      expect(times.timezoneOffsetHours, equals(3));
      expect(times.isDstActive, isTrue);

      // في الصيف الظهر يكون بعد الساعة 12 ظهراً (حوالي 12:55 أو 13:00)
      expect(times.dhuhr.hour, inInclusiveRange(12, 13));
    });

    test('مقارنة التباين الجغرافي بين المحافظات: الإسكندرية وأسوان وشرم الشيخ', () {
      final cairo = EgyptCitiesDatabase.findById('cairo');
      final alex = EgyptCitiesDatabase.findById('alexandria');
      final aswan = EgyptCitiesDatabase.findById('aswan');
      final sharm = EgyptCitiesDatabase.findById('sharm_el_sheikh');

      final date = DateTime(2026, 4, 15);

      final cairoTimes = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: cairo.latitude,
        longitude: cairo.longitude,
      );
      final alexTimes = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: alex.latitude,
        longitude: alex.longitude,
      );
      final aswanTimes = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: aswan.latitude,
        longitude: aswan.longitude,
      );
      final sharmTimes = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: sharm.latitude,
        longitude: sharm.longitude,
      );

      // الإسكندرية تقع غرب القاهرة => يؤذن المغرب فيها بعد القاهرة
      expect(alexTimes.maghrib.isAfter(cairoTimes.maghrib), isTrue);

      // شرم الشيخ تقع شرق القاهرة => يؤذن الفجر والمغرب فيها قبل القاهرة
      expect(sharmTimes.maghrib.isBefore(cairoTimes.maghrib), isTrue);
      expect(sharmTimes.fajr.isBefore(cairoTimes.fajr), isTrue);

      // أسوان في أقصى الجنوب والشرق النسبي
      expect(aswanTimes.fajr.isBefore(alexTimes.fajr), isTrue);
    });

    test('تحديد الصلاة القادمة والوقت المتبقي بشكل صحيح', () {
      final cairo = EgyptCitiesDatabase.findById('cairo');
      final date = DateTime(2026, 5, 10);
      final times = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: cairo.latitude,
        longitude: cairo.longitude,
      );

      // افتراض وقت قبل الفجر
      final beforeFajr = times.fajr.subtract(const Duration(minutes: 30));
      final next1 = times.getNextPrayer(beforeFajr);
      expect(next1.type, equals(PrayerType.fajr));
      expect(next1.remaining.inMinutes, equals(30));

      // افتراض وقت بين الظهر والعصر
      final betweenDhuhrAndAsr = times.dhuhr.add(const Duration(minutes: 45));
      final next2 = times.getNextPrayer(betweenDhuhrAndAsr);
      expect(next2.type, equals(PrayerType.asr));

      // افتراض وقت بعد العشاء
      final afterIsha = times.isha.add(const Duration(hours: 1));
      final next3 = times.getNextPrayer(afterIsha);
      expect(next3.type, equals(PrayerType.fajr)); // الفجر القادم
    });

    test('تطبيق تعديلات الدقائق اليدوية على الصلوات', () {
      final cairo = EgyptCitiesDatabase.findById('cairo');
      final date = DateTime(2026, 6, 1);

      const adjustments = PrayerAdjustments(
        fajr: 2,
        maghrib: -1,
      );

      final normalTimes = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: cairo.latitude,
        longitude: cairo.longitude,
      );

      final adjustedTimes = EgyptianPrayerCalculator.calculate(
        date: date,
        latitude: cairo.latitude,
        longitude: cairo.longitude,
        adjustments: adjustments,
      );

      expect(adjustedTimes.fajr.difference(normalTimes.fajr).inMinutes, equals(2));
      expect(adjustedTimes.maghrib.difference(normalTimes.maghrib).inMinutes, equals(-1));
    });
  });
}
