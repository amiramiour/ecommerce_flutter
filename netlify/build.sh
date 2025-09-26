#!/usr/bin/env bash
set -e

# Installe Flutter
git clone https://github.com/flutter/flutter.git -b ${FLUTTER_CHANNEL:-stable} --depth 1 $HOME/flutter
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter pub get

# Build Flutter Web
flutter build web --release --pwa-strategy=none --web-renderer canvaskit
