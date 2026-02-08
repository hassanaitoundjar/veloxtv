part of 'helpers.dart';

class AppTheme {
  static ThemeData themeData(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: kColorBackground,
      primaryColor: kColorPrimary,
      colorScheme: const ColorScheme.dark(
        primary: kColorPrimary,
        secondary: kColorFocus,
        surface: kColorCard,
        error: kColorError,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          color: kColorTextSecondary,
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: GoogleFonts.inter(
          color: kColorTextPrimary,
          fontSize: 14.sp,
        ),
        bodyMedium: GoogleFonts.inter(
          color: kColorTextSecondary,
          fontSize: 13.sp,
        ),
        bodySmall: GoogleFonts.inter(
          color: kColorTextMuted,
          fontSize: 12.sp,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(
        color: kColorTextPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kColorCard,
        hintStyle: GoogleFonts.inter(color: kColorHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kColorBorder.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kColorBorder.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kColorFocus, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kColorPrimary,
          foregroundColor: kColorTextPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
