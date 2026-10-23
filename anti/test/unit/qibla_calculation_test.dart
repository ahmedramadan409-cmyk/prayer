import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/constants/egypt_cities.dart';
import '../../lib/core/utils/qibla_math.dart';

void main() {
  group('اختبارات حساب اتجاه القبلة والمسافة للكعبة المشرفة', () {
    test('حساب اتجاه القبلة من القاهرة (يجب أن يكون قرابة 136 درجة)', () {
      final cairo = EgyptCitiesDatabase.findById('cairo');
      final bearing = QiblaMath.calculateQiblaBearing(cairo.latitude, cairo.longitude);

      // في القاهرة، اتجاه القبلة حوالي 136.0 إلى 136.5 درجة
      expect(bearing, inInclusiveRange(135.0, 137.5));

      final distance = QiblaMath.calculateDistanceToKaabaKm(cairo.latitude, cairo.longitude);
      // المسافة الجوية بين القاهرة ومكة المكرمة حوالي 1280 - 1300 كم
      expect(distance, inInclusiveRange(1250.0, 1320.0));
    });

    test('حساب اتجاه القبلة من الإسكندرية وأسوان وشرم الشيخ', () {
      final alex = EgyptCitiesDatabase.findById('alexandria');
      final aswan = EgyptCitiesDatabase.findById('aswan');
      final sharm = EgyptCitiesDatabase.findById('sharm_el_sheikh');

      final alexBearing = QiblaMath.calculateQiblaBearing(alex.latitude, alex.longitude);
      final aswanBearing = QiblaMath.calculateQiblaBearing(aswan.latitude, aswan.longitude);
      final sharmBearing = QiblaMath.calculateQiblaBearing(sharm.latitude, sharm.longitude);

      // الإسكندرية (31.2°N, 29.9°E) => زاوية القبلة 135.4°
      expect(alexBearing, inInclusiveRange(134.5, 136.5));

      // أسوان (جنوب مصر، بمحاذاة مكة شمالاً وجنوباً تقريباً) => زاوية أصغر (حوالي 110° - 114°)
      expect(aswanBearing, inInclusiveRange(108.0, 116.0));

      // شرم الشيخ (في سيناء، أقرب للشرق)
      expect(sharmBearing, inInclusiveRange(138.0, 144.0));
    });

    test('حساب زاوية دوران المؤشر بالنسبة لهاتف المستخدم', () {
      // إذا كانت القبلة عند 136 والهاتف متجه للشمال (0)، يجب أن تكون الزاوية 136
      final angle1 = QiblaMath.calculateNeedleAngle(qiblaBearing: 136.0, compassHeading: 0.0);
      expect(angle1, equals(136.0));

      // إذا كان الهاتف متجه للقبلة تماماً (136)، يجب أن تكون الزاوية 0
      final angle2 = QiblaMath.calculateNeedleAngle(qiblaBearing: 136.0, compassHeading: 136.0);
      expect(angle2, equals(0.0));
    });
  });
}
