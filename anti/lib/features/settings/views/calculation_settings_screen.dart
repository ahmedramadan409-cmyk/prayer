import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/prayer_calculation_engine.dart';
import '../../prayer_times/models/prayer_provider.dart';
import '../models/settings_provider.dart';
import 'data_sources_screen.dart';

class CalculationSettingsScreen extends StatelessWidget {
  const CalculationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final city = prayerProvider.selectedCity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الحساب والمواقيت'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // بطاقة المنهجية الرسمية المعتمدة
          Card(
            color: isDark ? const Color(0xFF132A1E) : const Color(0xFFF1F8F3),
            child: ListTile(
              leading: const Icon(Icons.verified, color: AppColors.accentGold, size: 28),
              title: const Text(
                'المرجع: الهيئة المصرية العامة للمساحة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'زاوية الفجر 19.5° | زاوية العشاء 17.5° | احتياط الزوال والغروب',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DataSourcesScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // مذهب صلاة العصر
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مذهب حساب صلاة العصر',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  RadioListTile<AsrMadhab>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('الشافعي والمالكي والحنبلي (ظل المثل = 1)'),
                    subtitle: const Text('المعتمد رسمياً في دار الإفتاء والهيئة المصرية للمساحة'),
                    value: AsrMadhab.shafii,
                    groupValue: settingsProvider.madhab,
                    activeColor: AppColors.accentGold,
                    onChanged: (val) {
                      if (val != null) {
                        settingsProvider.setMadhab(val, city);
                        prayerProvider.loadTimesForSelectedDate();
                      }
                    },
                  ),
                  RadioListTile<AsrMadhab>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('المذهب الحنفي (ظل المثلين = 2)'),
                    value: AsrMadhab.hanafi,
                    groupValue: settingsProvider.madhab,
                    activeColor: AppColors.accentGold,
                    onChanged: (val) {
                      if (val != null) {
                        settingsProvider.setMadhab(val, city);
                        prayerProvider.loadTimesForSelectedDate();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // التوقيت الصيفي والشتوي
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التوقيت الصيفي والشتوي في مصر',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  RadioListTile<DstMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('تلقائي وفق القانون المصري 24 لسنة 2023'),
                    subtitle: const Text('يبدأ آخر جمعة من أبريل وينتهي آخر خميس من أكتوبر'),
                    value: DstMode.autoEgypt,
                    groupValue: settingsProvider.dstMode,
                    activeColor: AppColors.accentGold,
                    onChanged: (val) {
                      if (val != null) {
                        settingsProvider.setDstMode(val, city);
                        prayerProvider.loadTimesForSelectedDate();
                      }
                    },
                  ),
                  RadioListTile<DstMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('توقيت شتوي دائماً (UTC+2)'),
                    value: DstMode.alwaysWinterUtc2,
                    groupValue: settingsProvider.dstMode,
                    activeColor: AppColors.accentGold,
                    onChanged: (val) {
                      if (val != null) {
                        settingsProvider.setDstMode(val, city);
                        prayerProvider.loadTimesForSelectedDate();
                      }
                    },
                  ),
                  RadioListTile<DstMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('توقيت صيفي دائماً (UTC+3)'),
                    value: DstMode.alwaysSummerUtc3,
                    groupValue: settingsProvider.dstMode,
                    activeColor: AppColors.accentGold,
                    onChanged: (val) {
                      if (val != null) {
                        settingsProvider.setDstMode(val, city);
                        prayerProvider.loadTimesForSelectedDate();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // تنسيق عرض الوقت والمظهر
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('نظام 24 ساعة للوقت', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    settingsProvider.is24Hours ? 'مفعل (مثال: 15:30)' : 'معطل - نظام 12 ساعة (مثال: 3:30 م)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: settingsProvider.is24Hours,
                  activeColor: AppColors.accentGold,
                  onChanged: (val) {
                    settingsProvider.setIs24Hours(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('المظهر (الوضع الليلي والنهاري)', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settingsProvider.themeMode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('تلقائي مع النظام')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('الوضع النهاري (فاتح)')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('الوضع الليلي (داكن)')),
                    ],
                    onChanged: (val) {
                      if (val != null) settingsProvider.setThemeMode(val);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('تعديل التقويم الهجري', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('للتوافق مع الرؤية الشرعية للهلال في مصر', style: TextStyle(fontSize: 12)),
                  trailing: DropdownButton<int>(
                    value: settingsProvider.hijriOffset,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: -2, child: Text('-2 يوم')),
                      DropdownMenuItem(value: -1, child: Text('-1 يوم')),
                      DropdownMenuItem(value: 0, child: Text('بدون تعديل (0)')),
                      DropdownMenuItem(value: 1, child: Text('+1 يوم')),
                      DropdownMenuItem(value: 2, child: Text('+2 يوم')),
                    ],
                    onChanged: (val) {
                      if (val != null) settingsProvider.setHijriOffset(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // تعديل الدقائق اليدوي لكل صلاة
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الضبط اليدوي بالدقائق للمواقيت',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يمكنك زيادة أو إنقاص دقائق محددة لكل صلاة بحسب مسجد منطقتك.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  _buildMinuteAdjustmentRow(
                    title: 'الفجر',
                    value: settingsProvider.adjustments.fajr,
                    onChanged: (val) {
                      final current = settingsProvider.adjustments;
                      settingsProvider.setAdjustments(
                        PrayerAdjustments(
                          fajr: val,
                          sunrise: current.sunrise,
                          dhuhr: current.dhuhr,
                          asr: current.asr,
                          maghrib: current.maghrib,
                          isha: current.isha,
                        ),
                        city,
                      );
                      prayerProvider.loadTimesForSelectedDate();
                    },
                  ),
                  _buildMinuteAdjustmentRow(
                    title: 'الظهر',
                    value: settingsProvider.adjustments.dhuhr,
                    onChanged: (val) {
                      final current = settingsProvider.adjustments;
                      settingsProvider.setAdjustments(
                        PrayerAdjustments(
                          fajr: current.fajr,
                          sunrise: current.sunrise,
                          dhuhr: val,
                          asr: current.asr,
                          maghrib: current.maghrib,
                          isha: current.isha,
                        ),
                        city,
                      );
                      prayerProvider.loadTimesForSelectedDate();
                    },
                  ),
                  _buildMinuteAdjustmentRow(
                    title: 'العصر',
                    value: settingsProvider.adjustments.asr,
                    onChanged: (val) {
                      final current = settingsProvider.adjustments;
                      settingsProvider.setAdjustments(
                        PrayerAdjustments(
                          fajr: current.fajr,
                          sunrise: current.sunrise,
                          dhuhr: current.dhuhr,
                          asr: val,
                          maghrib: current.maghrib,
                          isha: current.isha,
                        ),
                        city,
                      );
                      prayerProvider.loadTimesForSelectedDate();
                    },
                  ),
                  _buildMinuteAdjustmentRow(
                    title: 'المغرب',
                    value: settingsProvider.adjustments.maghrib,
                    onChanged: (val) {
                      final current = settingsProvider.adjustments;
                      settingsProvider.setAdjustments(
                        PrayerAdjustments(
                          fajr: current.fajr,
                          sunrise: current.sunrise,
                          dhuhr: current.dhuhr,
                          asr: current.asr,
                          maghrib: val,
                          isha: current.isha,
                        ),
                        city,
                      );
                      prayerProvider.loadTimesForSelectedDate();
                    },
                  ),
                  _buildMinuteAdjustmentRow(
                    title: 'العشاء',
                    value: settingsProvider.adjustments.isha,
                    onChanged: (val) {
                      final current = settingsProvider.adjustments;
                      settingsProvider.setAdjustments(
                        PrayerAdjustments(
                          fajr: current.fajr,
                          sunrise: current.sunrise,
                          dhuhr: current.dhuhr,
                          asr: current.asr,
                          maghrib: current.maghrib,
                          isha: val,
                        ),
                        city,
                      );
                      prayerProvider.loadTimesForSelectedDate();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMinuteAdjustmentRow({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                onPressed: value > -15 ? () => onChanged(value - 1) : null,
              ),
              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  value > 0 ? '+$value د' : (value < 0 ? '$value د' : '0 د'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 22),
                onPressed: value < 15 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
