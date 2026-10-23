/// بيانات المحافظات والمدن والمراكز في جمهورية مصر العربية
/// مع الإحداثيات الجغرافية المعتمدة
class EgyptianCity {
  final String id;
  final String governorateAr;
  final String cityNameAr;
  final String cityNameEn;
  final double latitude;
  final double longitude;
  final bool isGovernorateCapital;

  const EgyptianCity({
    required this.id,
    required this.governorateAr,
    required this.cityNameAr,
    required this.cityNameEn,
    required this.latitude,
    required this.longitude,
    this.isGovernorateCapital = false,
  });

  @override
  String toString() => '$cityNameAr ($governorateAr)';
}

class EgyptCitiesDatabase {
  static const EgyptianCity defaultCity = EgyptianCity(
    id: 'cairo',
    governorateAr: 'القاهرة',
    cityNameAr: 'القاهرة',
    cityNameEn: 'Cairo',
    latitude: 30.0444,
    longitude: 31.2357,
    isGovernorateCapital: true,
  );

  static const List<EgyptianCity> allCities = [
    // 1. القاهرة
    EgyptianCity(
      id: 'cairo',
      governorateAr: 'القاهرة',
      cityNameAr: 'القاهرة',
      cityNameEn: 'Cairo',
      latitude: 30.0444,
      longitude: 31.2357,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'cairo_new_cairo',
      governorateAr: 'القاهرة',
      cityNameAr: 'القاهرة الجديدة والتجمع',
      cityNameEn: 'New Cairo',
      latitude: 30.0276,
      longitude: 31.4913,
    ),
    EgyptianCity(
      id: 'cairo_helwan',
      governorateAr: 'القاهرة',
      cityNameAr: 'حلوان',
      cityNameEn: 'Helwan',
      latitude: 29.8414,
      longitude: 31.3008,
    ),
    EgyptianCity(
      id: 'cairo_shorouk',
      governorateAr: 'القاهرة',
      cityNameAr: 'الشروق وبدر',
      cityNameEn: 'El Shorouk',
      latitude: 30.1444,
      longitude: 31.6358,
    ),

    // 2. الجيزة
    EgyptianCity(
      id: 'giza',
      governorateAr: 'الجيزة',
      cityNameAr: 'الجيزة',
      cityNameEn: 'Giza',
      latitude: 30.0131,
      longitude: 31.2089,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'giza_october',
      governorateAr: 'الجيزة',
      cityNameAr: 'مدينة 6 أكتوبر والشيخ زايد',
      cityNameEn: '6th of October',
      latitude: 29.9737,
      longitude: 30.9529,
    ),
    EgyptianCity(
      id: 'giza_ayat',
      governorateAr: 'الجيزة',
      cityNameAr: 'العياط والصف',
      cityNameEn: 'El Ayat',
      latitude: 29.6200,
      longitude: 31.2600,
    ),
    EgyptianCity(
      id: 'giza_bahariya',
      governorateAr: 'الجيزة',
      cityNameAr: 'الواحات البحرية',
      cityNameEn: 'Bahariya Oasis',
      latitude: 28.3547,
      longitude: 28.8686,
    ),

    // 3. الإسكندرية
    EgyptianCity(
      id: 'alexandria',
      governorateAr: 'الإسكندرية',
      cityNameAr: 'الإسكندرية',
      cityNameEn: 'Alexandria',
      latitude: 31.2001,
      longitude: 29.9187,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'alex_borg_arab',
      governorateAr: 'الإسكندرية',
      cityNameAr: 'برج العرب',
      cityNameEn: 'Borg El Arab',
      latitude: 30.9167,
      longitude: 29.5333,
    ),

    // 4. القليوبية
    EgyptianCity(
      id: 'banha',
      governorateAr: 'القليوبية',
      cityNameAr: 'بنها',
      cityNameEn: 'Banha',
      latitude: 30.4660,
      longitude: 31.1853,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'shubra_el_kheima',
      governorateAr: 'القليوبية',
      cityNameAr: 'شبرا الخيمة',
      cityNameEn: 'Shubra El Kheima',
      latitude: 30.1286,
      longitude: 31.2422,
    ),

    // 5. بورسعيد
    EgyptianCity(
      id: 'port_said',
      governorateAr: 'بورسعيد',
      cityNameAr: 'بورسعيد',
      cityNameEn: 'Port Said',
      latitude: 31.2653,
      longitude: 32.3019,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'port_fouad',
      governorateAr: 'بورسعيد',
      cityNameAr: 'بورفؤاد',
      cityNameEn: 'Port Fouad',
      latitude: 31.2497,
      longitude: 32.3275,
    ),

    // 6. السويس
    EgyptianCity(
      id: 'suez',
      governorateAr: 'السويس',
      cityNameAr: 'السويس',
      cityNameEn: 'Suez',
      latitude: 29.9668,
      longitude: 32.5498,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'ain_sokhna',
      governorateAr: 'السويس',
      cityNameAr: 'العين السخنة',
      cityNameEn: 'Ain Sokhna',
      latitude: 29.6000,
      longitude: 32.3167,
    ),

    // 7. الإسماعيلية
    EgyptianCity(
      id: 'ismailia',
      governorateAr: 'الإسماعيلية',
      cityNameAr: 'الإسماعيلية',
      cityNameEn: 'Ismailia',
      latitude: 30.5965,
      longitude: 32.2715,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'fayed',
      governorateAr: 'الإسماعيلية',
      cityNameAr: 'فايد والتل الكبير',
      cityNameEn: 'Fayed',
      latitude: 30.3278,
      longitude: 32.2989,
    ),

    // 8. الدقهلية
    EgyptianCity(
      id: 'mansoura',
      governorateAr: 'الدقهلية',
      cityNameAr: 'المنصورة',
      cityNameEn: 'Mansoura',
      latitude: 31.0409,
      longitude: 31.3785,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'mit_ghamr',
      governorateAr: 'الدقهلية',
      cityNameAr: 'ميت غمر والسنبلاوين',
      cityNameEn: 'Mit Ghamr',
      latitude: 30.7194,
      longitude: 31.2625,
    ),

    // 9. الشرقية
    EgyptianCity(
      id: 'zagazig',
      governorateAr: 'الشرقية',
      cityNameAr: 'الزقازيق',
      cityNameEn: 'Zagazig',
      latitude: 30.5877,
      longitude: 31.5020,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'tenth_of_ramadan',
      governorateAr: 'الشرقية',
      cityNameAr: 'العاشر من رمضان وبلبيس',
      cityNameEn: '10th of Ramadan',
      latitude: 30.3000,
      longitude: 31.7500,
    ),

    // 10. الغربية
    EgyptianCity(
      id: 'tanta',
      governorateAr: 'الغربية',
      cityNameAr: 'طنطا',
      cityNameEn: 'Tanta',
      latitude: 30.7865,
      longitude: 31.0004,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'mahalla',
      governorateAr: 'الغربية',
      cityNameAr: 'المحلة الكبرى',
      cityNameEn: 'El Mahalla El Kubra',
      latitude: 30.9706,
      longitude: 31.1669,
    ),

    // 11. المنوفية
    EgyptianCity(
      id: 'shibin_el_kom',
      governorateAr: 'المنوفية',
      cityNameAr: 'شبين الكوم',
      cityNameEn: 'Shibin El Kom',
      latitude: 30.5599,
      longitude: 31.0118,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'sadat_city',
      governorateAr: 'المنوفية',
      cityNameAr: 'مدينة السادات وأشمون',
      cityNameEn: 'Sadat City',
      latitude: 30.3800,
      longitude: 30.5200,
    ),

    // 12. دمياط
    EgyptianCity(
      id: 'damietta',
      governorateAr: 'دمياط',
      cityNameAr: 'دمياط ورأس البر',
      cityNameEn: 'Damietta',
      latitude: 31.4175,
      longitude: 31.8144,
      isGovernorateCapital: true,
    ),

    // 13. كفر الشيخ
    EgyptianCity(
      id: 'kafr_el_sheikh',
      governorateAr: 'كفر الشيخ',
      cityNameAr: 'كفر الشيخ',
      cityNameEn: 'Kafr El Sheikh',
      latitude: 31.1107,
      longitude: 30.9388,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'desouk',
      governorateAr: 'كفر الشيخ',
      cityNameAr: 'دسوق وبلطيم',
      cityNameEn: 'Desouk',
      latitude: 31.1306,
      longitude: 30.6481,
    ),

    // 14. البحيرة
    EgyptianCity(
      id: 'damanhur',
      governorateAr: 'البحيرة',
      cityNameAr: 'دمنهور',
      cityNameEn: 'Damanhur',
      latitude: 31.0425,
      longitude: 30.4687,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'wadi_natrun',
      governorateAr: 'البحيرة',
      cityNameAr: 'وادي النطرون وكفر الدوار',
      cityNameEn: 'Wadi El Natrun',
      latitude: 30.3833,
      longitude: 30.3500,
    ),

    // 15. الفيوم
    EgyptianCity(
      id: 'faiyum',
      governorateAr: 'الفيوم',
      cityNameAr: 'الفيوم',
      cityNameEn: 'Faiyum',
      latitude: 29.3084,
      longitude: 30.8428,
      isGovernorateCapital: true,
    ),

    // 16. بني سويف
    EgyptianCity(
      id: 'beni_suef',
      governorateAr: 'بني سويف',
      cityNameAr: 'بني سويف والواسطى',
      cityNameEn: 'Beni Suef',
      latitude: 29.0661,
      longitude: 31.0994,
      isGovernorateCapital: true,
    ),

    // 17. المنيا
    EgyptianCity(
      id: 'minya',
      governorateAr: 'المنيا',
      cityNameAr: 'المنيا وملوي',
      cityNameEn: 'Minya',
      latitude: 28.0871,
      longitude: 30.7618,
      isGovernorateCapital: true,
    ),

    // 18. أسيوط
    EgyptianCity(
      id: 'asyut',
      governorateAr: 'أسيوط',
      cityNameAr: 'أسيوط وديروط',
      cityNameEn: 'Asyut',
      latitude: 27.1809,
      longitude: 31.1837,
      isGovernorateCapital: true,
    ),

    // 19. سوهاج
    EgyptianCity(
      id: 'sohag',
      governorateAr: 'سوهاج',
      cityNameAr: 'سوهاج وطهطا وجرجا',
      cityNameEn: 'Sohag',
      latitude: 26.5591,
      longitude: 31.6957,
      isGovernorateCapital: true,
    ),

    // 20. قنا
    EgyptianCity(
      id: 'qena',
      governorateAr: 'قنا',
      cityNameAr: 'قنا ونجع حمادي',
      cityNameEn: 'Qena',
      latitude: 26.1551,
      longitude: 32.7160,
      isGovernorateCapital: true,
    ),

    // 21. الأقصر
    EgyptianCity(
      id: 'luxor',
      governorateAr: 'الأقصر',
      cityNameAr: 'الأقصر وإسنا وأرمنت',
      cityNameEn: 'Luxor',
      latitude: 25.6872,
      longitude: 32.6396,
      isGovernorateCapital: true,
    ),

    // 22. أسوان
    EgyptianCity(
      id: 'aswan',
      governorateAr: 'أسوان',
      cityNameAr: 'أسوان وإدفو وكوم أمبو',
      cityNameEn: 'Aswan',
      latitude: 24.0889,
      longitude: 32.8998,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'abu_simbel',
      governorateAr: 'أسوان',
      cityNameAr: 'أبو سمبل وتوشكى',
      cityNameEn: 'Abu Simbel',
      latitude: 22.3470,
      longitude: 31.6111,
    ),

    // 23. البحر الأحمر
    EgyptianCity(
      id: 'hurghada',
      governorateAr: 'البحر الأحمر',
      cityNameAr: 'الغردقة',
      cityNameEn: 'Hurghada',
      latitude: 27.2579,
      longitude: 33.8116,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'safaga',
      governorateAr: 'البحر الأحمر',
      cityNameAr: 'سفاجا والقصير',
      cityNameEn: 'Safaga',
      latitude: 26.7328,
      longitude: 33.9364,
    ),
    EgyptianCity(
      id: 'marsa_alam',
      governorateAr: 'البحر الأحمر',
      cityNameAr: 'مرسى علم',
      cityNameEn: 'Marsa Alam',
      latitude: 25.0676,
      longitude: 34.8790,
    ),
    EgyptianCity(
      id: 'shalateen',
      governorateAr: 'البحر الأحمر',
      cityNameAr: 'شلاتين وحلايب',
      cityNameEn: 'Shalateen',
      latitude: 23.1317,
      longitude: 35.5861,
    ),

    // 24. مطروح
    EgyptianCity(
      id: 'marsa_matruh',
      governorateAr: 'مطروح',
      cityNameAr: 'مرسى مطروح',
      cityNameEn: 'Marsa Matruh',
      latitude: 31.3543,
      longitude: 27.2373,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'el_alamein',
      governorateAr: 'مطروح',
      cityNameAr: 'العلمين والضبعة',
      cityNameEn: 'El Alamein',
      latitude: 30.8333,
      longitude: 28.9500,
    ),
    EgyptianCity(
      id: 'siwa',
      governorateAr: 'مطروح',
      cityNameAr: 'سيوة',
      cityNameEn: 'Siwa Oasis',
      latitude: 29.2032,
      longitude: 25.5195,
    ),
    EgyptianCity(
      id: 'sallum',
      governorateAr: 'مطروح',
      cityNameAr: 'السلوم',
      cityNameEn: 'Sallum',
      latitude: 31.5500,
      longitude: 25.1500,
    ),

    // 25. الوادي الجديد
    EgyptianCity(
      id: 'kharga',
      governorateAr: 'الوادي الجديد',
      cityNameAr: 'الخارجة',
      cityNameEn: 'El Kharga',
      latitude: 25.4404,
      longitude: 30.5589,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'dakhla',
      governorateAr: 'الوادي الجديد',
      cityNameAr: 'الداخلة والفرافرة',
      cityNameEn: 'Dakhla Oasis',
      latitude: 25.5200,
      longitude: 28.9800,
    ),

    // 26. شمال سيناء
    EgyptianCity(
      id: 'arish',
      governorateAr: 'شمال سيناء',
      cityNameAr: 'العريش',
      cityNameEn: 'El Arish',
      latitude: 31.1325,
      longitude: 33.8033,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'rafah_egypt',
      governorateAr: 'شمال سيناء',
      cityNameAr: 'رفح والشيخ زويد وبئر العبد',
      cityNameEn: 'Rafah',
      latitude: 31.2823,
      longitude: 34.2442,
    ),

    // 27. جنوب سيناء
    EgyptianCity(
      id: 'sharm_el_sheikh',
      governorateAr: 'جنوب سيناء',
      cityNameAr: 'شرم الشيخ',
      cityNameEn: 'Sharm El Sheikh',
      latitude: 27.9158,
      longitude: 34.3299,
    ),
    EgyptianCity(
      id: 'tor_sinai',
      governorateAr: 'جنوب سيناء',
      cityNameAr: 'طور سيناء',
      cityNameEn: 'El Tor',
      latitude: 28.2394,
      longitude: 33.6231,
      isGovernorateCapital: true,
    ),
    EgyptianCity(
      id: 'dahab_nuweiba',
      governorateAr: 'جنوب سيناء',
      cityNameAr: 'دهب ونويبع وطابا',
      cityNameEn: 'Dahab',
      latitude: 28.5095,
      longitude: 34.5136,
    ),
    EgyptianCity(
      id: 'saint_catherine',
      governorateAr: 'جنوب سيناء',
      cityNameAr: 'سانت كاترين ورأس سدر',
      cityNameEn: 'Saint Catherine',
      latitude: 28.5639,
      longitude: 33.9514,
    ),
  ];

  static EgyptianCity findById(String id) {
    return allCities.firstWhere(
      (c) => c.id == id,
      orElse: () => defaultCity,
    );
  }

  static List<EgyptianCity> search(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return allCities;
    return allCities.where((c) {
      return c.cityNameAr.toLowerCase().contains(clean) ||
          c.governorateAr.toLowerCase().contains(clean) ||
          c.cityNameEn.toLowerCase().contains(clean);
    }).toList();
  }

  /// البحث عن أقرب مدينة لموقع جغرافي (GPS)
  static EgyptianCity findNearest(double lat, double lng) {
    EgyptianCity nearest = defaultCity;
    double minDistance = double.infinity;

    for (final city in allCities) {
      final dLat = city.latitude - lat;
      final dLng = city.longitude - lng;
      final distSquared = dLat * dLat + dLng * dLng;
      if (distSquared < minDistance) {
        minDistance = distSquared;
        nearest = city;
      }
    }
    return nearest;
  }
}
