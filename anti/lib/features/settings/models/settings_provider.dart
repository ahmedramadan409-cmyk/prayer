import 'package:flutter/material.dart';
import '../../../core/constants/egypt_cities.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/prayer_calculation_engine.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService storageService;

  late AsrMadhab _madhab;
  late DstMode _dstMode;
  late bool _is24Hours;
  late int _hijriOffset;
  late PrayerAdjustments _adjustments;
  late ThemeMode _themeMode;
  late String _adhanSound;
  late int _preReminderMinutes;
  late Map<String, bool> _notificationToggles;

  AsrMadhab get madhab => _madhab;
  DstMode get dstMode => _dstMode;
  bool get is24Hours => _is24Hours;
  int get hijriOffset => _hijriOffset;
  PrayerAdjustments get adjustments => _adjustments;
  ThemeMode get themeMode => _themeMode;
  String get adhanSound => _adhanSound;
  int get preReminderMinutes => _preReminderMinutes;
  Map<String, bool> get notificationToggles => _notificationToggles;

  SettingsProvider({required this.storageService}) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _madhab = storageService.getMadhab();
    _dstMode = storageService.getDstMode();
    _is24Hours = storageService.getIs24Hours();
    _hijriOffset = storageService.getHijriOffset();
    _adjustments = storageService.getAdjustments();
    _adhanSound = storageService.getAdhanSound();
    _preReminderMinutes = storageService.getPreReminderMinutes();
    _notificationToggles = storageService.getNotificationToggles();

    final themeStr = storageService.getThemeMode();
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setMadhab(AsrMadhab madhab, EgyptianCity city) async {
    _madhab = madhab;
    await storageService.setMadhab(madhab);
    await _reschedule(city);
    notifyListeners();
  }

  Future<void> setDstMode(DstMode mode, EgyptianCity city) async {
    _dstMode = mode;
    await storageService.setDstMode(mode);
    await _reschedule(city);
    notifyListeners();
  }

  Future<void> setIs24Hours(bool val) async {
    _is24Hours = val;
    await storageService.setIs24Hours(val);
    notifyListeners();
  }

  Future<void> setHijriOffset(int offset) async {
    _hijriOffset = offset;
    await storageService.setHijriOffset(offset);
    notifyListeners();
  }

  Future<void> setAdjustments(PrayerAdjustments adj, EgyptianCity city) async {
    _adjustments = adj;
    await storageService.setAdjustments(adj);
    await _reschedule(city);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await storageService.setThemeMode(modeStr);
    notifyListeners();
  }

  Future<void> setAdhanSound(String soundId, EgyptianCity city) async {
    _adhanSound = soundId;
    await storageService.setAdhanSound(soundId);
    await _reschedule(city);
    notifyListeners();
  }

  Future<void> setPreReminderMinutes(int minutes, EgyptianCity city) async {
    _preReminderMinutes = minutes;
    await storageService.setPreReminderMinutes(minutes);
    await _reschedule(city);
    notifyListeners();
  }

  Future<void> toggleNotification(String prayerKey, bool isEnabled, EgyptianCity city) async {
    _notificationToggles[prayerKey] = isEnabled;
    await storageService.setNotificationToggle(prayerKey, isEnabled);
    await _reschedule(city);
    notifyListeners();
  }

  Future<void> _reschedule(EgyptianCity city) async {
    await AppNotificationService().rescheduleUpcomingPrayers(
      city: city,
      storage: storageService,
    );
  }
}
