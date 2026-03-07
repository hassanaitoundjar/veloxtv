#!/bin/bash

echo "🚀 Building Optimized Android Releases..."

# Clean build
echo "🧹 Cleaning..."
flutter clean
flutter pub get

# Build App Bundle (For Play Store - Smallest Download Size)
echo "📦 Building App Bundle (AAB)..."
echo "   Use this for Google Play Console uploading."
flutter build appbundle --release
echo "✅ App Bundle created at: build/app/outputs/bundle/release/app-release.aab"

# Build Split APKs (For Direct Install / Side-loading)
echo "📱 Building Split APKs (Per Architecture)..."
echo "   Use 'app-arm64-v8a-release.apk' for most modern Android phones and TVs."
flutter build apk --release --split-per-abi

echo "✅ Split APKs created at: build/app/outputs/flutter-apk/"
echo "   - app-arm64-v8a-release.apk (Modern Devices) ~35MB"
echo "   - app-armeabi-v7a-release.apk (Older Devices) ~35MB"
echo "   - app-x86_64-release.apk (Emulators/PC) ~40MB"

echo "🎉 Build Complete!"
