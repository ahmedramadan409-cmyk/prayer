import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../prayer_times/models/prayer_provider.dart';
import '../models/settings_provider.dart';

class AdhanSettingsScreen extends StatelessWidget {
  const AdhanSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final city = prayerProvider.selectedCity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الأذان والتنبيهات'),
      ),
      body: StreamBuilder<AudioPlaybackState>(
        stream: AppAudioService().stateStream,
        initialData: AppAudioService().playbackState,
        builder: (context, snapshot) {
          final isPreviewing = snapshot.data == AudioPlaybackState.previewing;
          final currentPlayingId = AppAudioService().currentlyPlayingId;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // بطاقة فحص الأذونات وقواعد النظام
              Card(
                color: isDark ? const Color(0xFF132A1E) : const Color(0xFFF1F8F3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security_update_good, color: AppColors.accentGold, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            Platform.isAndroid ? 'أذونات نظام Android' : 'أذونات وقواعد نظام iOS',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Platform.isAndroid
                            ? 'لضمان دقة الأذان في موعده تماماً على أندرويد، يحتاج التطبيق إلى إذن «الإشعارات» وإذن «المنبهات الدقيقة (Exact Alarms)»، كما يُنصح باستثناء التطبيق من قيود توفير طاقة البطارية.'
                            : 'في نظام iOS: تحدد أبل الحد الأقصى لصوت الإشعار المحلي في الخلفية بـ 30 ثانية فقط، لذا يُصدر الإشعار تكبيرات الأذان والتنبيه المخصص حتى 30 ثانية، بينما يُرفع الأذان كاملاً تلقائياً بمجرد فتح التطبيق أو النقر على الإشعار.',
                        style: const TextStyle(fontSize: 12.5, height: 1.6),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final res = await AppNotificationService().requestPermissions();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res ? 'تم التحقق من الأذونات بنجاح ✓' : 'يرجى تفعيل الأذونات من إعدادات الهاتف'),
                                  backgroundColor: res ? AppColors.primaryDarkGreen : Colors.orange,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.notifications_active_outlined, size: 18),
                          label: const Text('طلب وتفعيل أذونات الإشعارات'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDarkGreen,
                            side: const BorderSide(color: AppColors.primaryDarkGreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // اختيار صوت الأذان
              const Text(
                'اختيار صوت الأذان والتنبيه',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...AppAudioService.availableSounds.map((sound) {
                final isSelected = settingsProvider.adhanSound == sound.id;
                final isThisPlaying = isPreviewing && currentPlayingId == sound.id;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.accentGold : Colors.transparent,
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: ListTile(
                    leading: Radio<String>(
                      value: sound.id,
                      groupValue: settingsProvider.adhanSound,
                      activeColor: AppColors.accentGold,
                      onChanged: (val) {
                        if (val != null) {
                          settingsProvider.setAdhanSound(val, city);
                        }
                      },
                    ),
                    title: Text(
                      sound.nameAr,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      sound.descriptionAr,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isThisPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                        color: isThisPlaying ? Colors.red : AppColors.accentGold,
                        size: 32,
                      ),
                      tooltip: isThisPlaying ? 'إيقاف المعاينة' : 'معاينة الصوت',
                      onPressed: () {
                        AppAudioService().previewSound(sound.id);
                      },
                    ),
                    onTap: () {
                      settingsProvider.setAdhanSound(sound.id, city);
                    },
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              // التذكير قبل الصلاة
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'التنبيه المسبق قبل الأذان',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إرسال إشعار تذكيري هادئ قبل دخول وقت الصلاة بعدة دقائق للاستعداد والوضوء.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: settingsProvider.preReminderMinutes,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('معطل (تنبيه وقت الأذان فقط)')),
                          DropdownMenuItem(value: 5, child: Text('قبل 5 دقائق')),
                          DropdownMenuItem(value: 10, child: Text('قبل 10 دقائق')),
                          DropdownMenuItem(value: 15, child: Text('قبل 15 دقيقة (موصى به)')),
                          DropdownMenuItem(value: 20, child: Text('قبل 20 دقيقة')),
                          DropdownMenuItem(value: 30, child: Text('قبل نصف ساعة')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            settingsProvider.setPreReminderMinutes(val, city);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // تفعيل وتعطيل التنبيه لكل صلاة على حدة
              const Text(
                'تفعيل التنبيهات لكل صلاة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: [
                    _buildPrayerSwitch(
                      context,
                      title: 'صلاة الفجر',
                      keyName: 'fajr',
                      settings: settingsProvider,
                      city: city,
                    ),
                    const Divider(height: 1),
                    _buildPrayerSwitch(
                      context,
                      title: 'شروق الشمس',
                      keyName: 'sunrise',
                      settings: settingsProvider,
                      city: city,
                    ),
                    const Divider(height: 1),
                    _buildPrayerSwitch(
                      context,
                      title: 'صلاة الظهر',
                      keyName: 'dhuhr',
                      settings: settingsProvider,
                      city: city,
                    ),
                    const Divider(height: 1),
                    _buildPrayerSwitch(
                      context,
                      title: 'صلاة العصر',
                      keyName: 'asr',
                      settings: settingsProvider,
                      city: city,
                    ),
                    const Divider(height: 1),
                    _buildPrayerSwitch(
                      context,
                      title: 'صلاة المغرب',
                      keyName: 'maghrib',
                      settings: settingsProvider,
                      city: city,
                    ),
                    const Divider(height: 1),
                    _buildPrayerSwitch(
                      context,
                      title: 'صلاة العشاء',
                      keyName: 'isha',
                      settings: settingsProvider,
                      city: city,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrayerSwitch(
    BuildContext context, {
    required String title,
    required String keyName,
    required SettingsProvider settings,
    required dynamic city,
  }) {
    final isEnabled = settings.notificationToggles[keyName] ?? true;
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      value: isEnabled,
      activeColor: AppColors.accentGold,
      onChanged: (val) {
        settings.toggleNotification(keyName, val, city);
      },
    );
  }
}
