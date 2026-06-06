part of 'helpers.dart';

/// Parses Xtream EPG timestamps and date strings into local [DateTime].
DateTime? parseEpgTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();

  final str = value.toString().trim();
  if (str.isEmpty || str == 'null') return null;

  if (RegExp(r'^\d+$').hasMatch(str)) {
    try {
      final n = int.parse(str);
      final ms = str.length <= 10 ? n * 1000 : n;
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
    } catch (_) {}
  }

  if (str.length >= 14 && RegExp(r'^\d{14}').hasMatch(str.substring(0, 14))) {
    try {
      final y = int.parse(str.substring(0, 4));
      final m = int.parse(str.substring(4, 6));
      final d = int.parse(str.substring(6, 8));
      final h = int.parse(str.substring(8, 10));
      final min = int.parse(str.substring(10, 12));
      final s = int.parse(str.substring(12, 14));
      return DateTime(y, m, d, h, min, s);
    } catch (_) {}
  }

  try {
    final normalized =
        str.contains(' ') && !str.contains('T') ? str.replaceFirst(' ', 'T') : str;
    return DateTime.parse(normalized).toLocal();
  } catch (_) {}

  return null;
}

/// Returns corrected start/end for an EPG entry (swaps if server data is reversed).
({DateTime start, DateTime end})? parseEpgWindow({
  String? startTimestamp,
  String? stopTimestamp,
  String? start,
  String? end,
}) {
  var startDt = parseEpgTime(startTimestamp) ?? parseEpgTime(start);
  var endDt = parseEpgTime(stopTimestamp) ?? parseEpgTime(end);
  if (startDt == null || endDt == null) return null;
  if (endDt.isBefore(startDt)) {
    final tmp = startDt;
    startDt = endDt;
    endDt = tmp;
  }
  return (start: startDt, end: endDt);
}

String decodeEpgText(String? text) {
  if (text == null || text.isEmpty) return '';
  try {
    return utf8.decode(base64.decode(text));
  } catch (_) {
    return text;
  }
}

String formatExpiration(String raw) {
  if (raw.toLowerCase() == "unlimited" || raw.isEmpty) return "Unlimited";
  // Check if it's a timestamp
  if (RegExp(r'^\d+$').hasMatch(raw)) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(raw) * 1000);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return raw;
    }
  }
  return raw;
}
