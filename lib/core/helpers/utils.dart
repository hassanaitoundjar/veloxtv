part of 'helpers.dart';

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
