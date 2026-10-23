import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/hijri_date.dart';

void main() {
  group('اختبارات التقويم الهجري والمناسبات الإسلامية', () {
    test('تحويل تاريخ ميلادي معروف إلى التاريخ الهجري المقابل', () {
      // 10 مارس 2024 م وافق تقريباً نهاية شعبان / غرة رمضان 1445 هـ
      final date = DateTime(2024, 3, 11);
      final hijri = HijriDate.fromGregorian(date);

      expect(hijri.hYear, equals(1445));
      expect(hijri.hMonth, inInclusiveRange(8, 9));
      expect(hijri.monthNameAr.isNotEmpty, isTrue);
      expect(hijri.dayNameAr.isNotEmpty, isTrue);
    });

    test('فحص المناسبات الإسلامية (رأس السنة، عاشوراء، المولد، الأعياد)', () {
      // محاكاة يوم 1 شوال (عيد الفطر)
      final eidDay = _createSpecificHijriDate(1446, 10, 1);
      expect(eidDay.getIslamicEvent(), contains('عيد الفطر'));

      // محاكاة يوم 9 ذو الحجة (يوم عرفة)
      final arafahDay = _createSpecificHijriDate(1446, 12, 9);
      expect(arafahDay.getIslamicEvent(), contains('يوم عرفة'));

      // محاكاة 12 ربيع الأول (المولد النبوي)
      final mawlidDay = _createSpecificHijriDate(1446, 3, 12);
      expect(mawlidDay.getIslamicEvent(), contains('المولد النبوي'));

      // محاكاة 10 محرم (عاشوراء)
      final ashuraDay = _createSpecificHijriDate(1446, 1, 10);
      expect(ashuraDay.getIslamicEvent(), contains('عاشوراء'));
    });

    test('تطبيق تعديل رؤية الهلال بالأيام (+/-)', () {
      final baseDate = DateTime(2026, 4, 15);
      final standard = HijriDate.fromGregorian(baseDate, adjustmentDays: 0);
      final plusOne = HijriDate.fromGregorian(baseDate, adjustmentDays: 1);
      final minusOne = HijriDate.fromGregorian(baseDate, adjustmentDays: -1);

      expect(plusOne.hDay != standard.hDay || plusOne.hMonth != standard.hMonth, isTrue);
      expect(minusOne.hDay != standard.hDay || minusOne.hMonth != standard.hMonth, isTrue);
    });
  });
}

HijriDate _createSpecificHijriDate(int y, int m, int d) {
  return HijriDate(
    hYear: y,
    hMonth: m,
    hDay: d,
    monthNameAr: HijriDate.hijriMonthNames[m - 1],
    dayNameAr: 'الجمعة',
  );
}
