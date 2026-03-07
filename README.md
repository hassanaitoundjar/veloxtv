# IPTV Player Premium 📺

**IPTV Player Premium** is a high-performance, feature-rich application built with Flutter, designed specifically for Android TV and Mobile devices. With a sleek, modern UI inspired by industry leaders like IPTV Smarters Pro, this app offers a premium viewing experience for Live TV, Movies, and Series.

### ✨ Key Features

- 🔑 **Xtream Codes API Login**: Fast and secure authentication.
- 📺 **Live TV**: Organized by categories with smooth channel switching.
- 🎬 **Movies & Series**: Comprehensive VOD support with posters, ratings, and episode lists.
- 🎮 **TV-First Navigation**: Fully optimized for Remote Control (D-Pad) with professional focus animations.
- 🛠️ **Customizable Branding**: Easily change logos, colors, and the app name.
- 🚀 **High Performance**: Built with BLoC for efficient state management and VLC for robust playback.

### 🛠️ Getting Started

1.  **Extract** the source code.
2.  **Run** `flutter pub get` to install dependencies.
3.  **Configure** your branding in `lib/core/helpers/constants.dart` and `lib/core/helpers/colors.dart`.
4.  **Generate** platform files (if needed): `flutter create . --platforms android,ios`.
5.  **Build** for release: `flutter build apk --release`.

For detailed instructions, see [DOCUMENTATION.md](file:///home/laradev/player/DOCUMENTATION.md).

---

### 📦 Project Structure

- `lib/core`: Branding, themes, and helper constants.
- `lib/logic`: Business logic (BLoCs & Cubits).
- `lib/presentation`: UI screens and responsive widgets.
- `lib/repository`: API interactions and data models.

---

_Professional IPTV solution for the modern era._
