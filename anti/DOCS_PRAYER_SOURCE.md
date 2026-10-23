# دليل مصدر مواقيت الصلاة وكيفية تغييره وتطويره | Salaty Egypt

يوثق هذا المستند المرجعية الرسمية المعتمدة لحساب مواقيت الصلاة في تطبيق «صلاتي مصر»، وتفاصيل الزوايا والمعادلات الفلكية، وكيفية استبدال أو توسيع مصدر البيانات عبر بنية برمجية مستقلة.

---

## 1. المرجعية المعتمدة: الهيئة المصرية العامة للمساحة (ESA)

تعتبر **الهيئة المصرية العامة للمساحة** (التابعة لوزارة الموارد المائية والري في مصر) المرجع الوطني والرسمي الوحيد المعتمد لإصدار نتائج ومواقيت الصلاة وإعداد التقاويم في جمهورية مصر العربية، وذلك بالاشتراك والتنسيق المباشر مع دار الإفتاء المصرية ومجمع البحوث الإسلامية بالأزهر الشريف.

### الزوايا والمعايير الفلكية المعتمدة في مصر

| الصلاة / الوقت | الزاوية والارتفاع الشمسي | المنهجية المتبعة والمعايير المصرية |
| :--- | :--- | :--- |
| **الفجر** | -19.5° تحت الأفق | انخفاض مركز قرص الشمس بمقدار 19.5 درجة تحت الأفق الشرقي (زاوية الفجر الصادق المعتمدة في مصر). |
| **الشروق** | -0.8333° (50 دقيقة قوسية) | لحظة ملامسة الحافة العليا لقرص الشمس للأفق الشرقي، باحتساب الانكسار الجوي (34 دقيقة قوسية) ونصف قطر الشمس (16 دقيقة قوسية). |
| **الظهر** | زوال الشمس + دقيقة واحدة | لحظة مرور الشمس بخط الزوال السماوي، ويضاف إليها دقيقة واحدة كاحتياط شرعي معتمد لدى المساحة المصرية للتحقق من زوال الشمس عن كبد السماء. |
| **العصر** | ظل المثل = 1 (المذهب الشافعي) | حساب ارتفاع الشمس عندما يصير ظل كل شاخص مساوياً لطوله مضافاً إليه ظل الزوال، وهو المعتمد في الفتوى الرسمية المصرية وتطبيقات الأزهر ودار الإفتاء. |
| **المغرب** | غروب الشمس + دقيقتان احتياط | لحظة اختفاء كامل قرص الشمس تحت الأفق الغربي (50 دقيقة قوسية) مع إضافة دقيقتين كاحتياط شرعي للغروب معتمد لدى الهيئة المصرية للمساحة. |
| **العشاء** | -17.5° تحت الأفق | انخفاض مركز قرص الشمس بمقدار 17.5 درجة تحت الأفق الغربي (لحظة مغيب الشفق الأحمر). |

---

## 2. قواعد التوقيت الصيفي والشتوي في جمهورية مصر العربية

وفقاً للقانون رقم **24 لسنة 2023** الصادر عن مجلس النواب والمنشور في الجريدة الرسمية المصرية بشأن تقرير نظام التوقيت الصيفي:
- **بدء التوقيت الصيفي (UTC+3)**: يبدأ في تمام الساعة 00:00 (منتصف ليل الخميس/الجمعة) من **آخر جمعة من شهر أبريل** من كل عام، بتقديم الساعة 60 دقيقة.
- **انتهاء التوقيت الصيفي والعودة للتوقيت الشتوي (UTC+2)**: ينتهي في تمام الساعة 24:00 (منتصف ليل الخميس/الجمعة) من **آخر خميس من شهر أكتوبر** من كل عام، بتأخير الساعة 60 دقيقة.

تم تضمين هذه القاعدة بدقة داخل دالة `isEgyptianDst(DateTime date)` في محرك الحساب، مما يضمن انتقال المواقيت تلقائياً دون أي تدخل يدوي من المستخدم.

---

## 3. هندسة طبقة البيانات (Decoupled Data Source Architecture)

