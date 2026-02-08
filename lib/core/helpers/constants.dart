part of 'helpers.dart';

const String kAppName = "Velox TV";

// Asset Paths
const String kIconSplash = "assets/images/logo.png";
const String kIconLive = "assets/images/live-stream.png";
const String kIconMovies = "assets/images/film-reel.png";
const String kIconSeries = "assets/images/clapperboard.png";
const String kImageIntro = "assets/images/intro.png";

// Screen Size Constants
const double kSizeTablet = 950;
const double kSizeTvMin = 1200;

// Animation Durations
const Duration kAnimationFast = Duration(milliseconds: 150);
const Duration kAnimationNormal = Duration(milliseconds: 300);
const Duration kAnimationSlow = Duration(milliseconds: 500);

// Focus Scale
const double kFocusScale = 1.05;

// Preferences
const String kPrefDeviceType = "device_type";

// Category Types
enum TypeCategory {
  all,
  live,
  movies,
  series,
}

// Helper Functions
Size getSize(BuildContext context) => MediaQuery.of(context).size;

bool isTv(BuildContext context) {
  return MediaQuery.of(context).size.width > kSizeTablet;
}

bool isLargeTv(BuildContext context) {
  return MediaQuery.of(context).size.width > kSizeTvMin;
}

double getGridColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > kSizeTvMin) return 7;
  if (width > kSizeTablet) return 5;
  if (width > 600) return 4;
  return 3;
}

// TV Safe Margins
EdgeInsets getTvSafeMargins(BuildContext context) {
  if (isTv(context)) {
    return const EdgeInsets.symmetric(horizontal: 48, vertical: 27);
  }
  return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
}
