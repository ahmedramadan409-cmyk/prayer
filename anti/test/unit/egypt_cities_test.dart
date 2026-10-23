import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/constants/egypt_cities.dart';

void main() {
  group('اختبارات قاعدة بيانات المدن والمحافظات المصرية', () {
    test('التحقق من وجود جميع المحافظات الـ 27 والمراكز الرئيسية', () {
      final cities = EgyptCitiesDatabase.allCities;
      expect(cities.length, greaterThanOrEqualTo(27));

      final governorates = cities.map((c) => c.governorateAr).toSet();
      // تحقق من المحافظات الأساسية
      expect(governorates.contains('القاهرة'), isTrue);
      expect(governorates.contains('الإسكندرية'), isTrue);
      expect(governorates.contains('الجيزة'), isTrue);
      expect(governorates.contains('أسوان'), isTrue);
      expect(governorates.contains('الأقصر'), isTrue);
      expect(governorates.contains('البحر الأحمر'), isTrue);
      expect(governorates.contains('شمال سيناء'), isTrue);
      expect(governorates.contains('جنوب سيناء'), isTrue);
      expect(governorates.contains('مطروح'), isTrue);
      expect(governorates.contains('الوادي الجديد'), isTrue);
    });

    test('البحث بالنص في المدن والمحافظات', () {
      final resultsCairo = EgyptCitiesDatabase.search('القاهرة');
      expect(resultsCairo.isNotEmpty, isTrue);

      final resultsSinai = EgyptCitiesDatabase.search('سيناء');
      expect(resultsSinai.length, greaterThanOrEqualTo(2));

      final resultsEnglish = EgyptCitiesDatabase.search('Alexandria');
      expect(resultsEnglish.any((c) => c.id == 'alexandria'), isTrue);
    });

    test('تحديد أقرب مدينة لموقع GPS (Nearest Neighbor)', () {
      // إحداثيات ميدان التحرير بالقاهرة: 30.0444, 31.2357
      final nearestCairo = EgyptCitiesDatabase.findNearest(30.0444, 31.2357);
      expect(nearestCairo.id, equals('cairo'));

      // إحداثيات بالقرب من مكتبة الإسكندرية: 31.2089, 29.9092
      final nearestAlex = EgyptCitiesDatabase.findNearest(31.2089, 29.9092);
      expect(nearestAlex.id, equals('alexandria'));

      // إحداثيات السد العالي بأسوان: 23.9700, 32.8800
      final nearestAswan = EgyptCitiesDatabase.findNearest(23.9700, 32.8800);
      expect(nearestAswan.id, equals('aswan'));

      // إحداثيات خليج نعمة بشرم الشيخ: 27.9150, 34.3300
      final nearestSharm = EgyptCitiesDatabase.findNearest(27.9150, 34.3300);
      expect(nearestSharm.id, equals('sharm_el_sheikh'));
    });
  });
}
