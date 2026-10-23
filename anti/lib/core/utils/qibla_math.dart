import 'dart:math' as math;

/// حساب اتجاه ومسافة القبلة المشرفة بدقة فلكية
class QiblaMath {
  // إحداثيات الكعبة المشرفة بدقة عالية
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;
  static const double earthRadiusKm = 6371.0;

  /// حساب اتجاه القبلة بالنسبة للشمال الحقيقي بالدرجات (0 - 360)
  static double calculateQiblaBearing(double userLat, double userLng) {
    final userLatRad = _degToRad(userLat);
    final userLngRad = _degToRad(userLng);
    final kaabaLatRad = _degToRad(kaabaLatitude);
    final kaabaLngRad = _degToRad(kaabaLongitude);

    final dLng = kaabaLngRad - userLngRad;

    final y = math.sin(dLng);
    final x = math.cos(userLatRad) * math.tan(kaabaLatRad) -
        math.sin(userLatRad) * math.cos(dLng);

    var qiblaRad = math.atan2(y, x);
    var qiblaDeg = _radToDeg(qiblaRad);

    return (qiblaDeg + 360.0) % 360.0;
  }

  /// حساب المسافة بالكيلومتر بين موقع المستخدم والكعبة المشرفة (قانون هافرسين)
  static double calculateDistanceToKaabaKm(double userLat, double userLng) {
    final lat1 = _degToRad(userLat);
    final lon1 = _degToRad(userLng);
    final lat2 = _degToRad(kaabaLatitude);
    final lon2 = _degToRad(kaabaLongitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// حساب زاوية دوران مؤشر القبلة بالنسبة لاتجاه الهاتف (البوصلة)
  static double calculateNeedleAngle({
    required double qiblaBearing,
    required double compassHeading,
  }) {
    var angle = qiblaBearing - compassHeading;
    while (angle > 180) angle -= 360;
    while (angle < -180) angle += 360;
    return angle;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
