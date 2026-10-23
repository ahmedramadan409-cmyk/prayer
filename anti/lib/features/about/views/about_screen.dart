import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('عن تطبيق صلاتي مصر'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // شعار التطبيق
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDarkGreen.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mosque, size: 44, color: AppColors.accentGold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'صلاتي مصر | Salaty Egypt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإصدار 1.0.0 (مستقر ومجاني بالكامل)',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // بطاقة الخصوصية والمجانية
          Card(
            color: isDark ? const Color(0xFF132A1E) : const Color(0xFFF1F8F3),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.volunteer_activism, color: AppColors.accentGold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'تطبيق مجاني 100% لوجه الله تعالى',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'هذا التطبيق مخصص بالكامل لخدمة المسلمين في جمهورية مصر العربية وخارجها، مجاني وخالٍ تماماً من أي إعلانات مزعجة أو اشتراكات مدفوعة أو طلبات تسجيل حساب.',
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // الخصوصية وعدم جمع البيانات
          Card(
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip, color: AppColors.primaryDarkGreen, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'سياسة الخصوصية وحماية البيانات',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• لا يقوم التطبيق بجمع أو إرسال أي بيانات شخصية أو موقع جغرافي لأي خادم خارجي.\n'
                    '• يتم استخدام موقع GPS - في حال وافق المستخدم على منحه - محلياً فقط على الجهاز لتحديد أقرب محافظة مصرية.\n'
                    '• يمكن استخدام التطبيق بكامل وظائفه عبر اختيار المدينة يدوياً دون الحاجة لمنح إذن الموقع.\n'
                    '• كافة الحسابات والتنبيهات تتم محلياً في هاتفك وتعمل دون إنترنت.',
                    style: TextStyle(fontSize: 12.5, height: 1.7),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // تراخيص الصوت
          Card(
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.library_music, color: AppColors.primaryDarkGreen, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'حقوق وتراخيص الملفات الصوتية',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'جميع تسجيلات الأذان والتكبيرات المضمنة في التطبيق مأخوذة من تسجيلات المشاع الإبداعي المرخصة للنفع العام وغير التجاري (Creative Commons / Public Domain) مع كامل التقدير لكبار مؤذني مصر والعالم الإسلامي.',
                    style: TextStyle(fontSize: 12.5, height: 1.6),
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
}
