import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/hijri_date.dart';
import '../../../../core/utils/prayer_calculation_engine.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../prayer_times/models/prayer_provider.dart';
import '../../settings/models/settings_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  List<CalculatedPrayerTimes> _monthTimes = [];
  bool _isLoadingMonth = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoadingMonth = true);
    final prayerProvider = Provider.of<PrayerTimesProvider>(context, listen: false);

    final times = await prayerProvider.prayerRepository.getMonthlyPrayerTimes(
      year: _focusedMonth.year,
      month: _focusedMonth.month,
      city: prayerProvider.selectedCity,
    );

    if (mounted) {
      setState(() {
        _monthTimes = times;
        _isLoadingMonth = false;
      });
    }
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
    _loadMonthData();
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
    _loadMonthData();
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final is24H = settingsProvider.is24Hours;

    const gregorianMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final monthName = gregorianMonths[_focusedMonth.month - 1];

    final midMonthHijri = HijriDate.fromGregorian(
      DateTime(_focusedMonth.year, _focusedMonth.month, 15),
      adjustmentDays: settingsProvider.hijriOffset,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقويم ومواقيت الشهر'),
      ),
      body: Column(
        children: [
          // شريط اختيار الشهر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  tooltip: 'الشهر السابق',
                  onPressed: _previousMonth,
                ),
                Column(
                  children: [
                    Text(
                      '$monthName ${_focusedMonth.year} م',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    Text(
                      'الموافق: ${midMonthHijri.monthNameAr} ${midMonthHijri.hYear} هـ',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  tooltip: 'الشهر التالي',
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // قائمة أيام الشهر
          Expanded(
            child: _isLoadingMonth
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryDarkGreen),
                  )
                : ListView.builder(
                    itemCount: _monthTimes.length,
                    itemBuilder: (context, index) {
                      final dayTimes = _monthTimes[index];
                      final isToday = _isToday(dayTimes.date);
                      final hijri = HijriDate.fromGregorian(
                        dayTimes.date,
                        adjustmentDays: settingsProvider.hijriOffset,
                      );
                      final event = hijri.getIslamicEvent();

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isToday
                              ? (isDark ? const Color(0xFF1D4532) : const Color(0xFFEAF5EE))
                              : (isDark ? AppColors.cardDark : AppColors.cardLight),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday
                                ? AppColors.accentGold
                                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                            width: isToday ? 1.5 : 0.8,
                          ),
                        ),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          leading: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.accentGold
                                  : (isDark ? Colors.white10 : AppColors.primaryDarkGreen.withOpacity(0.08)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${dayTimes.date.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isToday ? AppColors.black : null,
                                  ),
                                ),
                                Text(
                                  hijri.dayNameAr.substring(0, 3),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isToday ? AppColors.black : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '${hijri.hDay} ${hijri.monthNameAr}',
                                style: TextStyle(
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'اليوم',
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: event != null
                              ? Text(
                                  event,
                                  style: const TextStyle(
                                    color: AppColors.accentGoldDark,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'الفجر: ${TimeFormatter.formatPrayerTime(dayTimes.fajr, is24Hours: is24H)} | المغرب: ${TimeFormatter.formatPrayerTime(dayTimes.maghrib, is24Hours: is24H)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _PrayerColumn(title: 'الفجر', time: dayTimes.fajr, is24H: is24H),
                                  _PrayerColumn(title: 'الشروق', time: dayTimes.sunrise, is24H: is24H),
                                  _PrayerColumn(title: 'الظهر', time: dayTimes.dhuhr, is24H: is24H),
                                  _PrayerColumn(title: 'العصر', time: dayTimes.asr, is24H: is24H),
                                  _PrayerColumn(title: 'المغرب', time: dayTimes.maghrib, is24H: is24H),
                                  _PrayerColumn(title: 'العشاء', time: dayTimes.isha, is24H: is24H),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }
}

class _PrayerColumn extends StatelessWidget {
  final String title;
  final DateTime time;
  final bool is24H;

  const _PrayerColumn({
    Key? key,
    required this.title,
    required this.time,
    required this.is24H,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          TimeFormatter.formatPrayerTime(time, is24Hours: is24H),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
