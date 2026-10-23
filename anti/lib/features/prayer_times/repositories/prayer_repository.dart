import 'dart:convert';
import '../../../core/constants/egypt_cities.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/prayer_calculation_engine.dart';

enum PrayerDataSourceType {
  localEsaCalculation, // حساب فلكي محلي مطابق للهيئة المصرية العامة للمساحة
  externalVerifiedApi, // مزامنة عبر واجهة برمجية خارجية معتمدة (عند توفرها)
}

class PrayerSourceInfo {
  final PrayerDataSourceType type;
  final String titleAr;
  final String descriptionAr;
  final bool isOfflineReady;
  final DateTime? lastCalculatedDate;

  const PrayerSourceInfo({
    required this.type,
    required this.titleAr,
    required this.descriptionAr,
    required this.isOfflineReady,
    this.lastCalculatedDate,
  });
}

abstract class IPrayerTimesDataSource {
  Future<CalculatedPrayerTimes> getPrayerTimes({
    required DateTime date,
    required EgyptianCity city,
    required AsrMadhab madhab,
    required DstMode dstMode,
    required PrayerAdjustments adjustments,
  });

  PrayerSourceInfo getSourceInfo();
}

/// المصدر المحلي: حساب فلكي دقيق وفق المنهجية الرسمية للهيئة المصرية العامة للمساحة
/// يعمل 100% بدون اتصال بالإنترنت ولا يحتاج لأي خادم خارجي
class LocalEsaAstronomicalDataSource implements IPrayerTimesDataSource {
  @override
  Future<CalculatedPrayerTimes> getPrayerTimes({
    required DateTime date,
    required EgyptianCity city,
    required AsrMadhab madhab,
    required DstMode dstMode,
    required PrayerAdjustments adjustments,
  }) async {
    return EgyptianPrayerCalculator.calculate(
      date: date,
      latitude: city.latitude,
      longitude: city.longitude,
      asrMadhab: madhab,
      dstMode: dstMode,
      adjustments: adjustments,
    );
  }

  @override
  PrayerSourceInfo getSourceInfo() {
    return const PrayerSourceInfo(
      type: PrayerDataSourceType.localEsaCalculation,
      titleAr: 'محرك الحساب الفلكي المحلي (معايير الهيئة المصرية العامة للمساحة)',
      descriptionAr:
          'يتم الحساب مباشرة داخل جهازك باستخدام خوارزميات فلكية دقيقة مطابقة تماماً لمعايير الهيئة المصرية العامة للمساحة (الفجر 19.5°، العشاء 17.5°، واحتياط الزوال والغروب)، ويعمل دون اتصال بالإنترنت.',
      isOfflineReady: true,
    );
  }
}

/// مستودع إدارة مواقيت الصلاة مع التخزين المؤقت
class PrayerRepository {
  final StorageService storageService;
  IPrayerTimesDataSource _currentSource;

  PrayerRepository({
    required this.storageService,
    IPrayerTimesDataSource? dataSource,
  }) : _currentSource = dataSource ?? LocalEsaAstronomicalDataSource();

  void switchDataSource(IPrayerTimesDataSource newSource) {
    _currentSource = newSource;
  }

  PrayerSourceInfo getSourceInfo() => _currentSource.getSourceInfo();

  /// جلب مواقيت الصلاة ليوم ومحافظة معينة مع التخزين المحلي
  Future<CalculatedPrayerTimes> getPrayerTimes({
    required DateTime date,
    required EgyptianCity city,
  }) async {
    final madhab = storageService.getMadhab();
    final dstMode = storageService.getDstMode();
    final adjustments = storageService.getAdjustments();

    final times = await _currentSource.getPrayerTimes(
      date: date,
      city: city,
      madhab: madhab,
      dstMode: dstMode,
      adjustments: adjustments,
    );

    // حفظ تاريخ آخر معالجة
    await storageService.setLastCacheDate(DateTime.now());

    return times;
  }

  /// جلب مواقيت شهر كامل (لعرض التقويم الهجري والميلادي)
  Future<List<CalculatedPrayerTimes>> getMonthlyPrayerTimes({
    required int year,
    required int month,
    required EgyptianCity city,
  }) async {
    final madhab = storageService.getMadhab();
    final dstMode = storageService.getDstMode();
    final adjustments = storageService.getAdjustments();

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<CalculatedPrayerTimes> monthTimes = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final times = await _currentSource.getPrayerTimes(
        date: date,
        city: city,
        madhab: madhab,
        dstMode: dstMode,
        adjustments: adjustments,
      );
      monthTimes.add(times);
    }

    return monthTimes;
  }
}
