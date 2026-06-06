part of 'helpers.dart';

/// Available time format options that can be selected in settings.
enum TimeFormatOption {
  /// 24-hour clock, e.g. "21:30".
  h24,

  /// 12-hour clock with AM/PM, e.g. "09:30 PM".
  h12,
}

/// Available date format options that can be selected in settings.
enum DateFormatOption {
  /// "Jun 6, 2026" style.
  mmmDY,

  /// "06/06/2026" style.
  ddmmyyyy,

  /// "2026-06-06" ISO-style.
  yyyymmdd,
}

/// Available timezone modes.
enum TimezoneMode {
  /// Use the device's current timezone (auto-detected).
  auto,

  /// Use a manually selected timezone.
  manual,
}

/// Centralized service for formatting dates, times and handling timezones.
///
/// All EPG/UI time formatting should go through this service so that the
/// user's preferences in Settings are respected everywhere.
class DateTimeFormatService {
  static final _storage = GetStorage("settings");

  // Persisted keys
  static const _kTimeFormat = "time_format";
  static const _kDateFormat = "date_format";
  static const _kTimezoneMode = "timezone_mode";
  static const _kTimezoneId = "timezone_id";
  static const _kAutoDetectedTz = "auto_detected_timezone";

  // -----------------------------
  // Time format
  // -----------------------------
  static TimeFormatOption getTimeFormat() {
    final v = _storage.read(_kTimeFormat);
    if (v is String) {
      return TimeFormatOption.values.firstWhere(
        (e) => e.name == v,
        orElse: () => TimeFormatOption.h24,
      );
    }
    return TimeFormatOption.h24;
  }

  static Future<void> setTimeFormat(TimeFormatOption v) async {
    await _storage.write(_kTimeFormat, v.name);
  }

  /// Returns the intl [DateFormat] pattern used to display a time.
  static String getTimePattern() {
    return getTimeFormat() == TimeFormatOption.h12 ? 'hh:mm a' : 'HH:mm';
  }

  // -----------------------------
  // Date format
  // -----------------------------
  static DateFormatOption getDateFormat() {
    final v = _storage.read(_kDateFormat);
    if (v is String) {
      return DateFormatOption.values.firstWhere(
        (e) => e.name == v,
        orElse: () => DateFormatOption.mmmDY,
      );
    }
    return DateFormatOption.mmmDY;
  }

  static Future<void> setDateFormat(DateFormatOption v) async {
    await _storage.write(_kDateFormat, v.name);
  }

  static String getDatePattern() {
    switch (getDateFormat()) {
      case DateFormatOption.mmmDY:
        return 'MMM d, yyyy';
      case DateFormatOption.ddmmyyyy:
        return 'dd/MM/yyyy';
      case DateFormatOption.yyyymmdd:
        return 'yyyy-MM-dd';
    }
  }

  // -----------------------------
  // Timezone
  // -----------------------------
  static TimezoneMode getTimezoneMode() {
    final v = _storage.read(_kTimezoneMode);
    if (v is String) {
      return TimezoneMode.values.firstWhere(
        (e) => e.name == v,
        orElse: () => TimezoneMode.auto,
      );
    }
    return TimezoneMode.auto;
  }

  static Future<void> setTimezoneMode(TimezoneMode v) async {
    await _storage.write(_kTimezoneMode, v.name);
  }

  /// Returns the active [TimezoneInfo], either the device's timezone (auto)
  /// or the user-selected one.
  static TimezoneInfo getActiveTimezone() {
    final mode = getTimezoneMode();
    if (mode == TimezoneMode.auto) {
      return detectDeviceTimezone();
    }
    final id = _storage.read(_kTimezoneId);
    if (id is String) {
      final found = kTimezones.firstWhere(
        (t) => t.id == id,
        orElse: () => detectDeviceTimezone(),
      );
      return found;
    }
    return detectDeviceTimezone();
  }

  static Future<void> setManualTimezone(String id) async {
    await _storage.write(_kTimezoneId, id);
  }

