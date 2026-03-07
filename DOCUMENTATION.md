# IPTV Player Premium - Documentation

Welcome to the **IPTV Player Premium** documentation. This guide will help you set up, customize, and deploy your IPTV application for both Android TV and Mobile devices.

---

## 🚀 Features

- **Xtream Codes API**: Full support for Xtream Codes login (Username, Password, URL).
- **Live TV**: Category-organized channel listing with fast playback.
- **VOD (Movies & Series)**: Detailed info, posters, and season/episode management for series.
- **TV-First Experience**: Optimized for D-Pad/Remote Control navigation with professional focus states.
- **Modern UI**: Sleek dark mode design inspired by top-tier streaming services.
- **Integrated Player**: Uses high-performance VLC player for maximum codec compatibility.

---

## 🛠 Prerequisites

Before you begin, ensure you have the following installed:

1.  **Flutter SDK**: (Latest stable version recommended)
2.  **Android Studio** / **VS Code**
3.  **Dart SDK**
4.  **VLC Player**: Required for Linux development and as a dependency for the app player.

---

## 📦 Setup & Installation

### 1. Extract and Initialize

Extract the source code and run the following command in the root directory:

```bash
flutter pub get
```

### 2. Generate Platform Folders

If the `android` or `ios` folders are missing, generate them using:

```bash
flutter create . --org com.yourdomain.player --platforms android,ios
```

### 3. Configure Branding

You can easily brand the app by modifying the following files:

- **App Name**: Change `kAppName` in `lib/core/helpers/constants.dart`.
- **Colors**: Update the palette in `lib/core/helpers/colors.dart`.
- **Icons/Images**: Replace files in `assets/images/`:
  - `logo.png` (Main Logo)
  - `intro.png` (Intro Background)
  - `live-stream.png`, `film-reel.png`, `clapperboard.png` (Category Icons)

### 4. Android Permissions

Ensure your `android/app/src/main/AndroidManifest.xml` includes:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<application
    ...
    android:usesCleartextTraffic="true">
```

---

## 🎨 Customization

### Themes

The app's theme is managed in `lib/core/helpers/themes.dart`. You can modify the `ThemeData` to adjust typography, button styles, and more.

### State Management

The project uses **BLoC/Cubit** for business logic.

- Repositories are located in `lib/repository`.
- Logics (Cubit) are located in `lib/logic`.

---

## 🚀 Deployment

### Build Android APK

```bash
flutter build apk --release
```

### Build Android App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

---

## 📧 Support

If you have any questions or need further assistance, please contact us via the CodeCanyon support system.

---