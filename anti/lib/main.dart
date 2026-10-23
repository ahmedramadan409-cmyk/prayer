import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/prayer_times/models/prayer_provider.dart';
import 'features/prayer_times/repositories/prayer_repository.dart';
import 'features/prayer_times/views/home_screen.dart';
import 'features/settings/models/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة التخزين المحلي
  final storageService = await StorageService.init();

  // 2. تهيئة خدمة الإشعارات المحلية والمنبهات
  final notificationService = AppNotificationService();
  await notificationService.init();

  // 3. تهيئة مستودع المواقيت (Clean Architecture)
  final prayerRepository = PrayerRepository(storageService: storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(storageService: storageService),
        ),
        ChangeNotifierProvider<PrayerTimesProvider>(
          create: (_) => PrayerTimesProvider(
            storageService: storageService,
            prayerRepository: prayerRepository,
          ),
        ),
      ],
      child: const SalatyEgyptApp(),
    ),
  );
}

class SalatyEgyptApp extends StatelessWidget {
  const SalatyEgyptApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'صلاتي مصر | Salaty Egypt',
      debugShowCheckedModeBanner: false,

      // دعم كامل للغة العربية واتجاه اليمين لليسار (RTL)
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // الثيمات
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: settingsProvider.themeMode,

      home: const HomeScreen(),
    );
  }
}
