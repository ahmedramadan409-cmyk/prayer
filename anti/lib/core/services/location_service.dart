import 'package:geolocator/geolocator.dart';
import '../constants/egypt_cities.dart';

class LocationService {
  /// التحقق من صلاحيات الموقع الجغرافي وطلبها بأمان
  static Future<EgyptianCity?> detectEgyptianCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. التحقق من تفعيل خدمة الموقع في الهاتف
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // 2. التحقق من إذن التطبيق
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // 3. الحصول على الإحداثيات الحالية بدقة مقبولة
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      // 4. مطابقة الإحداثيات مع أقرب مدينة أو محافظة مصرية
      return EgyptCitiesDatabase.findNearest(
        position.latitude,
        position.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}
