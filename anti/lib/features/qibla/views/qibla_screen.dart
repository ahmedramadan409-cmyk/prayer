import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/qibla_math.dart';
import '../../prayer_times/models/prayer_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasCompassSensor = true;

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final city = prayerProvider.selectedCity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // حساب زاوية القبلة والمسافة للكعبة من موقع المدينة المحددة
    final qiblaBearing = QiblaMath.calculateQiblaBearing(city.latitude, city.longitude);
    final distanceKm = QiblaMath.calculateDistanceToKaabaKm(city.latitude, city.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة المشرفة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // بطاقة بيانات المدينة والمسافة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mosque, color: AppColors.accentGold, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الموقع: ${city.cityNameAr} (${city.governorateAr})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'زاوية القبلة: ${qiblaBearing.toStringAsFixed(1)}° من الشمال',
                            style: const TextStyle(
                              color: AppColors.primaryDarkGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'المسافة إلى مكة: ${distanceKm.round()} كم تقريباً',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // البوصلة التفاعلية
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    (snapshot.connectionState == ConnectionState.active &&
                        snapshot.data?.heading == null)) {
                  // الجهاز لا يحتوي على مستشعر بوصلة مغناطيسي
                  return _buildFallbackCompass(qiblaBearing, isDark);
                }

                final heading = snapshot.data?.heading;
                if (heading == null) {
                  return const SizedBox(
                    height: 280,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryDarkGreen),
                    ),
                  );
                }

                // حساب زاوية دوران مؤشر القبلة
                final needleAngle = QiblaMath.calculateNeedleAngle(
                  qiblaBearing: qiblaBearing,
                  compassHeading: heading,
                );

                final isAligned = needleAngle.abs() < 4.0;

                return Column(
                  children: [
                    // حالة المحاذاة
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAligned
                            ? AppColors.successGreen.withOpacity(0.15)
                            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAligned ? AppColors.successGreen : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        isAligned ? 'أنت تتجه الآن نحو القبلة تماماً ✓' : 'وجّه هاتفك حتى يتطابق المؤشر الذهبي',
                        style: TextStyle(
                          color: isAligned ? AppColors.successGreen : (isDark ? Colors.white70 : Colors.black80),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الرسم الدائري للبوصلة
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // قرص البوصلة (يدور عكس اتجاه الهاتف ليشير للشمال الحقيقي)
                          Transform.rotate(
                            angle: ((-heading) * (math.pi / 180.0)),
                            child: _buildCompassDial(isDark),
                          ),

                          // مؤشر القبلة الذهبي نحو الكعبة
                          Transform.rotate(
                            angle: (needleAngle * (math.pi / 180.0)),
                            child: _buildKaabaNeedle(),
                          ),

                          // مركز البوصلة
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDarkGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accentGold, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'اتجاه الهاتف الحالي: ${heading.round()}°',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // بطاقة تعليمات المعايرة وتنبيه الدقة
            Card(
              color: isDark ? const Color(0xFF152A1E) : const Color(0xFFF3F7F4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates, color: AppColors.accentGold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'إرشادات لدقة أعلى في تحديد القبلة:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• ابتعد عن الأجسام المعدنية والمغناطيسية والأسطح الكهربائية أثناء تحديد الاتجاه.\n'
                      '• إذا لاحظت عدم استقرار المؤشر، حرّك الهاتف في الهواء على شكل رقم 8 (ثمانية بالإنجليزية) لمعايرة مستشعر البوصلة.\n'
                      '• دقة القبلة تعتمد كلياً على جودة ومعايرة مستشعر الهاتف الداخلي.',
                      style: TextStyle(fontSize: 12.5, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassDial(bool isDark) {
    return Container(
      width: 270,
      height: 270,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF13281E) : Colors.white,
        border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // الحروف الأربعة (شمال، شرق، جنوب، غرب)
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'ش (N)',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'ق (E)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'ج (S)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'غ (W)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaabaNeedle() {
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          // رأس السهم المتجه للكعبة مع أيقونة الكعبة
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.accentGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.navigation,
              color: AppColors.black,
              size: 22,
            ),
          ),
          Container(
            width: 4,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.accentGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFallbackCompass(double qiblaBearing, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber, width: 0.8),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'مستشعر البوصلة المغناطيسي غير متوفر أو غير مدعوم على هذا الجهاز. يمكنك الاسترشاد بدرجة القبلة الموضحة أدناه بالنسبة للشمال.',
                  style: TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF13281E) : Colors.white,
            border: Border.all(color: AppColors.accentGold, width: 3),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore, size: 50, color: AppColors.accentGold),
                const SizedBox(height: 8),
                Text(
                  '${qiblaBearing.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                const Text(
                  'جنوب شرق بالنسبة للشمال',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
