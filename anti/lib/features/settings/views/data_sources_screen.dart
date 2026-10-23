import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DataSourcesScreen extends StatelessWidget {
  const DataSourcesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مصادر البيانات ودقة المواقيت'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Card(
            color: isDark ? const Color(0xFF132A1E) : const Color(0xFFF1F8F3),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user, color: AppColors.accentGold, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'المرجعية الفلكية المعتمدة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'يعتمد تطبيق «صلاتي مصر» بشكل أساسي ودقيق على المعايير والحسابات الفلكية الصادرة عن الهيئة المصرية العامة للمساحة، وهي الجهة الرسمية الوحيدة المنوط بها إعداد ونشر التقاويم ومواقيت الصلاة في جمهورية مصر العربية بالتعاون مع دار الإفتاء المصرية ومجمع البحوث الإسلامية بالأزهر الشريف.',
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'المعايير والزوايا الفلكية المطبقة بالتفصيل:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _buildParamCard(
            context,
            prayerName: 'الفجر',
            angle: '19.5° تحت الأفق',
            description: 'انخفاض الشمس بزاوية 19 درجة ونصف تحت الأفق الشرقي (زاوية الفجر الصادق المعتمدة في مصر).',
          ),
          _buildParamCard(
            context,
            prayerName: 'الشروق',
            angle: '50 دقيقة قوسية (0.8333°)',
            description: 'لحظة ملامسة الحافة العليا لقرص الشمس للأفق، مع مراعاة الانكسار الضوئي (34\') ونصف قطر الشمس (16\').',
          ),
          _buildParamCard(
            context,
            prayerName: 'الظهر',
            angle: 'زوال الشمس + دقيقة احتياطية',
            description: 'مرور الشمس بخط الزوال السماوي مع إضافة دقيقة واحدة كاحتياط شرعي للتحقق من زوال الشمس عن كبد السماء.',
          ),
          _buildParamCard(
            context,
            prayerName: 'العصر',
            angle: 'ظل المثل = 1 (المذهب الشافعي)',
            description: 'عندما يصير ظل كل شيء مثله مضافاً إليه ظل الزوال، وهو المعتمد في الفتوى الرسمية المصرية.',
          ),
          _buildParamCard(
            context,
            prayerName: 'المغرب',
            angle: 'غروب الشمس + دقيقتان احتياط',
            description: 'لحظة اختفاء كامل قرص الشمس تحت الأفق مع إضافة دقيقتين احتياطيتين معتمدتين لدى المساحة المصرية.',
          ),
          _buildParamCard(
            context,
            prayerName: 'العشاء',
            angle: '17.5° تحت الأفق',
            description: 'انخفاض مركز قرص الشمس بزاوية 17 درجة ونصف تحت الأفق الغربي (مغيب الشفق الأحمر).',
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بنية البيانات والعمل دون إنترنت (Offline-First)',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'صُمم التطبيق ببنية مستقلة نظيفة (Clean Architecture) تفصل تماماً بين واجهة المستخدم ومحرك الحساب الفلكي. يعمل محرك الحساب المحلي على جهازك ذاتياً دون الحاجة إلى الاتصال بأي خادم أو استهلاك باقة الإنترنت، مما يمنع انقطاع المواقيت أو عرض بيانات وهمية.',
                    style: TextStyle(fontSize: 12.5, height: 1.6, color: isDark ? Colors.white70 : Colors.black87),
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

  Widget _buildParamCard(
    BuildContext context, {
    required String prayerName,
    required String angle,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryDarkGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prayerName,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    angle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.accentGoldDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
