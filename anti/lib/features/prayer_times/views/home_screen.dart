import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/egypt_cities.dart';
import '../../../../core/utils/hijri_date.dart';
import '../../../../core/utils/prayer_calculation_engine.dart';
import '../../../../core/utils/time_formatter.dart';
import '../models/prayer_provider.dart';
import '../../settings/models/settings_provider.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_time_tile.dart';
import '../../qibla/views/qibla_screen.dart';
import '../../calendar/views/calendar_screen.dart';
import '../../settings/views/cities_screen.dart';
import '../../settings/views/adhan_settings_screen.dart';
import '../../settings/views/calculation_settings_screen.dart';
import '../../about/views/about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final city = prayerProvider.selectedCity;
    final date = prayerProvider.selectedDate;
    final times = prayerProvider.currentTimes;
    final nextSlot = prayerProvider.nextPrayer;
    final is24H = settingsProvider.is24Hours;

    final hijri = HijriDate.fromGregorian(
      date,
      adjustmentDays: settingsProvider.hijriOffset,
    );
    final islamicEvent = hijri.getIslamicEvent();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CitiesScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentGold.withOpacity(0.6),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  prayerProvider.isAutoLocation ? Icons.my_location : Icons.location_on,
                  size: 16,
                  color: AppColors.accentGold,
                ),
                const SizedBox(width: 6),
                Text(
                  city.cityNameAr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.white),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'عن التطبيق',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'إعدادات الحساب والمواقيت',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalculationSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: prayerProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDarkGreen),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await prayerProvider.refreshAll();
              },
              color: AppColors.primaryDarkGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // شريط التاريخ الهجري والميلادي مع التنقل بين الأيام
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, size: 28),
                                  tooltip: 'اليوم التالي',
                                  onPressed: () => prayerProvider.goToNextDay(),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        hijri.formatFullArabic(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.primaryDarkGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        TimeFormatter.formatGregorian(date),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_left, size: 28),
                                  tooltip: 'اليوم السابق',
                                  onPressed: () => prayerProvider.goToPreviousDay(),
                                ),
                              ],
                            ),
                            // زر العودة إلى اليوم الحالي إذا كان المستخدم يتصفح يوماً آخر
                            if (!_isSameDay(date, DateTime.now()))
                              TextButton.icon(
                                onPressed: () => prayerProvider.goToToday(),
                                icon: const Icon(Icons.today, size: 16, color: AppColors.accentGold),
                                label: const Text(
                                  'العودة لمواقيت اليوم الحالي',
                                  style: TextStyle(fontSize: 12, color: AppColors.accentGold),
                                ),
                              ),
                            // مناسبة إسلامية إن وجدت
                            if (islamicEvent != null)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppColors.accentGold),
                                    const SizedBox(width: 6),
                                    Text(
                                      islamicEvent,
                                      style: const TextStyle(
                                        color: AppColors.accentGoldDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // بطاقة الصلاة القادمة والعداد التنازلي
                    NextPrayerCard(
                      nextPrayer: nextSlot,
                      is24Hours: is24H,
                    ),

                    const SizedBox(height: 16),

                    // عنوان الصلوات مع حالة التوقيت
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'مواقيت الصلاة اليوم',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (times != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              times.isDstActive ? 'التوقيت الصيفي (UTC+3)' : 'التوقيت الشتوي (UTC+2)',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // قائمة الصلوات الست
                    if (times != null) ...[
                      PrayerTimeTile(
                        prayerKey: 'fajr',
                        titleAr: 'الفجر',
                        time: times.fajr,
                        isNext: nextSlot?.type == PrayerType.fajr,
                        is24Hours: is24H,
                        isNotificationEnabled: settingsProvider.notificationToggles['fajr'] ?? true,
                        onNotificationToggle: (val) =>
                            settingsProvider.toggleNotification('fajr', val, city),
                      ),
                      PrayerTimeTile(
                        prayerKey: 'sunrise',
                        titleAr: 'الشروق',
                        time: times.sunrise,
                        isNext: nextSlot?.type == PrayerType.sunrise,
                        is24Hours: is24H,
                        isNotificationEnabled: settingsProvider.notificationToggles['sunrise'] ?? false,
                        onNotificationToggle: (val) =>
                            settingsProvider.toggleNotification('sunrise', val, city),
                      ),
                      PrayerTimeTile(
                        prayerKey: 'dhuhr',
                        titleAr: 'الظهر',
                        time: times.dhuhr,
                        isNext: nextSlot?.type == PrayerType.dhuhr,
                        is24Hours: is24H,
                        isNotificationEnabled: settingsProvider.notificationToggles['dhuhr'] ?? true,
                        onNotificationToggle: (val) =>
                            settingsProvider.toggleNotification('dhuhr', val, city),
                      ),
                      PrayerTimeTile(
                        prayerKey: 'asr',
                        titleAr: 'العصر',
                        time: times.asr,
                        isNext: nextSlot?.type == PrayerType.asr,
                        is24Hours: is24H,
                        isNotificationEnabled: settingsProvider.notificationToggles['asr'] ?? true,
                        onNotificationToggle: (val) =>
                            settingsProvider.toggleNotification('asr', val, city),
                      ),
                      PrayerTimeTile(
                        prayerKey: 'maghrib',
                        titleAr: 'المغرب',
                        time: times.maghrib,
                        isNext: nextSlot?.type == PrayerType.maghrib,
                        is24Hours: is24H,
                        isNotificationEnabled: settingsProvider.notificationToggles['maghrib'] ?? true,
                        onNotificationToggle: (val) =>
                            settingsProvider.toggleNotification('maghrib', val, city),
                      ),
                      PrayerTimeTile(
                        prayerKey: 'isha',
                        titleAr: 'العشاء',
                        time: times.isha,
                        isNext: nextSlot?.type == PrayerType.isha,
                        is24Hours: is24H,
                        isNotificationEnabled: settingsProvider.notificationToggles['isha'] ?? true,
                        onNotificationToggle: (val) =>
                            settingsProvider.toggleNotification('isha', val, city),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // شريط الأدوات السريعة (القبلة، التقويم، إعدادات الأذان)
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.explore,
                            title: 'اتجاه القبلة',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const QiblaScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.calendar_month,
                            title: 'التقويم الهجري',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CalendarScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.notifications_active,
                            title: 'إعدادات الأذان',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdhanSettingsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentGold, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
