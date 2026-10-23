import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/egypt_cities.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/prayer_calculation_engine.dart';
import '../repositories/prayer_repository.dart';

class PrayerTimesProvider extends ChangeNotifier {
  final StorageService storageService;
  final PrayerRepository prayerRepository;

  EgyptianCity _selectedCity = EgyptCitiesDatabase.defaultCity;
  DateTime _selectedDate = DateTime.now();
  CalculatedPrayerTimes? _currentTimes;
  PrayerTimeSlot? _nextPrayer;
  bool _isLoading = false;
  bool _isAutoLocation = false;
  Timer? _countdownTicker;
  DateTime _lastTickTime = DateTime.now();

  EgyptianCity get selectedCity => _selectedCity;
  DateTime get selectedDate => _selectedDate;
  CalculatedPrayerTimes? get currentTimes => _currentTimes;
  PrayerTimeSlot? get nextPrayer => _nextPrayer;
  bool get isLoading => _isLoading;
  bool get isAutoLocation => _isAutoLocation;
  DateTime get lastTickTime => _lastTickTime;

  PrayerTimesProvider({
    required this.storageService,
    required this.prayerRepository,
  }) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    final savedCityId = storageService.getCityId();
    _selectedCity = EgyptCitiesDatabase.findById(savedCityId);
    _isAutoLocation = storageService.getUseAutoLocation();

    if (_isAutoLocation) {
      await detectLocation(silent: true);
    } else {
      await loadTimesForSelectedDate();
    }

    _startCountdownTicker();
    _isLoading = false;
    notifyListeners();

    // جدولة الإشعارات التلقائية
    _rescheduleNotifications();
  }

  void _startCountdownTicker() {
    _countdownTicker?.cancel();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _lastTickTime = DateTime.now();
      if (_currentTimes != null) {
        _nextPrayer = _currentTimes!.getNextPrayer(_lastTickTime);
        notifyListeners();
      }
    });
  }

  Future<void> loadTimesForSelectedDate() async {
    _currentTimes = await prayerRepository.getPrayerTimes(
      date: _selectedDate,
      city: _selectedCity,
    );
    _nextPrayer = _currentTimes?.getNextPrayer(DateTime.now());
    notifyListeners();
  }

  Future<void> setDate(DateTime newDate) async {
    _selectedDate = newDate;
    await loadTimesForSelectedDate();
  }

  Future<void> goToToday() async {
    _selectedDate = DateTime.now();
    await loadTimesForSelectedDate();
  }

  Future<void> goToNextDay() async {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    await loadTimesForSelectedDate();
  }

  Future<void> goToPreviousDay() async {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    await loadTimesForSelectedDate();
  }

  Future<void> selectCity(EgyptianCity city) async {
    _selectedCity = city;
    _isAutoLocation = false;
    await storageService.setCityId(city.id);
    await storageService.setUseAutoLocation(false);
    await loadTimesForSelectedDate();
    await _rescheduleNotifications();
    notifyListeners();
  }

  Future<bool> detectLocation({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    final city = await LocationService.detectEgyptianCity();
    if (city != null) {
      _selectedCity = city;
      _isAutoLocation = true;
      await storageService.setCityId(city.id);
      await storageService.setUseAutoLocation(true);
      await loadTimesForSelectedDate();
      await _rescheduleNotifications();
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _rescheduleNotifications() async {
    await AppNotificationService().rescheduleUpcomingPrayers(
      city: _selectedCity,
      storage: storageService,
    );
  }

  Future<void> refreshAll() async {
    await loadTimesForSelectedDate();
    await _rescheduleNotifications();
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    super.dispose();
  }
}