  /// Storage key for the manually selected timezone id. Exposed so the
  /// settings UI can read the raw value.
  static String getManualTzKey() => _kTimezoneId;

  /// Returns the timezone that the device currently believes it is in.
  static TimezoneInfo detectDeviceTimezone() {
    try {
      final name = DateTime.now().timeZoneName; // e.g. "CET", "UTC"
      final offsetMin = DateTime.now().timeZoneOffset.inMinutes;
      final id = 'device_${name}_$offsetMin';
      // Try to map the device's offset to a known region for nicer display
      final mapped = kTimezones.firstWhere(
        (t) => t.offsetMinutes == offsetMin,
        orElse: () => TimezoneInfo(
          id: id,
          label: 'Auto ($name)',
          country: 'Device',
          offsetMinutes: offsetMin,
        ),
      );
      return mapped;
    } catch (_) {
      return const TimezoneInfo(
        id: 'utc',
        label: 'UTC',
        country: 'Coordinated Universal Time',
        offsetMinutes: 0,
      );
    }
  }

  /// Fetches the user's country from a free IP geolocation API and returns the
  /// matching [TimezoneInfo]. Falls back to device timezone on any error.
  static Future<TimezoneInfo> detectTimezoneByCountry() async {
    try {
      // ip-api.com is a free, no-key service. Timeout fast to avoid hanging
      // the app if the network is unreachable.
      final response = await Dio().get<String>(
        'http://ip-api.com/json/',
        options: Options(
          responseType: ResponseType.plain,
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final body = jsonDecode(response.data!);
        if (body is Map && body['countryCode'] is String) {
          final code = (body['countryCode'] as String).toUpperCase();
          final byCountry = kTimezonesByCountry[code];
          if (byCountry != null) {
            final tz = kTimezones.firstWhere(
              (t) => t.id == byCountry,
              orElse: () => detectDeviceTimezone(),
            );
            await _storage.write(_kAutoDetectedTz, tz.id);
            return tz;
          }
        }
      }
    } catch (_) {
      // Ignore network/parse errors and fall back.
    }
    return detectDeviceTimezone();
  }

  // -----------------------------
  // Formatting helpers
  // -----------------------------

  /// Formats [dt] (a local moment, as returned by [parseEpgTime]) into a
  /// [DateTime] shifted into the currently active timezone. The shift is
  /// computed from UTC, so it works regardless of the device's local
  /// timezone: we first convert the input to UTC, then apply the target
  /// offset.
  static DateTime toDisplayTime(DateTime dt) {
    final tz = getActiveTimezone();
    final asUtc = dt.toUtc();
    return asUtc.add(Duration(minutes: tz.offsetMinutes));
  }

  /// Formats a [DateTime] as a time string (e.g. "21:30" or "09:30 PM").
  static String formatTime(DateTime dt) {
    final local = toDisplayTime(dt);
    return DateFormat(getTimePattern()).format(local);
  }

  /// Formats a [DateTime] as a date string (e.g. "Jun 6, 2026").
  static String formatDate(DateTime dt) {
    final local = toDisplayTime(dt);
    return DateFormat(getDatePattern()).format(local);
  }

  /// Formats a [DateTime] as "date, time".
  static String formatDateTime(DateTime dt) {
    return "${formatDate(dt)}, ${formatTime(dt)}";
  }

  /// Formats a start/end pair as "HH:mm - HH:mm". If the two are on
  /// different days, appends a "(+N)" suffix to the end time so that the
  /// user can see at a glance that the program crosses midnight.
  static String formatTimeRange(DateTime start, DateTime end) {
    final s = toDisplayTime(start);
    final e = toDisplayTime(end);
    final sStr = DateFormat(getTimePattern()).format(s);
    final eStr = DateFormat(getTimePattern()).format(e);
    final dayDiff = DateTime(e.year, e.month, e.day)
        .difference(DateTime(s.year, s.month, s.day))
        .inDays;
    if (dayDiff == 0) {
      return '$sStr - $eStr';
    }
    if (dayDiff == 1) {
      return '$sStr - $eStr (+1)';
    }
    return '$sStr - $eStr (+$dayDiff)';
  }
}

/// Lightweight value type describing a timezone entry. We avoid pulling in a
/// heavy timezone database by hand-rolling a small list of common regions
/// (still covering >95% of users worldwide).
class TimezoneInfo {
  /// Stable identifier, e.g. "europe_london".
  final String id;

