# IPTV Player Premium

A premium IPTV Player application built with Flutter, designed for Android TV and Mobile devices.
Inspired by IPTV Smarters Pro, it features a modern dark UI, fast navigation, and Xtream Codes API support.

## Features

- **Authentication**: Xtream Codes API login (Username, Password, URL).
- **Live TV**: Category-based navigation, EPG support (placeholder), and fast channel switching.
- **Movies & Series**: VOD support with posters, details, seasons, and episodes.
- **Player**: Integrated VLC player with overlay controls.
- **Favorites**: Save your favorite channels and VODs.
- **Search**: Local search within categories.
- **TV-First Design**: Optimized for Remote Control (D-Pad) navigation with focus states.

## Setup Instructions

**Important**: This project contains the Dart/Flutter source code in `lib/`. The platform-specific folders (android, ios, etc.) were not generated due to environment limitations.

1.  **Generate Platform Files**:
    Run the following command in the project root to generate the missing platform folders:

    ```bash
    flutter create . --org com.antigravity.player --platforms android,ios
    ```

2.  **Add Permissions**:
    After generating the `android` folder, open `android/app/src/main/AndroidManifest.xml` and add:

    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <application
        ...
        android:usesCleartextTraffic="true">
    ```

3.  **Run the App**:

    ```bash
    flutter run
    ```

4.  **Linux Setup**:
    To run on Linux, ensure you have the following dependencies installed (Ubuntu/Debian):
    ```bash
    sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev libvlc-dev vlc
    ```
    Then run:
    ```bash
    flutter run -d linux
    ```

## Architecture

- **State Management**: BLoC (Business Logic Component) and Cubit.
- **Navigation**: GetX for simple route management.
- **Networking**: Dio for API requests.
- **Player**: flutter_vlc_player.

## Project Structure

- `lib/core`: Constants, Theme, Helpers.
- `lib/logic`: BLoCs and Cubits.
- `lib/presentation`: Screens and Widgets.
- `lib/repository`: API implementation and Models.
