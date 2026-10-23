import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/prayer_calculation_engine.dart';
import '../constants/egypt_cities.dart';
import 'storage_service.dart';
import 'audio_service.dart';

/// خدمة إدارة الإشعارات المحلية وجدولة الأذان بدقة لنظامي Android و iOS
class AppNotificationService {
  static final AppNotificationService _instance = AppNotificationService._internal();
  factory AppNotificationService() => _instance;
  AppNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String channelIdAdhan = 'salaty_egypt_adhan_channel_v1';
  static const String channelNameAdhan = 'تنبيهات وأذان صلاتي مصر';
  static const String channelDescAdhan = 'قناة التنبيهات الدقيقة لمواقيت الصلاة والأذان';

  static const String channelIdReminders = 'salaty_egypt_reminders_channel_v1';
  static const String channelNameReminders = 'تذكيرات ما قبل الصلاة';
  static const String channelDescReminders = 'تنبيهات قبل دخول وقت الصلاة بعدة دقائق';

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    // ضبط المنطقة الزمنية المحلية لمصر (القاهرة)
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (_) {
      // احتياطي في حال عدم العثور على اسم النطاق
    }

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification_crescent');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
    );

    await _createNotificationChannels();
    _isInitialized = true;
  }

  /// إنشاء قنوات الإشعارات لنظام Android 8.0+
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // قناة الأذان ذات الأهمية القصوى
      const adhanChannel = AndroidNotificationChannel(
        channelIdAdhan,
        channelNameAdhan,
        description: channelDescAdhan,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('adhan_cairo'),
      );

      // قناة التذكيرات الهادئة
      const reminderChannel = AndroidNotificationChannel(
        channelIdReminders,
        channelNameReminders,
        description: channelDescReminders,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await androidImplementation.createNotificationChannel(adhanChannel);
      await androidImplementation.createNotificationChannel(reminderChannel);
    }
  }

  /// طلب الأذونات اللازمة من المستخدم (Android 13+ و iOS)
  Future<bool> requestPermissions() async {
    bool granted = false;

    if (Platform.isAndroid) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final notificationsGranted = await androidImpl.requestNotificationsPermission();
        final exactAlarmGranted = await androidImpl.requestExactAlarmsPermission();
        granted = (notificationsGranted ?? false) && (exactAlarmGranted ?? false);
      }
    } else if (Platform.isIOS) {
      final iosImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final res = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = res ?? false;
      }
    }

    return granted;
  }

  /// إعادة جدولة مواقيت وتنبيهات الأيام القادمة (لـ 7 أيام قادمة)
  Future<void> rescheduleUpcomingPrayers({
    required EgyptianCity city,
    required StorageService storage,
  }) async {
    // إلغاء كافة الإشعارات المجدولة القديمة لتجنب أي تداخل
    await cancelAll();

    final toggles = storage.getNotificationToggles();
    final madhab = storage.getMadhab();
    final dstMode = storage.getDstMode();
    final adjustments = storage.getAdjustments();
    final preReminderMinutes = storage.getPreReminderMinutes();
    final soundId = storage.getAdhanSound();

    final now = DateTime.now();

    // جدولة 7 أيام مقدماً
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final times = EgyptianPrayerCalculator.calculate(
        date: targetDate,
        latitude: city.latitude,
        longitude: city.longitude,
        asrMadhab: madhab,
        dstMode: dstMode,
        adjustments: adjustments,
      );

      final prayers = [
        _PrayerScheduleItem(key: 'fajr', name: 'صلاة الفجر', time: times.fajr, baseId: 1000),
        _PrayerScheduleItem(key: 'sunrise', name: 'شروق الشمس', time: times.sunrise, baseId: 2000),
        _PrayerScheduleItem(key: 'dhuhr', name: 'صلاة الظهر', time: times.dhuhr, baseId: 3000),
        _PrayerScheduleItem(key: 'asr', name: 'صلاة العصر', time: times.asr, baseId: 4000),
        _PrayerScheduleItem(key: 'maghrib', name: 'صلاة المغرب', time: times.maghrib, baseId: 5000),
        _PrayerScheduleItem(key: 'isha', name: 'صلاة العشاء', time: times.isha, baseId: 6000),
      ];

      for (final p in prayers) {
        // التحقق إن كانت الصلاة مفعلة في الإعدادات وإن كان وقتها لم يمضِ بعد
        final isEnabled = toggles[p.key] ?? true;
        if (!isEnabled) continue;

        if (p.time.isAfter(now)) {
          // جدولة تنبيه الأذان في وقت الصلاة تماماً
          await _scheduleSinglePrayerNotification(
            id: p.baseId + dayOffset,
            title: 'حان الآن موعد ${p.name}',
            body: 'الله أكبر.. حسب التوقيت المحلي لـ ${city.cityNameAr}',
            scheduledTime: p.time,
            soundId: soundId,
            payload: 'prayer_${p.key}',
          );
        }

        // جدولة التذكير المسبق (مثلاً قبل 15 دقيقة) إذا كان مفعلاً
        if (preReminderMinutes > 0 && p.key != 'sunrise') {
          final reminderTime = p.time.subtract(Duration(minutes: preReminderMinutes));
          if (reminderTime.isAfter(now)) {
            await _schedulePreReminderNotification(
              id: 10000 + p.baseId + dayOffset,
              title: 'اقترب موعد ${p.name}',
              body: 'بقي $preReminderMinutes دقيقة على أذان ${p.name} في ${city.cityNameAr}',
              scheduledTime: reminderTime,
            );
          }
        }
      }
    }
  }

  Future<void> _scheduleSinglePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String soundId,
    required String payload,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      channelIdAdhan,
      channelNameAdhan,
      channelDescription: channelDescAdhan,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      sound: const RawResourceAndroidNotificationSound('adhan_cairo'),
      playSound: true,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_stop_adhan',
          'إيقاف الصوت',
          cancelNotification: true,
        ),
      ],
    );

    // قيود نظام iOS: الأصوات المخصصة يجب أن تكون مدتها 30 ثانية أو أقل داخل حزمة التطبيق
    const iosDetails = DarwinNotificationDetails(
      sound: 'adhan_cairo_short.caf',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> _schedulePreReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      channelIdReminders,
      channelNameReminders,
      channelDescription: channelDescReminders,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'pre_reminder',
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.actionId == 'action_stop_adhan') {
      AppAudioService().stop();
    } else if (response.payload != null && response.payload!.startsWith('prayer_')) {
      final prayerKey = response.payload!.replaceFirst('prayer_', '');
      AppAudioService().playAdhanForPrayer(prayerKey);
    }
  }

  @pragma('vm:entry-point')
  static void _backgroundNotificationHandler(NotificationResponse response) {
    if (response.actionId == 'action_stop_adhan') {
      AppAudioService().stop();
    }
  }
}

class _PrayerScheduleItem {
  final String key;
  final String name;
  final DateTime time;
  final int baseId;

  const _PrayerScheduleItem({
    required this.key,
    required this.name,
    required this.time,
    required this.baseId,
  });
}
