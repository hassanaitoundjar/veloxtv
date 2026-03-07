#!/bin/bash
# Script to generate Android launcher icons using ImageMagick
# Usage: ./generate_icons.sh <source_image_path>

SOURCE="$1"

if [ -z "$SOURCE" ]; then
  echo "Usage: ./generate_icons.sh <source_image_path>"
  exit 1
fi

DEST_BASE="android/app/src/main/res"

# Define sizes for standard mipmap densities
# mdpi: 48x48
# hdpi: 72x72
# xhdpi: 96x96
# xxhdpi: 144x144
# xxxhdpi: 192x192

mkdir -p "$DEST_BASE/mipmap-mdpi"
convert "$SOURCE" -resize 48x48 "$DEST_BASE/mipmap-mdpi/ic_launcher.png"

mkdir -p "$DEST_BASE/mipmap-hdpi"
convert "$SOURCE" -resize 72x72 "$DEST_BASE/mipmap-hdpi/ic_launcher.png"

mkdir -p "$DEST_BASE/mipmap-xhdpi"
convert "$SOURCE" -resize 96x96 "$DEST_BASE/mipmap-xhdpi/ic_launcher.png"

mkdir -p "$DEST_BASE/mipmap-xxhdpi"
convert "$SOURCE" -resize 144x144 "$DEST_BASE/mipmap-xxhdpi/ic_launcher.png"

mkdir -p "$DEST_BASE/mipmap-xxxhdpi"
convert "$SOURCE" -resize 192x192 "$DEST_BASE/mipmap-xxxhdpi/ic_launcher.png"

echo "Icons generated successfully!"
