import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/utils/prayer_calculation_engine.dart';
import '../../../../core/utils/time_formatter.dart';

class NextPrayerCard extends StatelessWidget {
  final PrayerTimeSlot? nextPrayer;
  final bool is24Hours;

  const NextPrayerCard({
    Key? key,
    required this.nextPrayer,
    required this.is24Hours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (nextPrayer == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime = TimeFormatter.formatPrayerTime(
      nextPrayer!.time,
      is24Hours: is24Hours,
    );
    final countdownStr = TimeFormatter.formatDuration(nextPrayer!.remaining);

    return StreamBuilder<AudioPlaybackState>(
      stream: AppAudioService().stateStream,
      initialData: AppAudioService().playbackState,
      builder: (context, snapshot) {
        final isPlayingAudio = snapshot.data == AudioPlaybackState.playingAdhan;

        return Column(
          children: [
            // شريط إيقاف الأذان في حال كان الصوت يعمل الآن
            if (isPlayingAudio)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volume_up, color: AppColors.black, size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'الأذان يُرفع الآن.. حان وقت الصلاة',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => AppAudioService().stop(),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('إيقاف الصوت'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // البطاقة الكبرى للصلاة القادمة
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF133624), const Color(0xFF0D2519)]
                      : [AppColors.primaryDarkGreen, const Color(0xFF093120)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDarkGreen.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.accentGold.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  // زخرفة إسلامية خفيفة في الخلفية
                  Positioned(
                    left: -20,
                    top: -20,
                    child: Icon(
                      Icons.mosque,
                      size: 150,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.accentGold, width: 0.8),
                              ),
                              child: const Text(
                                'الصلاة القادمة',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nextPrayer!.nameAr,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'متبقي على الأذان',
                          style: TextStyle(
                            color: Color(0xFFB5D1C3),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // عداد تنازلي دقيق بالثواني
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            countdownStr,
                            style: const TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