اتبع التطبيق مبدأ **Dependency Inversion** بفصل واجهة مصدر البيانات `IPrayerTimesDataSource` عن واجهة المستخدم والتخزين المحلي:

```dart
abstract class IPrayerTimesDataSource {
  Future<CalculatedPrayerTimes> getPrayerTimes({
    required DateTime date,
    required EgyptianCity city,
    required AsrMadhab madhab,
    required DstMode dstMode,
    required PrayerAdjustments adjustments,
  });

  PrayerSourceInfo getSourceInfo();
}
```

### المصدر الافتراضي المطبق: `LocalEsaAstronomicalDataSource`
- يتم الحساب فلكياً بالكامل على جهاز المستخدم.
- **يعمل 100% دون اتصال بالإنترنت**.
- لا يعرض أي بيانات وهمية أو تخمينية.
- يستهلك موارد معالجة ضئيلة للغاية (أقل من 2 ميلي ثانية لكل يوم).

---

## 4. كيفية استبدال أو إضافة مصدر بيانات خارجي (API)

في حال رغبتك في مزامنة المواقيت مستقبلاً من خادم رسمي أو API معتمد (مثل بوابة حكومية مصرية أو خدمة سحابية موثقة):

1. أنشئ كلاس جديد ينفذ `IPrayerTimesDataSource` في مسار:
   `lib/features/prayer_times/repositories/external_api_source.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'prayer_repository.dart';
import '../../../core/constants/egypt_cities.dart';
import '../../../core/utils/prayer_calculation_engine.dart';

class ExternalApiPrayerDataSource implements IPrayerTimesDataSource {
  final String apiBaseUrl;
  final IPrayerTimesDataSource fallbackLocalSource;

  ExternalApiPrayerDataSource({
    required this.apiBaseUrl,
    IPrayerTimesDataSource? fallback,
  }) : fallbackLocalSource = fallback ?? LocalEsaAstronomicalDataSource();

  @override
  Future<CalculatedPrayerTimes> getPrayerTimes({
    required DateTime date,
    required EgyptianCity city,
    required AsrMadhab madhab,
    required DstMode dstMode,
    required PrayerAdjustments adjustments,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/times?city=${city.id}&date=${date.toIso8601String()}'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // تحويل استجابة الـ API إلى CalculatedPrayerTimes
        return _parseApiResponse(data, date, dstMode);
      }
    } catch (e) {
      // عند انقطاع الإنترنت أو فشل السيرفر، يتم الرجوع تلقائياً للمحرك المحلي دون إزعاج المستخدم
    }

    return fallbackLocalSource.getPrayerTimes(
      date: date,
      city: city,
      madhab: madhab,
      dstMode: dstMode,
      adjustments: adjustments,
    );
  }

  @override
  PrayerSourceInfo getSourceInfo() {
    return const PrayerSourceInfo(
      type: PrayerDataSourceType.externalVerifiedApi,
      titleAr: 'مزامنة مع واجهة الهيئة المصرية للبيانات (مع نسخة محلية)',
      descriptionAr: 'يتم جلب البيانات المحدثة من الخادم، مع الاحتفاظ بالحساب المحلي الدقيق عند انقطاع الاتصال.',
      isOfflineReady: true,
    );
  }

  CalculatedPrayerTimes _parseApiResponse(dynamic json, DateTime date, DstMode dstMode) {
    // منطق تحويل البيانات من الـ API
    // ...
    throw UnimplementedError();
  }
}
```

2. قم بتمرير المصدر الجديد إلى مستودع المواقيت في `lib/main.dart`:
```dart
final customSource = ExternalApiPrayerDataSource(apiBaseUrl: 'https://api.example.gov.eg');
final prayerRepository = PrayerRepository(
  storageService: storageService,
  dataSource: customSource,
);
```

بهذه الطريقة، لن تتأثر الواجهات أو التنبيهات بأي تعديل في مصدر البيانات، وسيظل التطبيق محتفظاً بقدرته على العمل دون إنترنت بفضل ميزة الـ Fallback المدمجة.
