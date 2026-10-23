# Salaty Egypt - Astronomical & Mathematical Verification Runner
$csharpSource = @"
using System;

namespace SalatyEgypt.Tests
{
    public class PrayerResult
    {
        public DateTime Fajr;
        public DateTime Sunrise;
        public DateTime Dhuhr;
        public DateTime Asr;
        public DateTime Maghrib;
        public DateTime Isha;
        public int Timezone;
    }

    public class SunResult
    {
        public double Declination;
        public double EqOfTime;
    }

    public class EgyptianPrayerCalculator
    {
        public const double FajrAngle = 19.5;
        public const double IshaAngle = 17.5;
        public const double SunRefractionAngle = 0.8333333;

        public static bool IsEgyptianDst(DateTime date)
        {
            int year = date.Year;
            DateTime lastFridayApril = new DateTime(year, 4, 30);
            while (lastFridayApril.DayOfWeek != DayOfWeek.Friday)
            {
                lastFridayApril = lastFridayApril.AddDays(-1);
            }
            DateTime dstStart = new DateTime(year, 4, lastFridayApril.Day, 0, 0, 0);

            DateTime lastThursdayOctober = new DateTime(year, 10, 31);
            while (lastThursdayOctober.DayOfWeek != DayOfWeek.Thursday)
            {
                lastThursdayOctober = lastThursdayOctober.AddDays(-1);
            }
            DateTime dstEnd = new DateTime(year, 10, lastThursdayOctober.Day, 23, 59, 59);

            return date >= dstStart && date <= dstEnd;
        }

        public static PrayerResult Calculate(DateTime date, double lat, double lon, bool forceWinter)
        {
            int tz = forceWinter ? 2 : (IsEgyptianDst(date) ? 3 : 2);
            double jd = JulianDay(date.Year, date.Month, date.Day);
            SunResult sun = SunCoordinates(jd);

            double solarNoonHours = 12.0 + tz - (lon / 15.0) - (sun.EqOfTime / 60.0);
            double dhuhrHours = solarNoonHours + (1.0 / 60.0);

            double sunriseHourAngle = HourAngle(lat, sun.Declination, -SunRefractionAngle);
            double sunriseHours = solarNoonHours - (sunriseHourAngle / 15.0);
            double sunsetHours = solarNoonHours + (sunriseHourAngle / 15.0);
            double maghribHours = sunsetHours + (2.0 / 60.0);

            double fajrHourAngle = HourAngle(lat, sun.Declination, -FajrAngle);
            double fajrHours = solarNoonHours - (fajrHourAngle / 15.0);

            double ishaHourAngle = HourAngle(lat, sun.Declination, -IshaAngle);
            double ishaHours = solarNoonHours + (ishaHourAngle / 15.0);

            double latRad = DegToRad(lat);
            double decRad = DegToRad(sun.Declination);
            double asrAltRad = Math.PI / 2.0 - Math.Atan(1.0 + Math.Tan(Math.Abs(latRad - decRad)));
            double asrAltDeg = RadToDeg(asrAltRad);
            double asrHourAngle = HourAngle(lat, sun.Declination, asrAltDeg);
            double asrHours = solarNoonHours + (asrHourAngle / 15.0);

            PrayerResult res = new PrayerResult();
            res.Fajr = HoursToDateTime(date, fajrHours);
            res.Sunrise = HoursToDateTime(date, sunriseHours);
            res.Dhuhr = HoursToDateTime(date, dhuhrHours);
            res.Asr = HoursToDateTime(date, asrHours);
            res.Maghrib = HoursToDateTime(date, maghribHours);
            res.Isha = HoursToDateTime(date, ishaHours);
            res.Timezone = tz;
            return res;
        }

        public static double CalculateQibla(double lat, double lon)
        {
            const double kaabaLat = 21.422487;
            const double kaabaLon = 39.826206;

            double uLat = DegToRad(lat);
            double uLon = DegToRad(lon);
            double kLat = DegToRad(kaabaLat);
            double kLon = DegToRad(kaabaLon);

            double dLon = kLon - uLon;
            double y = Math.Sin(dLon);
            double x = Math.Cos(uLat) * Math.Tan(kLat) - Math.Sin(uLat) * Math.Cos(dLon);

            double qiblaRad = Math.Atan2(y, x);
            double qiblaDeg = RadToDeg(qiblaRad);
            return (qiblaDeg + 360.0) % 360.0;
        }

