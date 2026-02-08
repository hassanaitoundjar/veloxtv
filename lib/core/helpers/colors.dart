part of 'helpers.dart';

// IPTV Smarters Pro Style Color Palette

// Primary Backgrounds
const Color kColorBackground = Color(0xFF0F172A); // Deep Dark Blue
const Color kColorBackgroundDark = Color(0xFF0A0F1A); // Darker variant
const Color kColorPanel = Color(0xFF111827); // Secondary panels

// Accent Colors
const Color kColorPrimary = Color(0xFF3B82F6); // Blue accent
const Color kColorPrimaryDark = Color(0xFF2563EB); // Darker blue
const Color kColorFocus = Color(0xFF60A5FA); // Focus/Hover blue

// Card Colors
const Color kColorCard = Color(0xFF1E293B); // Card background
const Color kColorCardLight = Color(0xFF334155); // Lighter card
const Color kColorCardDark = Color(0xFF0F172A); // Darker card

// Text Colors
const Color kColorTextPrimary = Color(0xFFFFFFFF); // Primary text
const Color kColorTextSecondary = Color(0xFF9CA3AF); // Secondary text
const Color kColorTextMuted = Color(0xFF6B7280); // Muted text

// Status Colors
const Color kColorSuccess = Color(0xFF22C55E); // Green
const Color kColorError = Color(0xFFEF4444); // Red
const Color kColorWarning = Color(0xFFF59E0B); // Orange

// Hint & Border
const Color kColorHint = Color(0xFF4B5563);
const Color kColorBorder = Color(0xFF374151);

// Decorations
BoxDecoration kDecorBackground = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [kColorBackgroundDark, kColorBackground],
  ),
);

BoxDecoration kDecorCard = BoxDecoration(
  color: kColorCard,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: kColorBorder.withOpacity(0.3)),
);

BoxDecoration kDecorFocusGlow = BoxDecoration(
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: kColorFocus.withOpacity(0.4),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ],
);

BoxDecoration kDecorIconCircle = const BoxDecoration(
  shape: BoxShape.circle,
  gradient: LinearGradient(
    colors: [kColorPrimary, kColorPrimaryDark],
  ),
);
