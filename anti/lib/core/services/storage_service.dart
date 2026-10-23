import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/prayer_calculation_engine.dart';

/// خدمة التخزين المحلي الدائم للإعدادات والمواقيت بدون إنترنت
class StorageService {
  static const String _keyCityId = 'salaty_city_id';
  static const String _keyUseAutoLocation = 'salaty_use_auto_location';
  static const String _keyCustomLat = 'salaty_custom_lat';
  static const String _keyCustomLng = 'salaty_custom_lng';
  static const String _keyMadhab = 'salaty_madhab';
  static const String _keyDstMode = 'salaty_dst_mode';
  static const String _keyIs24Hours = 'salaty_is_24_hours';
  static const String _keyHijriOffset = 'salaty_hijri_offset';
  static const String _keyAdjustments = 'salaty_adjustments';
  static const String _keyThemeMode = 'salaty_theme_mode'; // 'system', 'light', 'dark'
  static const String _keyAdhanSoundType = 'salaty_adhan_sound_type';
  static const String _keyNotificationSettings = 'salaty_notifications_settings';
  static const String _keyPreReminderMinutes = 'salaty_pre_reminder_minutes';
  static const String _keyLastCacheDate = 'salaty_last_cache_date';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- المدينة والموقع ---

  String getCityId() => _prefs.getString(_keyCityId) ?? 'cairo';

  Future<void> setCityId(String cityId) async {
    await _prefs.setString(_keyCityId, cityId);
  }

  bool getUseAutoLocation() => _prefs.getBool(_keyUseAutoLocation) ?? false;

  Future<void> setUseAutoLocation(bool value) async {
    await _prefs.setBool(_keyUseAutoLocation, value);
  }

  double? getCustomLat() => _prefs.getDouble(_keyCustomLat);
  double? getCustomLng() => _prefs.getDouble(_keyCustomLng);

  Future<void> setCustomCoordinates(double lat, double lng) async {
    await _prefs.setDouble(_keyCustomLat, lat);
    await _prefs.setDouble(_keyCustomLng, lng);
  }

  // --- خيارات الحساب والوقت ---

  AsrMadhab getMadhab() {
    final raw = _prefs.getString(_keyMadhab);
    if (raw == 'hanafi') return AsrMadhab.hanafi;
    return AsrMadhab.shafii;
  }

  Future<void> setMadhab(AsrMadhab madhab) async {
    await _prefs.setString(_keyMadhab, madhab == AsrMadhab.hanafi ? 'hanafi' : 'shafii');
  }

  DstMode getDstMode() {
    final raw = _prefs.getString(_keyDstMode);
    if (raw == 'alwaysWinterUtc2') return DstMode.alwaysWinterUtc2;
    if (raw == 'alwaysSummerUtc3') return DstMode.alwaysSummerUtc3;
    return DstMode.autoEgypt;
  }

  Future<void> setDstMode(DstMode mode) async {
    await _prefs.setString(_keyDstMode, mode.name);
  }

  bool getIs24Hours() => _prefs.getBool(_keyIs24Hours) ?? false;

  Future<void> setIs24Hours(bool value) async {
    await _prefs.setBool(_keyIs24Hours, value);
  }

  int getHijriOffset() => _prefs.getInt(_keyHijriOffset) ?? 0;

  Future<void> setHijriOffset(int offset) async {
    await _prefs.setInt(_keyHijriOffset, offset);
  }

  PrayerAdjustments getAdjustments() {
    final raw = _prefs.getString(_keyAdjustments);
    if (raw == null) return const PrayerAdjustments();
    try {
      return PrayerAdjustments.fromJson(jsonDecode(raw));
    } catch (_) {
      return const PrayerAdjustments();
    }
  }

  Future<void> setAdjustments(PrayerAdjustments adj) async {
    await _prefs.setString(_keyAdjustments, jsonEncode(adj.toJson()));
  }

  // --- المظهر ---

  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  // --- التنبيهات والأذان ---

  String getAdhanSound() => _prefs.getString(_keyAdhanSoundType) ?? 'adhan_full_cairo';

  Future<void> setAdhanSound(String sound) async {
    await _prefs.setString(_keyAdhanSoundType, sound);
  }

  int getPreReminderMinutes() => _prefs.getInt(_keyPreReminderMinutes) ?? 0;

  Future<void> setPreReminderMinutes(int minutes) async {
    await _prefs.setInt(_keyPreReminderMinutes, minutes);
  }

  /// إعدادات التنبيه لكل صلاة (تفعيل/تعطيل)
  Map<String, bool> getNotificationToggles() {
    final raw = _prefs.getString(_keyNotificationSettings);
    if (raw == null) {
      return {
        'fajr': true,
        'sunrise': false, // تنبيه الشروق افتراضياً صامت أو معطل لتجنب الإزعاج
        'dhuhr': true,
        'asr': true,
        'maghrib': true,
        'isha': true,
      };
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {
        'fajr': true,
        'sunrise': false,
        'dhuhr': true,
        'asr': true,
        'maghrib': true,
        'isha': true,
      };
    }
  }

  Future<void> setNotificationToggle(String prayerKey, bool isEnabled) async {
    final current = getNotificationToggles();
    current[prayerKey] = isEnabled;
    await _prefs.setString(_keyNotificationSettings, jsonEncode(current));
  }

  Future<void> setAllNotificationToggles(Map<String, bool> toggles) async {
    await _prefs.setString(_keyNotificationSettings, jsonEncode(toggles));
  }

  // --- التخزين المؤقت وحالة التحديث ---

  DateTime? getLastCacheDate() {
    final raw = _prefs.getString(_keyLastCacheDate);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastCacheDate(DateTime date) async {
    await _prefs.setString(_keyLastCacheDate, date.toIso8601String());
  }
}
