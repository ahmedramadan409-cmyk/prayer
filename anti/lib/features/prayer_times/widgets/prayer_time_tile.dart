import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/prayer_calculation_engine.dart';
import '../../../../core/utils/time_formatter.dart';

class PrayerTimeTile extends StatelessWidget {
  final String prayerKey;
  final String titleAr;
  final DateTime time;
  final bool isNext;
  final bool is24Hours;
  final bool isNotificationEnabled;
  final ValueChanged<bool> onNotificationToggle;

  const PrayerTimeTile({
    Key? key,
    required this.prayerKey,
    required this.titleAr,
    required this.time,
    required this.isNext,
    required this.is24Hours,
    required this.isNotificationEnabled,
    required this.onNotificationToggle,
  }) : super(key: key);

  IconData _getPrayerIcon() {
    switch (prayerKey) {
      case 'fajr':
        return Icons.nights_stay_outlined;
      case 'sunrise':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.wb_twilight_rounded;
      case 'isha':
        return Icons.bedtime_outlined;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime = TimeFormatter.formatPrayerTime(time, is24Hours: is24Hours);

    final cardBgColor = isNext
        ? (isDark ? const Color(0xFF1D4532) : const Color(0xFFEAF5EE))
        : (isDark ? AppColors.cardDark : AppColors.cardLight);

    final borderColor = isNext
        ? AppColors.accentGold
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isNext ? 1.5 : 0.8,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.primaryDarkGreen.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isNext
                ? AppColors.accentGold.withOpacity(0.2)
                : (isDark ? Colors.white.withOpacity(0.05) : AppColors.primaryDarkGreen.withOpacity(0.06)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getPrayerIcon(),
            color: isNext ? AppColors.accentGold : AppColors.primaryDarkGreen,
            size: 22,
          ),
        ),
        title: Text(
          titleAr,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: isNext
                ? (isDark ? AppColors.accentGold : AppColors.primaryDarkGreen)
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
        subtitle: isNext
            ? const Text(
                'الصلاة القادمة',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedTime,
              style: TextStyle(
                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                fontSize: 17,
                color: isNext
                    ? (isDark ? AppColors.accentGold : AppColors.primaryDarkGreen)
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isNotificationEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                size: 20,
                color: isNotificationEnabled
                    ? AppColors.accentGold
                    : (isDark ? Colors.white38 : Colors.black26),
              ),
              onPressed: () => onNotificationToggle(!isNotificationEnabled),
              tooltip: isNotificationEnabled ? 'تعطيل التنبيه' : 'تفعيل التنبيه',
            ),
          ],
        ),
      ),
    );
  }
}
