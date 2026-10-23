import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/egypt_cities.dart';
import '../../prayer_times/models/prayer_provider.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({Key? key}) : super(key: key);

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<EgyptianCity> _filteredCities = EgyptCitiesDatabase.allCities;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCities = EgyptCitiesDatabase.search(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final selectedCity = prayerProvider.selectedCity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحافظات والمدن المصرية'),
      ),
      body: Column(
        children: [
          // زر التحديد التلقائي للموقع عبر GPS
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await prayerProvider.detectLocation();
                      if (!mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تحديد موقعك بنجاح: ${prayerProvider.selectedCity.cityNameAr}',
                            ),
                            backgroundColor: AppColors.primaryDarkGreen,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تعذر تحديد الموقع تلقائياً. تأكد من تشغيل GPS ومنح الإذن، أو اختر مدينتك يدوياً من القائمة.',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.my_location, size: 20),
                    label: const Text('تحديد موقعي تلقائياً (GPS)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // حقل البحث
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن محافظة، مدينة، أو مركز...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.accentGold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162C21) : const Color(0xFFEFF3EF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // قائمة المدن والمحافظات
          Expanded(
            child: _filteredCities.isEmpty
                ? const Center(
                    child: Text('لم يتم العثور على أي مدينة مطابقة'),
                  )
                : ListView.builder(
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      final isSelected = city.id == selectedCity.id;

                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentGold
                                : (isDark ? Colors.white10 : AppColors.primaryDarkGreen.withOpacity(0.08)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            city.isGovernorateCapital ? Icons.location_city : Icons.place,
                            size: 18,
                            color: isSelected ? AppColors.black : AppColors.primaryDarkGreen,
                          ),
                        ),
                        title: Text(
                          city.cityNameAr,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? AppColors.accentGold : AppColors.primaryDarkGreen)
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          'محافظة ${city.governorateAr} (${city.cityNameEn})',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.accentGold)
                            : null,
                        onTap: () {
                          prayerProvider.selectCity(city);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