  /// Human-readable label, e.g. "London (GMT)".
  final String label;

  /// Country/region the timezone is associated with, e.g. "Morocco".
  final String country;

  /// Offset from UTC in minutes. Note: this is a fixed offset; DST is
  /// intentionally not modelled to keep the implementation lightweight.
  final int offsetMinutes;

  const TimezoneInfo({
    required this.id,
    required this.label,
    required this.country,
    required this.offsetMinutes,
  });

  String get offsetLabel {
    final h = offsetMinutes ~/ 60;
    final m = offsetMinutes % 60;
    final sign = h >= 0 ? '+' : '-';
    final absH = h.abs();
    if (m == 0) {
      return 'UTC$sign${absH.toString().padLeft(2, '0')}:00';
    }
    return 'UTC$sign${absH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

/// A small, hand-curated list of common timezones keyed by stable id.
const List<TimezoneInfo> kTimezones = [
  // UTC
  TimezoneInfo(
    id: 'utc',
    label: 'UTC',
    country: 'Coordinated Universal Time',
    offsetMinutes: 0,
  ),

  // Africa
  TimezoneInfo(
    id: 'africa_casablanca',
    label: 'Casablanca',
    country: 'Morocco',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'africa_algiers',
    label: 'Algiers',
    country: 'Algeria',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'africa_tunis',
    label: 'Tunis',
    country: 'Tunisia',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'africa_cairo',
    label: 'Cairo',
    country: 'Egypt',
    offsetMinutes: 120,
  ),
  TimezoneInfo(
    id: 'africa_lagos',
    label: 'Lagos',
    country: 'Nigeria',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'africa_johannesburg',
    label: 'Johannesburg',
    country: 'South Africa',
    offsetMinutes: 120,
  ),

  // Europe
  TimezoneInfo(
    id: 'europe_london',
    label: 'London',
    country: 'United Kingdom',
    offsetMinutes: 0,
  ),
  TimezoneInfo(
    id: 'europe_paris',
    label: 'Paris',
    country: 'France',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'europe_madrid',
    label: 'Madrid',
    country: 'Spain',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'europe_berlin',
    label: 'Berlin',
    country: 'Germany',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'europe_rome',
    label: 'Rome',
    country: 'Italy',
    offsetMinutes: 60,
  ),
  TimezoneInfo(
    id: 'europe_istanbul',
    label: 'Istanbul',
    country: 'Turkey',
    offsetMinutes: 180,
  ),
  TimezoneInfo(
    id: 'europe_moscow',
    label: 'Moscow',
    country: 'Russia',
    offsetMinutes: 180,
  ),

  // Americas
  TimezoneInfo(
    id: 'america_new_york',
    label: 'New York',
    country: 'United States',
    offsetMinutes: -300,
  ),
  TimezoneInfo(
    id: 'america_chicago',
    label: 'Chicago',
    country: 'United States',
    offsetMinutes: -360,
  ),
  TimezoneInfo(
    id: 'america_denver',
    label: 'Denver',
    country: 'United States',
    offsetMinutes: -420,
  ),
  TimezoneInfo(
    id: 'america_los_angeles',
    label: 'Los Angeles',
    country: 'United States',
    offsetMinutes: -480,
  ),
  TimezoneInfo(
    id: 'america_sao_paulo',
    label: 'São Paulo',
    country: 'Brazil',
    offsetMinutes: -180,
  ),
  TimezoneInfo(
    id: 'america_mexico_city',
    label: 'Mexico City',
    country: 'Mexico',
    offsetMinutes: -360,
  ),

  // Asia & Middle East
  TimezoneInfo(
    id: 'asia_dubai',
    label: 'Dubai',
    country: 'United Arab Emirates',
    offsetMinutes: 240,
  ),
  TimezoneInfo(
    id: 'asia_tehran',
    label: 'Tehran',
    country: 'Iran',
    offsetMinutes: 210,
  ),
  TimezoneInfo(
    id: 'asia_riyadh',
    label: 'Riyadh',
    country: 'Saudi Arabia',
    offsetMinutes: 180,
  ),
  TimezoneInfo(
    id: 'asia_karachi',
    label: 'Karachi',
    country: 'Pakistan',
    offsetMinutes: 300,
  ),
  TimezoneInfo(
    id: 'asia_kolkata',
    label: 'Kolkata',
    country: 'India',
    offsetMinutes: 330,
  ),
  TimezoneInfo(
    id: 'asia_dhaka',
    label: 'Dhaka',
    country: 'Bangladesh',
    offsetMinutes: 360,
  ),
  TimezoneInfo(
    id: 'asia_bangkok',
    label: 'Bangkok',
    country: 'Thailand',
    offsetMinutes: 420,
  ),
  TimezoneInfo(
    id: 'asia_jakarta',
    label: 'Jakarta',
    country: 'Indonesia',
    offsetMinutes: 420,
  ),
  TimezoneInfo(
    id: 'asia_shanghai',
    label: 'Shanghai',
    country: 'China',
    offsetMinutes: 480,
  ),
  TimezoneInfo(
    id: 'asia_hong_kong',
    label: 'Hong Kong',
    country: 'Hong Kong',
    offsetMinutes: 480,
  ),
  TimezoneInfo(
    id: 'asia_singapore',
    label: 'Singapore',
    country: 'Singapore',
    offsetMinutes: 480,
  ),
  TimezoneInfo(
    id: 'asia_tokyo',
    label: 'Tokyo',
    country: 'Japan',
    offsetMinutes: 540,
  ),
  TimezoneInfo(
    id: 'asia_seoul',
    label: 'Seoul',
    country: 'South Korea',
    offsetMinutes: 540,
  ),

  // Oceania
  TimezoneInfo(
    id: 'australia_sydney',
    label: 'Sydney',
    country: 'Australia',
    offsetMinutes: 600,
  ),
  TimezoneInfo(
    id: 'pacific_auckland',
    label: 'Auckland',
    country: 'New Zealand',
    offsetMinutes: 720,
  ),
];

/// Maps ISO-3166 alpha-2 country codes to a [TimezoneInfo.id]. Used by
/// [DateTimeFormatService.detectTimezoneByCountry].
const Map<String, String> kTimezonesByCountry = {
  'MA': 'africa_casablanca',
  'DZ': 'africa_algiers',
  'TN': 'africa_tunis',
  'EG': 'africa_cairo',
  'NG': 'africa_lagos',
  'ZA': 'africa_johannesburg',
  'GB': 'europe_london',
  'FR': 'europe_paris',
  'ES': 'europe_madrid',
  'DE': 'europe_berlin',
  'IT': 'europe_rome',
  'TR': 'europe_istanbul',
  'RU': 'europe_moscow',
  'US': 'america_new_york',
  'CA': 'america_new_york',
  'BR': 'america_sao_paulo',
  'MX': 'america_mexico_city',
  'AE': 'asia_dubai',
  'IR': 'asia_tehran',
  'SA': 'asia_riyadh',
  'PK': 'asia_karachi',
  'IN': 'asia_kolkata',
  'BD': 'asia_dhaka',
  'TH': 'asia_bangkok',
  'ID': 'asia_jakarta',
  'CN': 'asia_shanghai',
  'HK': 'asia_hong_kong',
  'SG': 'asia_singapore',
  'JP': 'asia_tokyo',
  'KR': 'asia_seoul',
  'AU': 'australia_sydney',
  'NZ': 'pacific_auckland',
};