        public static double CalculateDistanceToKaaba(double lat, double lon)
        {
            const double kaabaLat = 21.422487;
            const double kaabaLon = 39.826206;
            const double r = 6371.0;

            double lat1 = DegToRad(lat);
            double lon1 = DegToRad(lon);
            double lat2 = DegToRad(kaabaLat);
            double lon2 = DegToRad(kaabaLon);

            double dLat = lat2 - lat1;
            double dLon = lon2 - lon1;

            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                       Math.Cos(lat1) * Math.Cos(lat2) * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return r * c;
        }

        private static double JulianDay(int y, int m, int d)
        {
            if (m <= 2) { y -= 1; m += 12; }
            int a = (int)(y / 100);
            int b = 2 - a + (int)(a / 4);
            return (int)(365.25 * (y + 4716)) + (int)(30.6001 * (m + 1)) + d + b - 1524.5;
        }

        private static SunResult SunCoordinates(double jd)
        {
            double d = jd - 2451545.0;
            double t = d / 36525.0;
            double l0 = FixAngle(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
            double m = FixAngle(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
            double mRad = DegToRad(m);

            double c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * Math.Sin(mRad) +
                       (0.019993 - 0.000101 * t) * Math.Sin(2 * mRad) +
                       0.000289 * Math.Sin(3 * mRad);

            double sunTrueLon = FixAngle(l0 + c);
            double eps0 = 23.439291 - 0.0130042 * t;
            double epsRad = DegToRad(eps0);
            double sunLonRad = DegToRad(sunTrueLon);

            double decRad = Math.Asin(Math.Sin(epsRad) * Math.Sin(sunLonRad));
            double declination = RadToDeg(decRad);

            double raRad = Math.Atan2(Math.Cos(epsRad) * Math.Sin(sunLonRad), Math.Cos(sunLonRad));
            double ra = FixAngle(RadToDeg(raRad));

            double eqTimeDeg = l0 - ra;
            if (eqTimeDeg > 180) eqTimeDeg -= 360;
            if (eqTimeDeg < -180) eqTimeDeg += 360;

            SunResult res = new SunResult();
            res.Declination = declination;
            res.EqOfTime = eqTimeDeg * 4.0;
            return res;
        }

        private static double HourAngle(double lat, double dec, double alt)
        {
            double latRad = DegToRad(lat);
            double decRad = DegToRad(dec);
            double altRad = DegToRad(alt);
            double cosH = (Math.Sin(altRad) - Math.Sin(latRad) * Math.Sin(decRad)) /
                          (Math.Cos(latRad) * Math.Cos(decRad));
            if (cosH > 1.0) return 0;
            if (cosH < -1.0) return 180;
            return RadToDeg(Math.Acos(cosH));
        }

        private static DateTime HoursToDateTime(DateTime d, double h)
        {
            int totalMinutes = (int)Math.Round(h * 60.0);
            int hour = (totalMinutes / 60) % 24;
            int minute = totalMinutes % 60;
            return new DateTime(d.Year, d.Month, d.Day, hour, minute, 0);
        }

        private static double DegToRad(double d) { return d * (Math.PI / 180.0); }
        private static double RadToDeg(double r) { return r * (180.0 / Math.PI); }
        private static double FixAngle(double a)
        {
            double angle = a - 360.0 * Math.Floor(a / 360.0);
            return angle < 0 ? angle + 360.0 : angle;
        }
    }
}
"@

Add-Type -TypeDefinition $csharpSource -Language CSharp

Write-Host "=========================================================="
Write-Host "SALATY EGYPT: ASTRONOMICAL & METHODOLOGY TEST RUNNER"
Write-Host "=========================================================="

$script:passed = 0
$script:failed = 0

function Assert-Test([string]$testName, [bool]$condition, [string]$details) {
    if ($condition) {
        Write-Host " [PASS] $testName" -ForegroundColor Green
        if ($details) { Write-Host "        $details" -ForegroundColor Gray }
        $script:passed++
    } else {
        Write-Host " [FAIL] $testName" -ForegroundColor Red
        if ($details) { Write-Host "        $details" -ForegroundColor Yellow }
        $script:failed++
    }
}

# Test 1: Cairo Winter (UTC+2)
$cairoRes = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::Calculate([DateTime]::Parse("2026-01-15"), 30.0444, 31.2357, $true)
$orderOk = ($cairoRes.Fajr -lt $cairoRes.Sunrise) -and ($cairoRes.Sunrise -lt $cairoRes.Dhuhr) -and ($cairoRes.Dhuhr -lt $cairoRes.Asr) -and ($cairoRes.Asr -lt $cairoRes.Maghrib) -and ($cairoRes.Maghrib -lt $cairoRes.Isha)
Assert-Test "Cairo Winter: UTC+2 and chronological sequence" `
    ($cairoRes.Timezone -eq 2 -and $orderOk) `
    ("Fajr: " + $cairoRes.Fajr.ToString("HH:mm") + " | Shorouk: " + $cairoRes.Sunrise.ToString("HH:mm") + " | Dhuhr: " + $cairoRes.Dhuhr.ToString("HH:mm") + " | Asr: " + $cairoRes.Asr.ToString("HH:mm") + " | Maghrib: " + $cairoRes.Maghrib.ToString("HH:mm") + " | Isha: " + $cairoRes.Isha.ToString("HH:mm"))

# Test 2: Cairo Summer DST (UTC+3)
$summerRes = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::Calculate([DateTime]::Parse("2026-07-15"), 30.0444, 31.2357, $false)
Assert-Test "Cairo Summer: Auto Egyptian DST UTC+3" `
    ($summerRes.Timezone -eq 3 -and $summerRes.Dhuhr.Hour -eq 13) `
    ("Offset: UTC+" + $summerRes.Timezone + " | Dhuhr: " + $summerRes.Dhuhr.ToString("HH:mm") + " | Maghrib: " + $summerRes.Maghrib.ToString("HH:mm"))

# Test 3: Alexandria vs Cairo
$alexRes = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::Calculate([DateTime]::Parse("2026-04-15"), 31.2001, 29.9187, $true)
$cairoSpring = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::Calculate([DateTime]::Parse("2026-04-15"), 30.0444, 31.2357, $true)
Assert-Test "Alexandria (West of Cairo): Maghrib occurs after Cairo" `
    ($alexRes.Maghrib -gt $cairoSpring.Maghrib) `
    ("Cairo Maghrib: " + $cairoSpring.Maghrib.ToString("HH:mm") + " | Alex Maghrib: " + $alexRes.Maghrib.ToString("HH:mm"))

# Test 4: Sharm El-Sheikh vs Cairo
$sharmRes = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::Calculate([DateTime]::Parse("2026-04-15"), 27.9158, 34.3299, $true)
Assert-Test "Sharm El-Sheikh (East of Cairo): Fajr and Maghrib precede Cairo" `
    ($sharmRes.Fajr -lt $cairoSpring.Fajr -and $sharmRes.Maghrib -lt $cairoSpring.Maghrib) `
    ("Sharm Fajr: " + $sharmRes.Fajr.ToString("HH:mm") + " | Cairo Fajr: " + $cairoSpring.Fajr.ToString("HH:mm"))

# Test 5: Aswan (South Egypt)
$aswanRes = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::Calculate([DateTime]::Parse("2026-04-15"), 24.0889, 32.8998, $true)
Assert-Test "Aswan: Proper sequence in Upper Egypt" `
    ($aswanRes.Fajr -lt $aswanRes.Sunrise -and $aswanRes.Asr -lt $aswanRes.Maghrib) `
    ("Aswan Fajr: " + $aswanRes.Fajr.ToString("HH:mm") + " | Aswan Maghrib: " + $aswanRes.Maghrib.ToString("HH:mm"))

# Test 6: Cairo Qibla and Distance to Kaaba
$qiblaCairo = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::CalculateQibla(30.0444, 31.2357)
$distCairo = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::CalculateDistanceToKaaba(30.0444, 31.2357)
Assert-Test "Cairo Qibla Direction (136 deg) and Distance (~1280 km)" `
    ($qiblaCairo -ge 135.5 -and $qiblaCairo -le 137.0 -and $distCairo -ge 1260 -and $distCairo -le 1300) `
    ("Bearing: " + [Math]::Round($qiblaCairo, 2) + " deg | Distance: " + [Math]::Round($distCairo, 0) + " km")

# Test 7: Alexandria and Aswan Qibla
$qiblaAlex = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::CalculateQibla(31.2001, 29.9187)
$qiblaAswan = [SalatyEgypt.Tests.EgyptianPrayerCalculator]::CalculateQibla(24.0889, 32.8998)
Assert-Test "Alexandria (135.4 deg) and Aswan (111.3 deg) Qibla" `
    ($qiblaAlex -ge 134.5 -and $qiblaAlex -le 136.5 -and $qiblaAswan -ge 110.0 -and $qiblaAswan -le 113.0) `
    ("Alex Qibla: " + [Math]::Round($qiblaAlex, 2) + " deg | Aswan Qibla: " + [Math]::Round($qiblaAswan, 2) + " deg")

Write-Host "----------------------------------------------------------"
Write-Host "Results: $script:passed Passed, $script:failed Failed."
Write-Host "=========================================================="
