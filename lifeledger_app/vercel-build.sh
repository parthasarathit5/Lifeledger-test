#!/bin/bash
set -e

echo "=========================================="
echo " Starting LifeLedger Flutter Web Vercel Build (App Directory) "
echo "=========================================="

FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "--> Installing Flutter SDK (channel stable)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_DIR"
else
  echo "--> Flutter SDK already exists in cache, updating..."
  cd "$FLUTTER_DIR" && git pull && cd -
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "--> Verifying Flutter installation:"
flutter --version

echo "--> Enabling Flutter Web support..."
flutter config --enable-web --no-analytics

echo "--> Fetching dependencies..."
flutter pub get

echo "--> Compiling Flutter Web release build..."
flutter build web --release --pwa-strategy=none

echo "=========================================="
echo " Build successful! Output in build/web "
echo "=========================================="
